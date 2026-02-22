# Static Sites — brandnewcolony-org

Multi-site monorepo for BNC static websites, deployed to Cloudflare Pages via GitHub Actions.

## Repo Structure

```
sites/
  uncommonthings.co.uk/     # Live site
  lesleytaker.co.uk/        # Placeholder site
  placeholder.example.com/  # Scaffold template
infra/
  terragrunt.hcl             # Root Terragrunt config
  modules/
    static-sites/            # Terraform module (Cloudflare Pages + DNS)
  gcp/
    prod/
      env.hcl                # Environment settings
      static-sites/
        terragrunt.hcl       # Site definitions and Cloudflare zone IDs
.github/
  workflows/
    deploy.yml               # Auto-deploy on merge to main
AGENTS.md
```

## Adding a New Site

1. Add a site entry to `infra/gcp/prod/static-sites/terragrunt.hcl` under `sites`
2. Add the Cloudflare zone ID for the new domain
3. Add a mapping in `.github/workflows/deploy.yml` under `SITE_MAP`
4. Create a directory under `sites/<domain>/` with at least an `index.html`
5. Run `terragrunt apply` from `infra/gcp/prod/static-sites/`
6. Deploy the initial content: `npx wrangler pages deploy sites/<domain>/ --project-name=<pages-project> --branch=main`

The Terragrunt module handles: Cloudflare Pages project, custom domain
registration, and DNS CNAME records (root + www).

Required env vars for `terragrunt` commands:
```bash
export CLOUDFLARE_API_TOKEN="..."
export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)   # for GCS state backend
```

## Deployment

Automatic on merge to `main`. The workflow detects which `sites/*/` directories changed and deploys only those to their Cloudflare Pages projects via `wrangler pages deploy`.

GitHub Actions secrets required:
- `CLOUDFLARE_API_TOKEN` — Cloudflare API token with Pages:Edit and DNS:Edit
- `CLOUDFLARE_ACCOUNT_ID` — Cloudflare account ID

Manual deploy for a single site:
```bash
CLOUDFLARE_API_TOKEN="..." CLOUDFLARE_ACCOUNT_ID="..." \
  npx wrangler pages deploy sites/uncommonthings.co.uk/ \
    --project-name=uncommonthings-co-uk --branch=main --commit-dirty=true
```

## Hosting Architecture

All sites are hosted on **Cloudflare Pages** (free tier):
- Unlimited bandwidth, global CDN
- Automatic SSL via Let's Encrypt
- DNS CNAME records (proxied) point root and www to `*.pages.dev`

| Domain | Pages Project | Pages URL |
|--------|--------------|-----------|
| uncommonthings.co.uk | uncommonthings-co-uk | uncommonthings-co-uk.pages.dev |
| lesleytaker.co.uk | lesleytaker-co-uk | lesleytaker-co-uk.pages.dev |

## Infrastructure as Code

All infrastructure is managed via Terragrunt/Terraform in `infra/`.
State is stored in `gs://brandnewcolony-production-terraform-state/gcp/prod/static-sites/`.

The Terraform module at `infra/modules/static-sites/` uses a `sites` map
variable to create per-site resources via `for_each`.

Provider: `cloudflare/cloudflare ~> 4.0`

## Tech Stack

- Pure HTML/CSS/JS — no build step, no frameworks
- Inter font via Google Fonts (SIL Open Font License)
- All open source, zero proprietary dependencies
