provider "aws" {
  region = local.effective_region
}

locals {
  global_config = var.global_config_file == "" ? {} : yamldecode(file(var.global_config_file))

  effective_region      = coalesce(var.region, try(local.global_config.default_regions.account_vending, null), try(local.global_config.default_region, null))
  effective_account_name = coalesce(var.account_name, try(local.global_config.accounts.account_vending.name, null))
  effective_account_email = coalesce(var.account_email, try(local.global_config.accounts.account_vending.email, null))
  effective_parent_ou_id = coalesce(var.parent_ou_id, try(local.global_config.accounts.account_vending.parent_ou_id, null))
  effective_baseline_tags = length(var.baseline_tags) > 0 ? var.baseline_tags : try(local.global_config.accounts.account_vending.baseline_tags, {})
}

resource "aws_organizations_account" "spoke" {
  name      = local.effective_account_name
  email     = local.effective_account_email
  parent_id = local.effective_parent_ou_id

  role_name = "OrganizationAccountAccessRole"
  tags      = local.effective_baseline_tags
}

resource "aws_ssm_parameter" "vended_account_id" {
  name  = "/plz/vended-accounts/${local.effective_account_name}/account-id"
  type  = "String"
  value = aws_organizations_account.spoke.id
  tags  = local.effective_baseline_tags
}
