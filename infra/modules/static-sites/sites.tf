# Per-site GCP resources created via for_each over var.sites

locals {
  bucket_names     = { for k, v in var.sites : k => replace(v.domain, ".", "-") }
  dns_auth_names   = { for k, v in var.sites : k => coalesce(v.dns_auth_name, "${k}-auth") }
  dns_auth_www     = { for k, v in var.sites : k => coalesce(v.dns_auth_www_name, "${k}-www-auth") }
  cert_names       = { for k, v in var.sites : k => coalesce(v.cert_name, "${k}-cert") }
}

# --- GCS Buckets ---

resource "google_storage_bucket" "site" {
  for_each = var.sites

  name                        = local.bucket_names[each.key]
  location                    = var.bucket_location
  force_destroy               = false
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

resource "google_storage_bucket_iam_member" "public" {
  for_each = var.sites

  bucket = google_storage_bucket.site[each.key].name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "deployer" {
  for_each = var.sites

  bucket = google_storage_bucket.site[each.key].name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.deployer.email}"
}

# --- Backend Buckets (CDN-enabled) ---

resource "google_compute_backend_bucket" "site" {
  for_each = var.sites

  name        = "${each.key}-backend"
  bucket_name = google_storage_bucket.site[each.key].name
  enable_cdn  = true
}

# --- Certificate Manager DNS Authorizations ---

resource "google_certificate_manager_dns_authorization" "root" {
  for_each = var.sites

  name   = local.dns_auth_names[each.key]
  domain = each.value.domain
  type   = "PER_PROJECT_RECORD"
}

resource "google_certificate_manager_dns_authorization" "www" {
  for_each = var.sites

  name   = local.dns_auth_www[each.key]
  domain = "www.${each.value.domain}"
  type   = "PER_PROJECT_RECORD"
}

# --- Managed SSL Certificates ---

resource "google_certificate_manager_certificate" "site" {
  for_each = var.sites

  name = local.cert_names[each.key]

  managed {
    domains = [each.value.domain, "www.${each.value.domain}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.root[each.key].id,
      google_certificate_manager_dns_authorization.www[each.key].id,
    ]
  }
}

# --- Certificate Map Entries ---

resource "google_certificate_manager_certificate_map_entry" "root" {
  for_each = var.sites

  name         = "${each.key}-root-entry"
  map          = google_certificate_manager_certificate_map.main.name
  hostname     = each.value.domain
  certificates = [google_certificate_manager_certificate.site[each.key].id]
}

resource "google_certificate_manager_certificate_map_entry" "www" {
  for_each = var.sites

  name         = "${each.key}-www-entry"
  map          = google_certificate_manager_certificate_map.main.name
  hostname     = "www.${each.value.domain}"
  certificates = [google_certificate_manager_certificate.site[each.key].id]
}
