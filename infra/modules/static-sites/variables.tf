variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name_prefix" {
  description = "Prefix for shared resources (IP, LB, proxies, forwarding rules)"
  type        = string
  default     = "uncommonthings"
}

variable "bucket_location" {
  type    = string
  default = "EUROPE-WEST2"
}

variable "default_site" {
  description = "Key from the sites map to use as the URL map default backend"
  type        = string
}

variable "sites" {
  description = "Map of static sites to host"
  type = map(object({
    domain             = string
    cloudflare_zone_id = string
    dns_auth_name      = optional(string) # Override root DNS auth resource name (default: {key}-auth)
    dns_auth_www_name  = optional(string) # Override www DNS auth resource name (default: {key}-www-auth)
    cert_name          = optional(string) # Override certificate resource name (default: {key}-cert)
  }))
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "deployer_sa_account_id" {
  description = "Service account ID for the GitHub Actions deployer"
  type        = string
  default     = "static-sites-deployer"
}
