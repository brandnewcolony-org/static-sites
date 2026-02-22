variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "sites" {
  description = "Map of static sites hosted on Cloudflare Pages"
  type = map(object({
    domain             = string
    cloudflare_zone_id = string
    pages_project_name = optional(string) # Override Pages project name (default: domain with dots replaced by hyphens)
  }))
}
