# DNS records pointing each domain to its Cloudflare Pages project

resource "cloudflare_record" "cname_root" {
  for_each = var.sites

  zone_id = each.value.cloudflare_zone_id
  name    = each.value.domain
  type    = "CNAME"
  content = "${local.pages_names[each.key]}.pages.dev"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "cname_www" {
  for_each = var.sites

  zone_id = each.value.cloudflare_zone_id
  name    = "www"
  type    = "CNAME"
  content = "${local.pages_names[each.key]}.pages.dev"
  ttl     = 1
  proxied = true
}
