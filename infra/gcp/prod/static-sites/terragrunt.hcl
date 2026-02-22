include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/static-sites"
}

inputs = {
  cloudflare_api_token = get_env("CLOUDFLARE_API_TOKEN")

  default_site = "uncommonthings"

  sites = {
    uncommonthings = {
      domain             = "uncommonthings.co.uk"
      cloudflare_zone_id = "2942ea909444ea4b2c780127867eb9d4"
      dns_auth_name      = "uncommonthings-auth-v2"
      cert_name          = "uncommonthings-cert-cm"
    }
    lesleytaker = {
      domain             = "lesleytaker.co.uk"
      cloudflare_zone_id = "168fbdf85555f717a6da6a3f3666c81e"
    }
  }
}
