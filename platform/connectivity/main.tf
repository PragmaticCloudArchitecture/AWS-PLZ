provider "aws" {
  region = var.region
}

module "hub_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.name_prefix}-hub"
  cidr = var.hub_vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "transit_gateway" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.11"

  name                                = "${var.name_prefix}-tgw"
  description                         = "Central IT transit gateway"
  enable_auto_accept_shared_attachments = true

  vpc_attachments = {
    hub = {
      vpc_id       = module.hub_vpc.vpc_id
      subnet_ids   = module.hub_vpc.private_subnets
      dns_support  = true
      ipv6_support = false
    }
  }
}
