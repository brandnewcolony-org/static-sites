#!/usr/bin/env bash
set -euo pipefail

# Import existing infrastructure into Terraform state.
#
# Prerequisites:
#   export CLOUDFLARE_API_TOKEN="..."
#   cd infra/gcp/prod/static-sites
#   terragrunt init
#
# Expected plan changes after import:
#   - uncommonthings-www-auth: recreated (type FIXED_RECORD -> PER_PROJECT_RECORD)
#   - Associated Cloudflare ACME CNAME for uncommonthings www: recreated (new challenge value)
#   - uncommonthings cert: may re-provision briefly (~5 min)
#   - Stale Cloudflare CNAME records (_acme-challenge.uncommonthings.co.uk,
#     _acme-challenge.www.uncommonthings.co.uk) are NOT managed and should be
#     cleaned up manually after apply.

PROJECT="brandnewcolony-production"
P="projects/${PROJECT}"

import() {
  echo "→ $1"
  terragrunt import "$1" "$2" 2>&1 | tail -1
}

echo "=== Core infrastructure ==="

import 'module.static-sites.google_compute_global_address.ip' \
  "${P}/global/addresses/uncommonthings-ip"

import 'module.static-sites.google_compute_url_map.main' \
  "${P}/global/urlMaps/uncommonthings-lb"

import 'module.static-sites.google_compute_url_map.http_redirect' \
  "${P}/global/urlMaps/uncommonthings-http-redirect"

import 'module.static-sites.google_compute_target_https_proxy.main' \
  "${P}/global/targetHttpsProxies/uncommonthings-https-proxy"

import 'module.static-sites.google_compute_target_http_proxy.redirect' \
  "${P}/global/targetHttpProxies/uncommonthings-http-proxy"

import 'module.static-sites.google_compute_global_forwarding_rule.https' \
  "${P}/global/forwardingRules/uncommonthings-https-rule"

import 'module.static-sites.google_compute_global_forwarding_rule.http' \
  "${P}/global/forwardingRules/uncommonthings-http-rule"

import 'module.static-sites.google_certificate_manager_certificate_map.main' \
  "${P}/locations/global/certificateMaps/uncommonthings-cert-map"

import 'module.static-sites.google_service_account.deployer' \
  "${P}/serviceAccounts/static-sites-deployer@${PROJECT}.iam.gserviceaccount.com"

echo ""
echo "=== uncommonthings site ==="

import 'module.static-sites.google_storage_bucket.site["uncommonthings"]' \
  "${P}/buckets/uncommonthings-co-uk"

import 'module.static-sites.google_storage_bucket_iam_member.public["uncommonthings"]' \
  "uncommonthings-co-uk roles/storage.objectViewer allUsers"

import 'module.static-sites.google_storage_bucket_iam_member.deployer["uncommonthings"]' \
  "uncommonthings-co-uk roles/storage.objectAdmin serviceAccount:static-sites-deployer@${PROJECT}.iam.gserviceaccount.com"

import 'module.static-sites.google_compute_backend_bucket.site["uncommonthings"]' \
  "${P}/global/backendBuckets/uncommonthings-backend"

import 'module.static-sites.google_certificate_manager_dns_authorization.root["uncommonthings"]' \
  "${P}/locations/global/dnsAuthorizations/uncommonthings-auth-v2"

import 'module.static-sites.google_certificate_manager_dns_authorization.www["uncommonthings"]' \
  "${P}/locations/global/dnsAuthorizations/uncommonthings-www-auth"

import 'module.static-sites.google_certificate_manager_certificate.site["uncommonthings"]' \
  "${P}/locations/global/certificates/uncommonthings-cert-cm"

import 'module.static-sites.google_certificate_manager_certificate_map_entry.root["uncommonthings"]' \
  "${P}/locations/global/certificateMaps/uncommonthings-cert-map/certificateMapEntries/uncommonthings-root-entry"

import 'module.static-sites.google_certificate_manager_certificate_map_entry.www["uncommonthings"]' \
  "${P}/locations/global/certificateMaps/uncommonthings-cert-map/certificateMapEntries/uncommonthings-www-entry"

# Cloudflare A records
import 'module.static-sites.cloudflare_record.a_root["uncommonthings"]' \
  "2942ea909444ea4b2c780127867eb9d4/12252167ac0bdd1c0c06cd618ccd4d37"

import 'module.static-sites.cloudflare_record.a_www["uncommonthings"]' \
  "2942ea909444ea4b2c780127867eb9d4/9f728d80e06e0373221d10ea90982b7b"

# ACME CNAME for root (PER_PROJECT_RECORD - matches TF config)
import 'module.static-sites.cloudflare_record.acme_root["uncommonthings"]' \
  "2942ea909444ea4b2c780127867eb9d4/1ae2ca639384fda9f5206b198a18a08c"

# ACME CNAME for www (FIXED_RECORD - will be recreated by TF as PER_PROJECT_RECORD)
import 'module.static-sites.cloudflare_record.acme_www["uncommonthings"]' \
  "2942ea909444ea4b2c780127867eb9d4/a619d4acabc3a462185669134ab652f3"

echo ""
echo "=== lesleytaker site ==="

import 'module.static-sites.google_storage_bucket.site["lesleytaker"]' \
  "${P}/buckets/lesleytaker-co-uk"

import 'module.static-sites.google_storage_bucket_iam_member.public["lesleytaker"]' \
  "lesleytaker-co-uk roles/storage.objectViewer allUsers"

import 'module.static-sites.google_storage_bucket_iam_member.deployer["lesleytaker"]' \
  "lesleytaker-co-uk roles/storage.objectAdmin serviceAccount:static-sites-deployer@${PROJECT}.iam.gserviceaccount.com"

import 'module.static-sites.google_compute_backend_bucket.site["lesleytaker"]' \
  "${P}/global/backendBuckets/lesleytaker-backend"

import 'module.static-sites.google_certificate_manager_dns_authorization.root["lesleytaker"]' \
  "${P}/locations/global/dnsAuthorizations/lesleytaker-auth"

import 'module.static-sites.google_certificate_manager_dns_authorization.www["lesleytaker"]' \
  "${P}/locations/global/dnsAuthorizations/lesleytaker-www-auth"

import 'module.static-sites.google_certificate_manager_certificate.site["lesleytaker"]' \
  "${P}/locations/global/certificates/lesleytaker-cert"

import 'module.static-sites.google_certificate_manager_certificate_map_entry.root["lesleytaker"]' \
  "${P}/locations/global/certificateMaps/uncommonthings-cert-map/certificateMapEntries/lesleytaker-root-entry"

import 'module.static-sites.google_certificate_manager_certificate_map_entry.www["lesleytaker"]' \
  "${P}/locations/global/certificateMaps/uncommonthings-cert-map/certificateMapEntries/lesleytaker-www-entry"

# Cloudflare A records
import 'module.static-sites.cloudflare_record.a_root["lesleytaker"]' \
  "168fbdf85555f717a6da6a3f3666c81e/0390df55e781809b2055dbcdec449b62"

import 'module.static-sites.cloudflare_record.a_www["lesleytaker"]' \
  "168fbdf85555f717a6da6a3f3666c81e/9c155499daeb16f137e2f196af69b353"

import 'module.static-sites.cloudflare_record.acme_root["lesleytaker"]' \
  "168fbdf85555f717a6da6a3f3666c81e/ec00831e66059298a3973c6865f99b2b"

import 'module.static-sites.cloudflare_record.acme_www["lesleytaker"]' \
  "168fbdf85555f717a6da6a3f3666c81e/5771bafcaabc653db2628ed4f06891cc"

echo ""
echo "=== Import complete ==="
echo "Run 'terragrunt plan' to review changes."
echo ""
echo "Stale records to clean up manually after apply:"
echo "  - Cloudflare CNAME: _acme-challenge.uncommonthings.co.uk (id: ac0d482adfb7df961ec4e92341261ae6)"
echo "  - Cloudflare CNAME: _acme-challenge.www.uncommonthings.co.uk (id: a619d4acabc3a462185669134ab652f3)"
