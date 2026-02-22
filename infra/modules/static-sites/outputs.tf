output "pages_urls" {
  value = { for k, v in cloudflare_pages_project.site : k => "https://${v.name}.pages.dev" }
}

output "custom_domains" {
  value = { for k, v in cloudflare_pages_domain.root : k => v.domain }
}
