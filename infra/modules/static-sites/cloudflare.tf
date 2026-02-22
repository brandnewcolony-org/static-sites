# Cloudflare DNS records for each site
#
# Cloudflare normalizes record names to the subdomain-only form (e.g. "www"
# not "www.example.com"), so we use the short form to avoid spurious diffs.

locals {
  # Strip the zone suffix from ACME challenge CNAME names to get the short form
  acme_root_names = {
    for k, v in var.sites : k => trimsuffix(
      trimsuffix(google_certificate_manager_dns_authorization.root[k].dns_resource_record[0].name, "."),
      ".${v.domain}"
    )
  }
  acme_www_names = {
    for k, v in var.sites : k => trimsuffix(
      trimsuffix(google_certificate_manager_dns_authorization.www[k].dns_resource_record[0].name, "."),
      ".${v.domain}"
    )
  }
}

resource "cloudflare_record" "a_root" {
  for_each = var.sites

  zone_id = each.value.cloudflare_zone_id
  name    = each.value.domain
  type    = "A"
  content = google_compute_global_address.ip.address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "a_www" {
  for_each = var.sites

  zone_id = each.value.cloudflare_zone_id
  name    = "www"
  type    = "A"
  content = google_compute_global_address.ip.address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "acme_root" {
  for_each = var.sites

  zone_id = each.value.cloudflare_zone_id
  name    = local.acme_root_names[each.key]
  type    = "CNAME"
  content = google_certificate_manager_dns_authorization.root[each.key].dns_resource_record[0].data
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "acme_www" {
  for_each = var.sites

  zone_id = each.value.cloudflare_zone_id
  name    = local.acme_www_names[each.key]
  type    = "CNAME"
  content = google_certificate_manager_dns_authorization.www[each.key].dns_resource_record[0].data
  ttl     = 1
  proxied = false
}
