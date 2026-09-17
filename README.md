# Pulse Fulfilment — website handoff (pulsefulfilment.co.uk)

Static HTML replacement for the WordPress/Elementor site at https://pulsefulfilment.co.uk, hosted on Ionos (Apache).
Everything in `site/` is **production code, ready to upload as-is**. This is not a mockup to rebuild in a framework.

## What's in this bundle

| Path | What it is |
|---|---|
| `site/` | The complete website. Upload its contents to the Ionos document root. Includes hidden `.htaccess`. |
| `site/.htaccess` | Canonical host (https, non-www), 75 exact 301s from old WordPress URLs, WP archive patterns, 410 for wp-admin/wp-login/xmlrpc, trailing-slash strip, cache headers, 404 → /404.html |
| `site/sitemap.xml`, `site/robots.txt` | Point at pulsefulfilment.co.uk |
| `site/assets/styles.css` | Single global stylesheet (design tokens in `:root`) |
| `site/assets/site.js` | Nav, mobile drawer, FAQ accordions, Web3Forms submit helper |
| `docs/Migration URL Map.csv` | Every live WordPress URL → new URL, with status (Match / 301 / Missing / New) |
| `docs/Website Cutover Plan.html` | Client-facing plan (summary, open decisions, cutover steps, rollback). Print to PDF. |
| `docs/Migration Audit - couk to com.html` | Working audit with full reasoning |
| `scripts/test-redirects.sh` | Curl every old URL against a host and check for 301 → 200 |
| `scripts/deploy.sh`, `scripts/check-site.py`, `.github/workflows/deploy.yml` | GitHub → Ionos SFTP deployment, see `DEPLOY.md` |

## Site structure

Clean URLs via `folder/index.html` (no rewrite needed):

```
/                      index.html
/about /services /sectors /pricing /get-pricing /contact /privacy
/integrations          hub + 44 detail pages: /integrations/<slug>/
/locations/<city>      9 pages (liverpool, leeds, london, glasgow, newcastle, sheffield, birmingham, manchester, nottingham)
/blog                  hub + 6 posts: /blog/<slug>/
/news                  hub + 1 post
/404.html
```

Pages are hand-written HTML — no build step, no templating. Header/footer markup is duplicated in every page; a change to nav requires a find-and-replace across all `index.html` files (or introduce a build step — see "Suggested next steps").

## Third-party services already wired

- **Forms** (contact, get-pricing): Web3Forms, key in `site/assets/site.js` (`PULSE_WEB3FORMS_KEY`). Honeypot field + client validation present. First submission triggers a Web3Forms confirmation email that must be clicked once.
- **Booking**: Calendly inline widget on /contact → `calendly.com/sean-pulsefulfilment/10-20-discovery-call`, pre-filled from the form.
- **Fonts**: Google Fonts (Space Grotesk, Manrope, Newsreader) via `@import` in styles.css.
- **Analytics**: none installed. Add GA4/GTM snippet to every page `<head>` before launch if required.

## Design tokens (site/assets/styles.css :root)

Ink `#131A4A` · Ink-2 `#232C6B` · Ink-soft `#5A618C` · Pink `#FF2E7E` · Pink-deep `#E11367` · Amber `#FFB627` · Amber-deep `#FF8A2B` · Paper `#FBFAF8` · Paper-2 `#F2F1F6` · Line `#E6E4EE`
Display/UI font: Space Grotesk · Body: Manrope · Editorial headlines: Newsreader. Buttons/chips are pill (100px radius).

## Deploy to Ionos

Deployment is automated from GitHub over SFTP: pushes to `main` go to production, and
the Actions tab can deploy any branch to staging or production by hand, with a dry-run
option. Setup, cutover order and rollback are in [DEPLOY.md](DEPLOY.md).

- `.github/workflows/deploy.yml` — the pipeline (check → deploy → smoke test)
- `scripts/deploy.sh` — the SFTP mirror; also runs from a laptop
- `scripts/check-site.py` — link, sitemap and redirect-target checks, run on every PR

## Open decisions (need the client)

1. **17 old integration pages have no equivalent** (volo, royal-mail, dhl-parcel, fedex, apc-overnight, the-pallet-network, 3dcart, weebly, volusion, yumbles, zedonk, store-feeder, virtual-stock, inventory-planner, channel-engine, blue-jay-solutions, sap-business-by-design). Currently 301 → /integrations. If any rank in Search Console, build a page instead.
2. **12 sector landing pages** collapse into /sectors. Same test.
3. **Analytics** — see above.

## Suggested next steps for Claude Code

- Optional: introduce a minimal static build (Eleventy or a Node script) so header/footer/JSON-LD live in one partial. Output must remain `folder/index.html`.
- Consider self-hosting the three Google Fonts for performance/GDPR.
- Integration logos in `site/uploads/` have inconsistent filenames (spaces, mixed case); rename and update references if you touch them.
- The `.com` variant of this site (canonical URLs pointing at pulsefulfilment.com) was the original build; `site/` is the .co.uk version with 416 references swapped. If .com ever goes live too, it should 301 to .co.uk rather than serve a duplicate.
