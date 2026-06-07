# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Single-file wedding photography portfolio for Fehér Zalán. No build tools, no dependencies — everything (HTML, CSS, JS) lives in `index.html`. Open it directly in a browser to preview.

## File structure

```
index.html        ← entire site (CSS + JS inline)
favicon.png
images/
  borito-1536x1024.jpg     (hero cover fallback)
  esküvő1/
    img02.jpg … img116.jpg (115 photos, numbered; img01 does not exist)
rólam/
  img01.jpg                (portrait for the About section)
```

The `rólam/` and `images/esküvő1/` folder names contain UTF-8 characters; in HTML/JS paths use the URL-encoded form `images/esk%C3%BCv%C5%911/imgXX.jpg`. The literal form works in CSS `url()` and in JS running locally.

The `rólam/` folder name: reference with the literal character in HTML, not an entity.

## Architecture

`index.html` is divided into clearly labelled blocks with `<!-- ═══ … ═══ -->` comment banners:

1. **`<head>` / CSS** — all styles inline in `<style>`. CSS variables at the top: `--c-gold: #C4A060`, `--c-black: #0C0B08`, `--c-dark: #161412`, `--c-white: #FAF8F4`. Fonts: Cormorant Garamond (headings) + Josefin Sans (body/nav), loaded from Google Fonts.
2. **Sections (HTML)** — in order: `#hero`, `#rolam`, `#galeria`, `#miert`, `#arak`, `#kapcsolat`, `<footer>`.
3. **`<script>`** — all JS inline at the bottom, organised with `/* ─── … ─── */` comments.

## Key mechanics

**Hero gallery** — Right side of the hero is an OGL WebGL circular gallery (`<script type="module">` at bottom). `HERO_IMGS` array lists 18 images (`img02`–`img70`, every ~4th). Auto-scrolls continuously; drag/touch overrides. Loaded from `esm.sh/ogl` CDN (requires internet).

**Gallery** — Built at runtime by JS. `GALLERY` array holds `img02–img16` (URL-encoded paths). CSS columns masonry (3 cols desktop → 2 → 1). Lightbox: vanilla JS + keyboard (← → Esc) + touch swipe.

**Animations** — `IntersectionObserver` triggers `.rev` / `.img-rev` / `.wr` reveals. Word-reveal uses `translateY(115%) → 0` on inner `<span>` inside `.wr`.

**Packages → contact pre-select** — `[data-pkg]` buttons on package cards set the matching radio in `#kapcsolat` form on click. The radio group uses class `.csomag-fg` (not `.fg`) to avoid inheriting the `border-bottom` style that `.fg input` applies to text inputs.

## Responsive breakpoints

| Max-width | Key changes |
|-----------|-------------|
| 1100 px   | Hero photos shrink (188×242 px) |
| 900 px    | ph2 + ph4 hidden; hero photos move to top corners; masonry 2-col |
| 768 px    | Nav collapses to burger menu |
| 600 px    | Hero: text on top, ph1 + ph3 anchored `bottom: 0`; parallax off; `.h-corner` hidden |
| 480 px    | Masonry 1-col |

## Contact

- Tel: +36 70 615 2131  
- Email: feherzalan4@gmail.com
