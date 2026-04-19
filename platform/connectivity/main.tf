provider "aws" {
  region = local.effective_region
}

locals {
  global_config = var.global_config_file == "" ? {} : yamldecode(file(var.global_config_file))

  effective_region               = coalesce(var.region, try(local.global_config.default_regions.connectivity, null), try(local.global_config.default_region, null))
  effective_name_prefix          = coalesce(var.name_prefix, try(local.global_config.accounts.metadata.name_prefix, null))
  effective_hub_vpc_cidr         = coalesce(var.hub_vpc_cidr, try(local.global_config.network.hub_vpc_cidr, null))
  effective_azs                  = var.azs != null ? var.azs : try(local.global_config.network.azs, null)
  effective_private_subnet_cidrs = var.private_subnet_cidrs != null ? var.private_subnet_cidrs : try(local.global_config.network.private_subnet_cidrs, null)
  effective_public_subnet_cidrs  = var.public_subnet_cidrs != null ? var.public_subnet_cidrs : try(local.global_config.network.public_subnet_cidrs, null)
}

module "hub_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.effective_name_prefix}-hub"
  cidr = local.effective_hub_vpc_cidr

  azs             = local.effective_azs
  private_subnets = local.effective_private_subnet_cidrs
  public_subnets  = local.effective_public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = false
}

module "transit_gateway" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.11"

  name                                = "${local.effective_name_prefix}-tgw"
  description                         = "Central IT transit gateway"
  enable_auto_accept_shared_attachments = false

  vpc_attachments = {
    hub = {
      vpc_id       = module.hub_vpc.vpc_id
      subnet_ids   = module.hub_vpc.private_subnets
      dns_support  = true
      ipv6_support = false
    }
  }
}
