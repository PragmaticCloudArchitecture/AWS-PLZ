provider "aws" {
  region = var.region
}

data "aws_organizations_organization" "current" {}

locals {
  root_id = tolist(data.aws_organizations_organization.current.roots)[0].id
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each = var.organizational_units

  name      = each.key
  parent_id = coalesce(try(each.value.parent_ou_id, null), local.root_id)
}

resource "aws_organizations_policy" "baseline_scp" {
  count = var.baseline_scp_json == "" ? 0 : 1

  name        = "baseline-scp"
  description = "Central IT baseline SCP"
  content     = var.baseline_scp_json
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "baseline_scp_root" {
  count = var.baseline_scp_json == "" ? 0 : 1

  policy_id = aws_organizations_policy.baseline_scp[0].id
  target_id = local.root_id
}
