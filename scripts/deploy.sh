#!/usr/bin/env bash
# Deploy site/ to an Ionos webspace over SFTP.
#
# Mirrors the contents of site/ (including .htaccess) into REMOTE_PATH on the
# webspace, uploading changed files and deleting remote files that no longer
# exist in site/. Paths matching DEPLOY_EXCLUDES are never touched on either
# side, so the renamed WordPress directory, Ionos log folder, etc. survive.
#
# Required environment:
#   SFTP_HOST        e.g. access-123456789.webspace-host.com
#   SFTP_USER        e.g. u12345678 (the SFTP/SSH user from the Ionos panel)
#   SFTP_PASSWORD    or SFTP_PRIVATE_KEY (PEM contents) for key auth
#   REMOTE_PATH      folder the domain points at, e.g. / or /pulsefulfilment.co.uk
# Optional:
#   SFTP_PORT        default 22
#   DEPLOY_TARGET    production (default) or staging. Staging gets a
#                    Disallow-all robots.txt and an X-Robots-Tag noindex header.
#   DRY_RUN          true = list what would change, upload and delete nothing
#   DEPLOY_EXCLUDES  extra regexes (space separated) for paths to leave alone
#   DEPLOY_VERSION   string written to deploy-version.txt (defaults to git sha)
#
# Usage: scripts/deploy.sh            (reads the variables above)
#        DRY_RUN=true scripts/deploy.sh
set -euo pipefail

: "${SFTP_HOST:?SFTP_HOST is required}"
: "${SFTP_USER:?SFTP_USER is required}"
: "${REMOTE_PATH:?REMOTE_PATH is required (the folder your domain points at, e.g. /)}"
if [ -z "${SFTP_PASSWORD:-}" ] && [ -z "${SFTP_PRIVATE_KEY:-}" ]; then
  echo "Set SFTP_PASSWORD or SFTP_PRIVATE_KEY" >&2
  exit 1
fi
command -v lftp >/dev/null || { echo "lftp is not installed (apt-get install lftp)" >&2; exit 1; }

SFTP_PORT="${SFTP_PORT:-22}"
DEPLOY_TARGET="${DEPLOY_TARGET:-production}"
DRY_RUN="${DRY_RUN:-false}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/site"
[ -f "$SRC/.htaccess" ] || { echo "$SRC/.htaccess missing; refusing to deploy" >&2; exit 1; }

# --- Build a staging copy of site/ so the checkout is never modified --------
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD" "${KEY_FILE:-}"' EXIT
cp -a "$SRC"/. "$BUILD"/

VERSION="${DEPLOY_VERSION:-$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)}"
printf '%s %s %s\n' "$VERSION" "$DEPLOY_TARGET" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$BUILD/deploy-version.txt"

if [ "$DEPLOY_TARGET" = "staging" ]; then
  printf 'User-agent: *\nDisallow: /\n' > "$BUILD/robots.txt"
  cat >> "$BUILD/.htaccess" <<'HT'

# Staging only: keep search engines out
<IfModule mod_headers.c>
Header set X-Robots-Tag "noindex, nofollow"
</IfModule>
HT
fi

# --- Paths never uploaded or deleted --------------------------------------
# Regexes matched against paths relative to REMOTE_PATH; directories end in /.
EXCLUDES=(
  '^logs/'              # Ionos access logs at the webspace root
  '^\.well-known/'      # ACME / verification files
  '^_wordpress_old/'    # the renamed WordPress install kept for rollback
  '^\.ssh/'
  '(^|/)\.DS_Store$'
)
for extra in ${DEPLOY_EXCLUDES:-}; do EXCLUDES+=("$extra"); done
EXCLUDE_ARGS=()
for rx in "${EXCLUDES[@]}"; do EXCLUDE_ARGS+=(-x "$rx"); done

# --- SSH transport ----------------------------------------------------------
mkdir -p ~/.ssh && chmod 700 ~/.ssh
CONNECT="ssh -a -x -p $SFTP_PORT -o StrictHostKeyChecking=accept-new -o BatchMode=no"
if [ -n "${SFTP_PRIVATE_KEY:-}" ]; then
  KEY_FILE="$(mktemp)"
  printf '%s\n' "$SFTP_PRIVATE_KEY" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  CONNECT="$CONNECT -i $KEY_FILE -o IdentitiesOnly=yes"
fi
export LFTP_PASSWORD="${SFTP_PASSWORD:-}"

MIRROR_FLAGS=(--reverse --delete --no-perms --verbose=1 --parallel=4)
[ "$DRY_RUN" = "true" ] && MIRROR_FLAGS+=(--dry-run)

echo "Deploying $VERSION to $DEPLOY_TARGET: $SFTP_USER@$SFTP_HOST:$REMOTE_PATH (dry run: $DRY_RUN)"

lftp <<LFTP
set sftp:connect-program "$CONNECT"
set net:max-retries 3
set net:timeout 30
set xfer:log no
open -u "$SFTP_USER" --env-password -p $SFTP_PORT sftp://$SFTP_HOST
mirror ${MIRROR_FLAGS[*]} ${EXCLUDE_ARGS[*]@Q} "$BUILD" "$REMOTE_PATH"
bye
LFTP

echo "Done: $VERSION -> $DEPLOY_TARGET"
