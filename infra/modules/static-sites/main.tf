# Shared load balancer infrastructure for all static sites

locals {
  non_default_sites = { for k, v in var.sites : k => v if k != var.default_site }
}

# --- Static IP ---

resource "google_compute_global_address" "ip" {
  name = "${var.name_prefix}-ip"
}

# --- Service Account for GitHub Actions deploys ---

resource "google_service_account" "deployer" {
  account_id   = var.deployer_sa_account_id
  display_name = "Static Sites Deployer (GitHub Actions)"
}

# --- HTTPS URL Map (host-based routing to backend buckets) ---

resource "google_compute_url_map" "main" {
  name            = "${var.name_prefix}-lb"
  default_service = google_compute_backend_bucket.site[var.default_site].self_link

  dynamic "host_rule" {
    for_each = local.non_default_sites
    content {
      hosts        = [host_rule.value.domain, "www.${host_rule.value.domain}"]
      path_matcher = "${host_rule.key}-matcher"
    }
  }

  dynamic "path_matcher" {
    for_each = local.non_default_sites
    content {
      name            = "${path_matcher.key}-matcher"
      default_service = google_compute_backend_bucket.site[path_matcher.key].self_link
    }
  }
}

# --- HTTP-to-HTTPS redirect URL Map ---

resource "google_compute_url_map" "http_redirect" {
  name = "${var.name_prefix}-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# --- Certificate Map ---

resource "google_certificate_manager_certificate_map" "main" {
  name = "${var.name_prefix}-cert-map"
}

# --- HTTPS Target Proxy ---

resource "google_compute_target_https_proxy" "main" {
  name            = "${var.name_prefix}-https-proxy"
  url_map         = google_compute_url_map.main.self_link
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.main.id}"
}

# --- HTTP Target Proxy (for redirect) ---

resource "google_compute_target_http_proxy" "redirect" {
  name    = "${var.name_prefix}-http-proxy"
  url_map = google_compute_url_map.http_redirect.self_link
}

# --- HTTPS Forwarding Rule ---

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.name_prefix}-https-rule"
  ip_address            = google_compute_global_address.ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.main.self_link
  load_balancing_scheme = "EXTERNAL"
}

# --- HTTP Forwarding Rule (redirect) ---

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.name_prefix}-http-rule"
  ip_address            = google_compute_global_address.ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.redirect.self_link
  load_balancing_scheme = "EXTERNAL"
}
