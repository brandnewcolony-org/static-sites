# Root terragrunt configuration

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "env.hcl"), { locals = {} })

  project_id = local.env_vars.locals.project_id
  region     = local.env_vars.locals.region
  env        = local.env_vars.locals.env
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
EOF
}

remote_state {
  backend = "gcs"
  config = {
    project  = local.project_id
    location = local.region
    bucket   = "${local.project_id}-terraform-state"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
