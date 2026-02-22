include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/static-sites"
}

inputs = {
  cloudflare_api_token  = get_env("CLOUDFLARE_API_TOKEN")
  cloudflare_account_id = "991473580e3eb3a71145f144f59c77ac"

  sites = {
    uncommonthings = {
      domain             = "uncommonthings.co.uk"
      cloudflare_zone_id = "2942ea909444ea4b2c780127867eb9d4"
    }
    lesleytaker = {
      domain             = "lesleytaker.co.uk"
      cloudflare_zone_id = "168fbdf85555f717a6da6a3f3666c81e"
    }
  }
}
