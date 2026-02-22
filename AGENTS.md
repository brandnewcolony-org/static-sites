# Uncommon Things - Static Website

## Overview
Static website for **Uncommon Things**, a Liverpool-based creative studio led by curators and exhibition-makers specialising in digital art. Originally built on Readymag, this is a self-hosted static version.

## Architecture
Pure static site with zero build dependencies:
- `index.html` — single-page layout with all content
- `style.css` — full-width responsive styles, fluid typography via `clamp()`
- `script.js` — carousel (drag/swipe/keyboard), scroll-triggered animations
- `images/` — all assets downloaded from Readymag CDN

## Tech Stack
- **HTML/CSS/JS** — vanilla, no frameworks or build tools
- **Font** — Inter via Google Fonts (SIL Open Font License)
- **Hosting** — Google Cloud Storage static site serving

## Deployment
Deployed to GCP Cloud Storage as a static website bucket, fronted by a Cloud CDN load balancer with SSL.

- **Bucket**: `uncommonthings-co-uk` in `brandnewcolony-production` project
- **Domain**: uncommonthings.co.uk (when DNS is pointed)

To deploy manually:
```bash
gsutil -m rsync -r -d -x '\.git|AGENTS\.md' . gs://uncommonthings-co-uk/
```

## Content Sections
1. Hero — blue banner with studio description and nav
2. Exhibition Projects: Solo Artists — slideshow + description
3. Exhibition Projects: Group Shows — slideshow + description
4. Artist Development — slideshow + description
5. Talking, Teaching & Writing — slideshow + description
6. About Us — bios for Lesley Taker and Charlotte Horn
7. Contact — email link

## Carousel
Custom-built, supports:
- Click prev/next buttons
- Drag/swipe (mouse + touch)
- Keyboard arrows
- Dot navigation
- Wraps around at boundaries

## Notes
- All dependencies are open source (Inter font: SIL OFL, everything else: vanilla)
- Images are local — no external CDN dependencies at runtime except Google Fonts
- The site is fully functional offline (minus the font, which falls back to system sans-serif)
