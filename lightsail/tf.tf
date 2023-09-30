terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "^5.0.0"
    }
  }
  backend "s3" {
    bucket  = "terraform-0"
    key     = "lightsail-proxy.terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = local.aws_region
}

locals {
  aws_region = "us-east-1"
  app_name   = "lightsail-proxy"
}

#
# resources that don't change between app deployments
#

module "base" {
  source     = "./base"
  app_name   = local.app_name
  dns_domain = var.dns_domain
  dns_record = var.dns_record
}

#
# 1 or 2 lightsail instances of a color: ["blue", "green"]
#

module "app" {
  for_each    = toset(local.ordered_versions)
  source      = "./deploy"
  app_name    = local.app_name
  app_version = each.key

  aws_region     = local.aws_region
  bucket_name    = module.base.bucket_name
  dns_fqdn       = module.base.dns_fqdn
  iam_access_key = module.base.iam_access_key
  iam_secret_key = module.base.iam_secret_key

  newrelic_license_key = var.new_relic_license_key
  newrelic_api_key = var.new_relic_api_key
  newrelic_account_id = var.new_relic_account_id
}
locals {
  ordered_versions = length(compact([var.dev, var.prod])) == 0 ? ["none"] : compact([var.dev, var.prod])
  old_version      = local.ordered_versions[0]
  new_version      = reverse(local.ordered_versions)[0]
  # [dev, prod].
  # - [1] should receive traffic if [0] exists
  # - [0] should receive traffic otherwise
}

#
# call this module to perform the traffic redirection (static ip re-attachment)
#

module "upgrade" {
  source                   = "./upgrade"
  lightsail_static_ip_name = module.base.app_static_ip_name
  lightsail_instance_name  = module.app[local.new_version].app_instance_name
  healthcheck_public_ip    = module.app[local.new_version].app_public_ip
}

#
# this switches traffic over to the 'active version' of the app
# it includes a healthcheck that can fail the deployment
# protecting us from entering a bad state
#

output "currently_active_instance" {
  value = module.upgrade.healthcheck_passed ? local.new_version : local.old_version
}