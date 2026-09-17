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

### 2. Ionos: folders and domains

Recommended layout, so cutover and rollback are a single setting change:

| Folder in webspace | Serves |
|---|---|
| existing WordPress folder (often `/`) | the current site, untouched |
| `/pulse-site` | production build of this repo |
| `/pulse-staging` | staging build of this repo |

- **Domains & SSL → pulsefulfilment.co.uk → Adjust destination** shows which folder the
  domain serves today. Leave it alone until cutover.
- Create a subdomain, e.g. `staging.pulsefulfilment.co.uk`, point it at
  `/pulse-staging` and enable SSL for it. Staging must be served over https,
  because `.htaccess` redirects plain http to the production host.

### 3. GitHub: environments

**Settings → Environments** → create `staging` and `production`. On `production`,
add yourself under *Required reviewers* if you want a manual approval gate before
anything reaches the live folder.

Add to each environment:

| Kind | Name | Value |
|---|---|---|
| Variable | `SFTP_HOST` | the host from step 1 |
| Variable | `REMOTE_PATH` | `/pulse-site` for production, `/pulse-staging` for staging |
| Variable | `SITE_URL` | `https://pulsefulfilment.co.uk` / `https://staging.pulsefulfilment.co.uk` (used by the smoke test; leave empty to skip it) |
| Secret | `SFTP_USER` | the SFTP user |
| Secret | `SFTP_PASSWORD` | the SFTP password |

Optional: variable `SFTP_PORT` (default 22), secret `SFTP_PRIVATE_KEY` (PEM contents,
used instead of the password), variable `DEPLOY_EXCLUDES` (extra space-separated
regexes for remote paths to leave alone, e.g. `^old-site/ ^cgi-bin/`).

`REMOTE_PATH` is relative to the SFTP root of the webspace, which is the same root
the domain destinations are chosen from.

### 4. GitHub: `main` branch

The workflow deploys to production on pushes to `main`. Create `main` from the
current branch and make it the default branch under **Settings → General**.

## First deploy and cutover

1. **Actions → Deploy to Ionos → Run workflow**, target `staging`, *Dry run* ticked.
   Read the log: it lists every upload and deletion it would make. If it wants to
   delete things you did not expect, `REMOTE_PATH` is pointing at the wrong folder.
2. Run again for `staging` without dry run. Open the staging subdomain and click
   through. The smoke test in the same run checks all the old URLs redirect.
3. Run for `production` (dry run, then real). This fills `/pulse-site` while the
   domain still serves WordPress, so nothing is live yet.
4. Back up WordPress from the Ionos panel (files and database).
5. **Cutover:** Domains & SSL → pulsefulfilment.co.uk → Adjust destination →
   `/pulse-site`. Takes effect within a few minutes.
6. Check https loads, http and www redirect, `/404` works, the contact form sends,
   and run `scripts/test-redirects.sh https://pulsefulfilment.co.uk` once more.
7. Search Console: submit `https://pulsefulfilment.co.uk/sitemap.xml`.
8. After 30 clean days, delete the WordPress folder and database and cancel plugin
   licences.

**Rollback:** Adjust destination back to the WordPress folder. Nothing in it was
changed.

If you would rather deploy in place over the WordPress folder (`REMOTE_PATH` = the
folder the domain already serves), move the WordPress files into `_wordpress_old/`
first. That folder is on the exclude list, so the deploy leaves it alone, and rollback
is moving the files back out.

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
- **Smoke test fails on `deploy-version.txt`**: the domain is not pointing at
  `REMOTE_PATH`, or a CDN/cache in front of it is serving the old copy.
- **Redirect test fails on a few URLs**: open the failing URL in a browser. If Ionos
  has its own domain-level redirect (Domains & SSL → redirect) it runs before
  `.htaccess` and can conflict.
- **Everything re-uploads every run**: expected. Git checkouts have fresh timestamps,
  so lftp re-sends all files (about 10 MB). It still deletes only what is gone from
  `site/`.
