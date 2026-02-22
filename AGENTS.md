# Static Sites — brandnewcolony-org

Multi-site monorepo for BNC static websites, deployed to GCP Cloud Storage via GitHub Actions.

## Repo Structure

```
sites/
  uncommonthings.co.uk/     # Live site
    index.html
    style.css
    script.js
    images/
  placeholder.example.com/  # Scaffold for next site
    index.html
.github/
  workflows/
    deploy.yml               # Auto-deploy on merge to main
AGENTS.md
```

## Adding a New Site

1. Create a directory under `sites/<domain>/` with at least an `index.html`
2. Create a GCS bucket for it (e.g. `gsutil mb -l europe-west2 -b on gs://<bucket-name>/`)
3. Make bucket public: `gsutil iam ch allUsers:objectViewer gs://<bucket-name>/`
4. Configure static hosting: `gsutil web set -m index.html -e index.html gs://<bucket-name>/`
5. Grant the deployer SA access: `gsutil iam ch serviceAccount:static-sites-deployer@brandnewcolony-production.iam.gserviceaccount.com:roles/storage.objectAdmin gs://<bucket-name>/`
6. Add a mapping in `.github/workflows/deploy.yml` under `SITE_MAP`
7. Add a backend bucket, host rule, and path matcher to the `uncommonthings-lb` URL map
8. Add the domain to the SSL certificate or create a new one
9. Point DNS A records to `34.128.154.225`

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
| GCS Bucket | `uncommonthings-co-uk` | Site files |
| Backend Bucket | `uncommonthings-backend` | CDN-enabled backend |
| URL Map | `uncommonthings-lb` | Host-based routing |
| SSL Cert | `uncommonthings-cert` | Managed cert for uncommonthings.co.uk + www |
| Static IP | `uncommonthings-ip` | `34.128.154.225` |
| HTTPS Proxy | `uncommonthings-https-proxy` | TLS termination |
| HTTP Proxy | `uncommonthings-http-proxy` | HTTP->HTTPS redirect |
| Service Account | `static-sites-deployer` | GitHub Actions deploys |

## Tech Stack

- Pure HTML/CSS/JS — no build step, no frameworks
- Inter font via Google Fonts (SIL Open Font License)
- All open source, zero proprietary dependencies
