# BNC Static Sites

Monorepo for Brand New Colony's static websites, hosted on [Cloudflare Pages](https://pages.cloudflare.com/).

| Site | URL |
|------|-----|
| Uncommon Things | [uncommonthings.co.uk](https://uncommonthings.co.uk) |
| Lesley Taker | [lesleytaker.co.uk](https://lesleytaker.co.uk) |

## How it works

Each site lives in its own directory under `sites/`. Push to `main` and GitHub Actions automatically deploys any changed sites to Cloudflare Pages.

```
sites/
  uncommonthings.co.uk/   # HTML, CSS, JS, images
  lesleytaker.co.uk/       # HTML, CSS, JS, images
```

No build step, no frameworks — just static files served on Cloudflare's global CDN with free SSL.

## Adding a new site

1. Create `sites/<your-domain>/` with at least an `index.html`
2. Add a `SITE_MAP` entry in `.github/workflows/deploy.yml`
3. Add the site to `infra/gcp/prod/static-sites/terragrunt.hcl` and run `terragrunt apply` to provision the Cloudflare Pages project, custom domain, and DNS records
4. Push to `main`

## Manual deploy

```bash
export CLOUDFLARE_API_TOKEN="..."
export CLOUDFLARE_ACCOUNT_ID="..."

npx wrangler pages deploy sites/uncommonthings.co.uk/ \
  --project-name=uncommonthings-co-uk --branch=main --commit-dirty=true
```

## Infrastructure

DNS and hosting are managed as code via Terragrunt in `infra/`. See [AGENTS.md](AGENTS.md) for full details.
