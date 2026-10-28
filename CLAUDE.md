# Pulse Fulfilment website — project notes for Claude

Static marketing site for https://pulsefulfilment.co.uk (UK order fulfilment / 3PL).
Hand-written HTML in `site/`, one stylesheet, one script, no build step, no framework.

## Layout

| Path | What |
|---|---|
| `site/` | The deployable site. 72 pages as `folder/index.html`, `assets/styles.css`, `assets/site.js` |
| `design-system/pulse-fulfilment/MASTER.md` | Design rules for this site (colours, type, spacing, components, anti-patterns). Read before any visual change |
| `docs/brand-guidelines.md` | Brand voice, logo rules, imagery. Source of truth for the `brand` skill |
| `.claude/skills/ui-ux-pro-max`, `.claude/skills/brand` | Design-intelligence skills (MIT, from nextlevelbuilder/ui-ux-pro-max-skill). Use for UI/UX work and reviews |
| `scripts/check-site.py` | Link, sitemap, redirect-target and `.com` checks. Run after editing pages |
| `scripts/deploy.sh`, `.github/workflows/` | Deployment to Ionos over SFTP, see DEPLOY.md |

## Rules that bite

- Header, footer, `<head>` meta and the analytics/consent snippets are **duplicated in every page**.
  A change to any of them must be applied to all 72 files (script it; do not hand-edit one page).
- Every page needs: unique `<title>` and meta description, `<link rel="canonical">`, `og:*` tags,
  the GA4 + GTM snippets at the top of `<head>`, and the GTM `<noscript>` after `<body>`.
- New pages must be added to `site/sitemap.xml`. Removed pages need a 301 in `site/.htaccess`.
- Keep images small: JPG for photos, PNG only for logos/transparency, nothing over ~200 KB.
- Do not change `--pink-deep` lighter than `#D6115D` (4.5:1 contrast on the paper backgrounds).
- Keep heading order (h1 → h2 → h3; footer headings are h3).
- Reveal animation: elements with `.reveal` are hidden until scrolled into view (`.in`); a 2.2 s
  fallback shows everything. Full-page screenshots need a scroll-through or a 3 s wait.
- Analytics: GA4 is configured on the page, GTM is alongside it. Never add a GA4 tag inside GTM.
  Events go through `window.pulseTrack(name, params)` in `site.js`.
- Staging deploys strip the https/non-www redirect and add noindex; production does not.

## Workflow for a site change

1. Edit under `site/`. Apply site-wide changes with a script across all pages.
2. `python3 scripts/check-site.py`
3. Commit, push, run the "Deploy to Ionos" workflow against `staging`, check `staging.pulsefulfilment.co.uk`.
4. Run it against `production`. Both runs end with a smoke test (version check + 80 redirect checks).

## Design work

Load the `ui-ux-pro-max` skill for anything that changes how the site looks or behaves. Use
`design-system/pulse-fulfilment/MASTER.md` as the source of truth rather than generating a
new design system; the site's look is settled. The skill's `search.py` needs Python 3 only.
