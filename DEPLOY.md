# Deploying to Ionos

The site deploys from GitHub straight into the existing Ionos webspace over SFTP.
No build step: `site/` is uploaded as-is, including `.htaccess`.

## How it works

`.github/workflows/deploy.yml` runs on GitHub Actions:

| Trigger | What happens |
|---|---|
| Pull request | `scripts/check-site.py` only (broken links, sitemap, redirect targets, stray `.com` URLs) |
| Push to `main` | Checks, then deploy to the **production** environment, then smoke test |
| Actions tab → *Run workflow* | Checks, then deploy to **staging** or **production** by hand. Tick *Dry run* to see what would change without touching the server |

The deploy step is `scripts/deploy.sh`, which uses `lftp` to mirror `site/` into the
folder your domain points at. It uploads new and changed files and deletes remote
files that are no longer in `site/`, except paths on the exclude list (Ionos `logs/`,
`.well-known/`, `_wordpress_old/`, `.ssh/`). It also writes `deploy-version.txt`
containing the commit SHA, which the smoke test reads back to prove the upload landed.

Staging deploys get a `Disallow: /` robots.txt and an `X-Robots-Tag: noindex` header
so the staging host is never indexed.

The smoke test runs `scripts/test-redirects.sh` against the environment's URL and fails
the run if any of the 80 old WordPress URLs stop redirecting to a working page.

## One-time setup

### 1. Ionos: SFTP access

In the Ionos control panel: **Hosting → Manage webspace → SFTP & SSH access**.
Note the host name (looks like `access-1234567890.webspace-host.com` or
`home123456789.1and1-data.host`), the user name (`u12345678` or `acc...`) and set a
password. Port is 22. If your plan offers SSH keys you can use one instead of the
password (see secrets below).

### 2. Ionos: folders and domains (as set up on 7 Oct 2026)

The deploy SFTP user is restricted to the `/Staging` folder of the webspace, so the
deploy sees that folder as `/`. Both sites live inside it:

| Real folder in the webspace | Seen by the deploy as | Serves |
|---|---|---|
| `/Staging` | `/` | **production**, `pulsefulfilment.co.uk` |
| `/Staging/pulse-staging` | `/pulse-staging` | **staging**, `staging.pulsefulfilment.co.uk` |
| the old WordPress folder | not visible | nothing (kept for rollback) |

Domain destinations are set under **Domains & SSL → domain → Connect to webspace**.
The production environment has `DEPLOY_EXCLUDES` = `^pulse-staging/` so a production
deploy never deletes the staging site nested inside it.

If you ever want staging out of the production folder: widen the SFTP user's directory
to the webspace root, move `pulse-staging` up a level, and change both the subdomain's
destination and the staging `REMOTE_PATH` to match.

### 3. GitHub: environments

**Settings → Environments** → create `staging` and `production`. On `production`,
add yourself under *Required reviewers* if you want a manual approval gate before
anything reaches the live folder.

Add to each environment:

| Kind | Name | Value |
|---|---|---|
| Variable | `SFTP_HOST` | the host from step 1 |
| Variable | `REMOTE_PATH` | `/` for production, `/pulse-staging` for staging |
| Variable | `SITE_URL` | `https://pulsefulfilment.co.uk` / `https://staging.pulsefulfilment.co.uk` (used by the smoke test; leave empty to skip it) |
| Secret | `SFTP_USER` | the SFTP user |
| Secret | `SFTP_PASSWORD` | the SFTP password |

Production also needs variable `DEPLOY_EXCLUDES` = `^pulse-staging/` (see above).
Optional: variable `SFTP_PORT` (default 22), secret `SFTP_PRIVATE_KEY` (PEM contents,
used instead of the password).

`REMOTE_PATH` is relative to what the SFTP user sees as its root. **Ionos lets you
restrict an SFTP user to a folder**, and if you do, that folder becomes `/` for the
deploy while Ionos's own screens (file manager, domain destinations) still show the
full webspace. Example from the staging setup: the SFTP user is restricted to
`/Staging`, `REMOTE_PATH` is `/pulse-staging`, so the files really live at
`/Staging/pulse-staging`, and that full path is what the subdomain's destination must
be set to. If the user is not restricted, the two views are identical.

Two helper workflows in the Actions tab make this easy to check:

- **Inspect webspace** lists what the SFTP user can see at `/` and at `REMOTE_PATH`.
- **Tidy webspace** deletes exactly the paths you type in (nothing inferred).

### 4. GitHub: `main` branch

The workflow deploys to production on pushes to `main`. Create `main` from the
current branch and make it the default branch under **Settings → General**.

## Cutover status

Done on 7 Oct 2026: production build deployed, `https://pulsefulfilment.co.uk` serves
it, all 80 old WordPress URLs verified redirecting. WordPress files remain in their own
folder, untouched.

**Rollback:** Domains & SSL → `pulsefulfilment.co.uk` → Connect to webspace → pick the
WordPress folder again.

**Post go-live status (8 Oct 2026):**

- Done: contact form tested end to end on the live site (Web3Forms confirmed).
- Done: Bing Webmaster Tools reads `sitemap.xml` (Success, 71 URLs).
- Done: Google has indexed the pages; URL Inspection live test passes.
- Pending: Google Search Console's Sitemaps report still shows "could not be read /
  General HTTP error" despite the file being valid and served correctly. Known
  Search Console lag; re-check after a few days before doing anything.
- Done: Google Analytics GA4 tag (G-MXZB4LCY3H) in every page head, live since 8 Oct.
- To do: after 30 clean days, cancel the old Ionos package that still holds WordPress.

## Day to day

- Merge to `main` → production updates within a couple of minutes.
- To preview a branch, run the workflow by hand against `staging` and pick the branch
  in the *Use workflow from* dropdown.
- To roll production back to an earlier commit, run the workflow by hand against
  `production` with that commit's tag or branch selected.

## Deploying from your own machine

The same script works locally with `lftp` installed (`brew install lftp` or
`apt-get install lftp`):

```bash
export SFTP_HOST=access-1234567890.webspace-host.com
export SFTP_USER=u12345678
export SFTP_PASSWORD='...'
export REMOTE_PATH=/pulse-staging
DEPLOY_TARGET=staging DRY_RUN=true scripts/deploy.sh   # preview
DEPLOY_TARGET=staging scripts/deploy.sh                # upload
```

## Troubleshooting

- **`Login failed` / `Permission denied`**: wrong `SFTP_USER` or `SFTP_PASSWORD`, or
  the SFTP password was never set in the Ionos panel. SFTP users and control panel
  logins are different credentials.
- **Dry run lists hundreds of deletions**: `REMOTE_PATH` is a folder that holds other
  things. Point it at a folder dedicated to this site, or add patterns to
  `DEPLOY_EXCLUDES`.
- **Smoke test fails on `deploy-version.txt` with a plain Apache 404**: the domain's
  destination folder is not the folder the deploy wrote to. Run *Inspect webspace*
  to see where the files are, then set the destination (Domains & SSL → domain →
  Connect to webspace) to that folder, remembering any SFTP user restriction above.
- **Redirect test fails on a few URLs**: open the failing URL in a browser. If Ionos
  has its own domain-level redirect (Domains & SSL → redirect) it runs before
  `.htaccess` and can conflict.
- **Everything re-uploads every run**: expected. Git checkouts have fresh timestamps,
  so lftp re-sends all files (about 10 MB). It still deletes only what is gone from
  `site/`.
