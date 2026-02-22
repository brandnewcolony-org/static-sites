locals {
  pages_names = { for k, v in var.sites : k => coalesce(v.pages_project_name, replace(v.domain, ".", "-")) }
}

resource "cloudflare_pages_project" "site" {
  for_each = var.sites

  account_id      = var.cloudflare_account_id
  name            = local.pages_names[each.key]
  production_branch = "main"
}

resource "cloudflare_pages_domain" "root" {
  for_each = var.sites

  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.site[each.key].name
  domain       = each.value.domain
}

resource "cloudflare_pages_domain" "www" {
  for_each = var.sites

  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.site[each.key].name
  domain       = "www.${each.value.domain}"
}
