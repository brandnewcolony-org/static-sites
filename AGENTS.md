# Static Sites — brandnewcolony-org

Multi-site monorepo for BNC static websites, deployed to GCP Cloud Storage via GitHub Actions.

## Repo Structure

```
sites/
  uncommonthings.co.uk/     # Live site
  lesleytaker.co.uk/        # Placeholder site
  placeholder.example.com/  # Scaffold template
infra/
  terragrunt.hcl             # Root Terragrunt config
  modules/
    static-sites/            # Terraform module (all infra)
  gcp/
    prod/
      env.hcl                # Environment settings
      static-sites/
        terragrunt.hcl       # Site definitions and Cloudflare zone IDs
  scripts/
    import.sh                # One-time import script (already run)
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
6. Wait for the SSL cert to provision (~5-10 min)

The Terragrunt module handles: GCS bucket, backend bucket, CDN, URL map
routing, Certificate Manager DNS authorization, SSL cert, cert map entries,
Cloudflare A records, and ACME challenge CNAMEs.

Required env vars for `terragrunt` commands:
```bash
export CLOUDFLARE_API_TOKEN="..."
export GOOGLE_OAUTH_ACCESS_TOKEN=$(gcloud auth print-access-token)
```

## Deployment

Automatic on merge to `main`. The workflow detects which `sites/*/` directories changed and syncs only those to their mapped GCS buckets.

Manual deploy for a single site:
```bash
gsutil -m rsync -r -d sites/uncommonthings.co.uk/ gs://uncommonthings-co-uk/
```

## GCP Infrastructure

All in project `brandnewcolony-production`:

| Resource | Name | Purpose |
|----------|------|---------|
| GCS Bucket | `uncommonthings-co-uk` | uncommonthings.co.uk files |
| GCS Bucket | `lesleytaker-co-uk` | lesleytaker.co.uk files |
| Backend Bucket | `uncommonthings-backend` | CDN-enabled backend |
| Backend Bucket | `lesleytaker-backend` | CDN-enabled backend |
| URL Map | `uncommonthings-lb` | Host-based routing (all sites) |
| Cert Map | `uncommonthings-cert-map` | Certificate Manager map |
| Certificate | `uncommonthings-cert-cm` | Managed cert for uncommonthings.co.uk + www |
| Certificate | `lesleytaker-cert` | Managed cert for lesleytaker.co.uk + www |
| Static IP | `uncommonthings-ip` | `34.128.154.225` (shared) |
| HTTPS Proxy | `uncommonthings-https-proxy` | TLS termination |
| HTTP Proxy | `uncommonthings-http-proxy` | HTTP->HTTPS redirect |
| Service Account | `static-sites-deployer` | GitHub Actions deploys |

## Infrastructure as Code

All infrastructure is managed via Terragrunt/Terraform in `infra/`.
State is stored in `gs://brandnewcolony-production-terraform-state/gcp/prod/static-sites/`.

The Terraform module at `infra/modules/static-sites/` uses a `sites` map
variable to create per-site resources via `for_each`. Shared resources
(load balancer, static IP, cert map, service account) are created once.

Providers: `hashicorp/google ~> 5.0`, `cloudflare/cloudflare ~> 4.0`

## Tech Stack

- Pure HTML/CSS/JS — no build step, no frameworks
- Inter font via Google Fonts (SIL Open Font License)
- All open source, zero proprietary dependencies
