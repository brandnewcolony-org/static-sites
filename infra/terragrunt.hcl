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
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "${local.project_id}"
  region  = "${local.region}"
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

inputs = {
  project_id = local.project_id
  region     = local.region
}
