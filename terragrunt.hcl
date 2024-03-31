# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform/OpenTofu that provides extra tools for working with multiple modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  project  = "cloud-cost-352410"
  region = "us-central1"
}

generate "provider" {
  path = "provider.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "google" {
  project     = "${local.project}"
  region      = "${local.region}"
}

terraform {
  required_providers {
    google = "5.22.0"
  }  
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "gcs"
  config = {
    project        = "${local.project}"
    location       = "${local.region}"
    bucket         = "${local.project}-tf"
    prefix         = "${path_relative_to_include()}/tf.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure what repos to search when you run 'terragrunt catalog'
// catalog {
//   urls = [
//     "https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example",
//     "https://github.com/gruntwork-io/terraform-aws-utilities",
//     "https://github.com/gruntwork-io/terraform-kubernetes-namespace"
//   ]
// }

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
// inputs = merge(
//   local.account_vars.locals,
//   local.region_vars.locals,
//   local.environment_vars.locals,
// )