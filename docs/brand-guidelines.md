# Pulse Fulfilment — Brand Guidelines v1.0

> Last updated: 28 October 2026
> Status: Active (reflects the live site at pulsefulfilment.co.uk)

## Quick Reference

| Element | Value |
|---------|-------|
| Primary Color | #131A4A (Ink navy) |
| Secondary Color | #FF2E7E (Pulse pink) → #FFB627 (Amber) gradient |
| Primary Font | Newsreader (headlines), Space Grotesk (UI), Manrope (body) |
| Voice | Founder-led, plain-spoken, confident, warm |

---

## 1. Color Palette

### Primary Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Ink | #131A4A | rgb(19,26,74) | Headlines, body emphasis, dark sections, footer |
| Ink 2 | #232C6B | rgb(35,44,107) | Lifted panels on navy |
| Ink Soft | #5A618C | rgb(90,97,140) | Body copy, captions |

### Secondary Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Pulse Pink | #FF2E7E | rgb(255,46,126) | Gradient start, accents |
| Pink Deep | #D6115D | rgb(214,17,93) | Accent text, eyebrows, active nav, errors |
| Amber | #FFB627 | rgb(255,182,39) | Gradient end, warm accents |
| Amber Deep | #FF8A2B | rgb(255,138,43) | Hover on amber |

The signature "pulse" gradient is `linear-gradient(100deg, #FF2E7E 0%, #FFB627 100%)`. It is
used for the primary button, one highlighted word per headline, status badges and CTA panels.
Never use it as a page background or behind body text.

### Neutral Palette

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Paper | #FBFAF8 | rgb(251,250,248) | Page background (warm off-white) |
| Paper 2 | #F2F1F6 | rgb(242,241,246) | Tinted sections and panels |
| White | #FFFFFF | rgb(255,255,255) | Cards, inputs |
| Line | #E6E4EE | rgb(230,228,238) | Hairline borders |
| Navy text soft | #C9CDF0 | rgb(201,205,240) | Body text on navy |
| Navy text muted | #9AA0D8 | rgb(154,160,216) | Captions on navy |

### Semantic Colors

| State | Hex | Usage |
|-------|-----|-------|
| Success | #2ECC8A | Ticks, "sent" states |
| Error | #D6115D | Field errors, failure messages |
| Info / neutral | #5A618C | Helper text |

### Accessibility

- Ink on Paper: 13.9:1 (AAA). Ink Soft on Paper: 6.0:1 (AA).
- Pink Deep on Paper 2: 4.56:1 (AA) — the lightest pink allowed for text.
- White on the gradient button: pass at 600 weight, 15px+.
- All interactive elements keep a visible focus ring and a 44px minimum touch target.

---

## 2. Typography

### Font Stack

| Role | Font | Weights | Fallback |
|------|------|---------|----------|
| Headlines | Newsreader | 600 (400 italic for quotes) | Georgia, serif |
| UI, nav, buttons, stats | Space Grotesk | 400–700 | system-ui, sans-serif |
| Body | Manrope | 400–800 | system-ui, sans-serif |

### Type Scale

| Element | Size | Weight | Notes |
|---------|------|--------|-------|
| Hero H1 | clamp(2.6rem, 6.2vw, 5rem) | 600 | One gradient word max |
| H2 | clamp(2rem, 4.4vw, 3.4rem) | 600 | |
| H3 | clamp(1.5rem, 2.6vw, 2.2rem) | 600 | |
| Lead | clamp(1.05rem, 1.6vw, 1.3rem) | 400 | Ink Soft |
| Body | 16–17px | 400 | line-height 1.6 |
| Eyebrow | 13–14px | 600 | Pink Deep, preceded by a short rule |
| Small / captions | 13–14px | 500 | never below 12px |

### Font Loading

Google Fonts via a single `<link rel="stylesheet">` in each page `<head>` with `display=swap`,
preceded by `preconnect` to fonts.googleapis.com and fonts.gstatic.com. No CSS `@import`.

---

## 3. Logo Usage

### Variants

| File | Use |
|------|-----|
| `site/assets/logo.png` (500×250) | Full wordmark + mark, on light backgrounds |
| `site/assets/logo-mark.png` (239×239) | Mark only: header, favicon source, social avatar |
| Header/footer lockup | Mark + "PULSE" (Space Grotesk 700) with "FULFILMENT" small-caps beneath |

### Clear Space

Keep clear space equal to the height of the "P" on all sides. In the header the mark is 40px;
never below 24px on screen or 10mm in print.

### Don'ts

- Don't recolour the mark; on navy backgrounds use the white wordmark lockup with the colour mark
- Don't stretch, rotate, outline or add drop shadows
- Don't place the logo on the gradient
- Don't set the wordmark in any font other than Space Grotesk

---

## 4. Voice & Tone

### Brand Personality

| Trait | Description |
|-------|-------------|
| **Founder-led** | Sean and Daniel's names appear; "we" means real people who answer the phone |
| **Plain-spoken** | Short sentences, no logistics jargon unless explained |
| **Confident** | Specific claims (99.8% pick accuracy, 2pm cut-off, 14+ carriers), not superlatives |
| **Warm** | Friendly and direct; "no hard sell, just real answers" |

### Voice Chart

| Trait | We Are | We Are Not |
|-------|--------|------------|
| Founder-led | Personal, accountable | Faceless, corporate |
| Plain-spoken | Clear, concrete | Vague, buzzword-heavy |
| Confident | Specific, evidence-led | Boastful, "world-class" |
| Warm | Encouraging, human | Gushing, salesy |

### Tone by Context

| Context | Tone | Example |
|---------|------|---------|
| Hero / marketing | Energetic, benefit-led | "The pulse behind growing ecommerce brands." |
| Service detail | Practical, reassuring | "Orders placed before 2pm ship the same day." |
| Forms | Friendly, low-pressure | "A few quick details, then pick a time." |
| Errors | Calm, actionable | "Something went wrong sending that. Try again, or call 0151 329 3803." |
| Success | Brief, personal | "Thanks — we'll be in touch within one working day." |

### House style

- British English (fulfilment, organise, colour). Sentence case for headings and buttons.
- "Pulse Fulfilment" in prose; "Pulse" after first mention. Legal name: Pulse Fulfilment Limited.
- Numbers as figures (14+ carriers, 300 orders/month). Use the en dash for ranges (301–750).
- CTAs: "Book a call →", "See pricing", "Get a bespoke quote →".

### Prohibited Terms

| Avoid | Reason |
|-------|--------|
| Seamless, frictionless | Overused, unprovable |
| World-class, best-in-class | Boastful; use a specific stat instead |
| Leverage, synergy, solutions | Corporate jargon |
| Cheap | Say "transparent pricing" or "no hidden surprises" |
| Fulfillment (double L) | US spelling; the brand uses "fulfilment" |

---

## 5. Imagery Guidelines

### Photography Style

Not used on the current site. If introduced: real warehouse and team photos, natural light,
warm tones, people at work; no stock models or handshake clichés.

### Illustrations

Branded navy panels with a single motif (pulse line, box icon, chart) and the gradient as the
accent; blog hero images follow this pattern (1200×600).

### Icons

Inline SVG line icons, 1.5–2px stroke, Pink Deep on soft tint tiles. No emoji icons.

---

## 6. Design Components

### Buttons

| Type | Background | Text | Border Radius |
|------|------------|------|---------------|
| Primary | Pulse gradient | #FFFFFF | 100px (pill) |
| Secondary (ghost) | Transparent, 1px Line border | #131A4A | 100px |
| On navy | Transparent, 1px rgba(255,255,255,.3) | #FFFFFF | 100px |

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | 8px | Chip gaps |
| sm | 14–16px | Button rows, grid gaps |
| md | 24–32px | Card padding |
| lg | 48–64px | Between sub-sections |
| xl | clamp(64px, 9vw, 130px) | Section padding |

### Border Radius

| Element | Radius |
|---------|--------|
| Buttons, chips, badges | 100px |
| Inputs | 10px |
| Cards | 16px |
| Panels, banner | 24px |
| Hero visual, CTA panels | 32px |

---

## Changelog

- v1.0 (28 Oct 2026): written from the live redesign.
