# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Wedding photography portfolio for Fehér Zalán. No build tools, no dependencies — each page is a self-contained HTML file (CSS + JS inline). Open `index.html` directly in a browser to preview.

## File structure

```
index.html        ← home page (CSS + JS inline)
galeria/
  index.html      ← album-chooser page (clean URL: /galeria/)
favicon.png
images/
  og-cover.jpg             (1200×630 og:image, generated from becs-057)
  hero/  hero-01…18.jpg+webp   (hero carousel, max 1000 px)
  mid/   mid-01…44.jpg+webp    (portfolio pool; the home strip uses a curated 18)
  becs/  becs-001…097.jpg+webp (Vienna wedding album, max 1400 px; _map.csv maps to originals)
  photos/                  (SOURCE originals, 5–16 MB each, gitignored — never reference in HTML;
                            home-hero / home mid / hoome mid / Vienna 2026_06_05 subfolders)
rólam/
  img01.jpg                (portrait for the About section)
```

Image pipeline (re-run after adding originals to `images/photos/`):
1. `.claude/resize-photos.ps1` — System.Drawing resize + EXIF rotation + sanitized ASCII names → jpg
2. `.claude/make-webp.js` — webp siblings via sharp (`$env:SHARP_PATH` points at a sharp install, e.g. `%TEMP%\fz-webp\node_modules\sharp`)

Every gallery `<img>` is wrapped in `<picture>` with a `image/webp` `<source>`; the `webpOf()` helper swaps the extension. Sanitized names mean no URL-encoding is needed anywhere.

`images/photos/` and `images/photos.zip` are in `.gitignore` (GitHub blocks >100 MB files). The old `images/esküvő1/` and `borito-1536x1024.jpg` were deleted from the working tree (recoverable from git history).

The `rólam/` folder name: reference with the literal character in HTML, not an entity.

## Architecture

`index.html` is divided into clearly labelled blocks with `<!-- ═══ … ═══ -->` comment banners:

1. **`<head>` / CSS** — all styles inline in `<style>`. CSS variables at the top: `--c-gold: #B4B2AC`, `--c-black: #0C0B08`, `--c-dark: #161412`, `--c-white: #FAF8F4`. Fonts: Cormorant Garamond (headings) + Josefin Sans (body/nav), loaded from Google Fonts.
2. **Sections (HTML)** — in order: `#hero`, `#rolam`, `#galeria`, `#miert`, `#velemenyek`, `#arak`, `#foglalasmenete`, `#kapcsolat`, `<footer>`.
3. **`<script>`** — all JS inline at the bottom, organised with `/* ─── … ─── */` comments.

## Key mechanics

**Image strips** — one generic `buildStrip(id, imgs, opts)` (bottom script block) powers BOTH the hero gallery and the home portfolio. Pure CSS/JS infinite carousel (no WebGL, no CDN): tripled track for a seamless loop, auto-drift (paused via IntersectionObserver when off-screen, zeroed on `prefers-reduced-motion`), drag/touch override, parabolic "bend" per item. Options: `auto` (px/frame, sign = direction), `bend` (-1 = U arc like hero, +1 = inverted ∩ arc), `onClick` (suppressed when drag moved ≥ 8 px), `prevId`/`nextId` (arrow buttons nudge one card via a velocity impulse).
- Hero: `IMGS` loop `images/hero/hero-01…18`, `{auto: 0.65, bend: -1}`. First two images preloaded as webp in `<head>`.
- Portfolio (`#galeria`): `GALLERY` is a *curated* 18-image list from `images/mid/`, `{auto: -0.5, bend: 1}` (opposite drift + upside-down arc vs hero), with `#pgPrev`/`#pgNext` arrows; click opens the shared lightbox (keyboard ← → Esc + touch swipe). CTA button below links to `galeria/`.

**Galéria page (`galeria/index.html`)** — `WEDDINGS` array drives the album chooser. Currently one album (Vienna, 97 photos via loop). When `WEDDINGS.length === 1` the grid gets class `single` (one wide 16/10 centred card). On touch devices the card CTA is always visible (`@media (hover: none)`). Albums open a fan carousel with *windowed* loading: only `data-src`/`data-srcset` images within ~7 positions of `fanPos` get fetched (see `fanLayout`). Dots are hidden for albums with > 24 photos.

**Animations** — `IntersectionObserver` triggers `.rev` / `.img-rev` / `.wr` reveals. Word-reveal uses `translateY(115%) → 0` on inner `<span>` inside `.wr`.

**Packages → contact pre-select** — `[data-pkg]` buttons on package cards set the matching radio in `#kapcsolat` form on click. The radio group uses class `.csomag-fg` (not `.fg`) to avoid inheriting the `border-bottom` style that `.fg input` applies to text inputs.

**Contact form** — Formspree POST; `FORMSPREE_ID` is still the `XXXXXXXX` placeholder (must be set before launch). Honeypot + timing bot checks.

**A11y** — lightbox/burger/back-to-top controls are real `<button>`s with `aria-label`s; a global button reset exists in the base CSS of both pages.

## Responsive breakpoints

| Max-width | Key changes |
|-----------|-------------|
| 1100 px   | Narrower gaps; hero-left 42% |
| 900 px    | Hero stacks (gallery above text); pkg grid 1-col |
| 768 px    | Nav collapses to burger menu; timeline spine moves left |
| 600 px    | Hero strip hidden; CTA stacks; smaller portfolio arrows |
| 520 px    | Stats 2-col; form rows stack |

## Contact

- Tel: +36 70 615 2131  
- Email: feherzalan4@gmail.com
