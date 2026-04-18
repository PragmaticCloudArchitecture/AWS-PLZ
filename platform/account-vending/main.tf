provider "aws" {
  region = var.region
}

resource "aws_organizations_account" "spoke" {
  name      = var.account_name
  email     = var.account_email
  parent_id = var.parent_ou_id

  role_name = "OrganizationAccountAccessRole"
  tags      = var.baseline_tags
}

resource "aws_ssm_parameter" "vended_account_id" {
  name  = "/plz/vended-accounts/${var.account_name}/account-id"
  type  = "String"
  value = aws_organizations_account.spoke.id
  tags  = var.baseline_tags
}
