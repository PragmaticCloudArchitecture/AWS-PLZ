provider "aws" {
  region = local.effective_region
}

data "aws_organizations_organization" "current" {}

locals {
  global_config = var.global_config_file == "" ? {} : yamldecode(file(var.global_config_file))
  root_id       = tolist(data.aws_organizations_organization.current.roots)[0].id

  effective_region            = coalesce(var.region, try(local.global_config.default_regions.governance, null), try(local.global_config.default_region, null))
  effective_organizational_units = length(var.organizational_units) > 0 ? var.organizational_units : try(local.global_config.organization.organizational_units, {})
  effective_baseline_scp_json = var.baseline_scp_json != "" ? var.baseline_scp_json : try(local.global_config.organization.baseline_scp_json, "")
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each = local.effective_organizational_units

  name      = each.key
  parent_id = coalesce(try(each.value.parent_ou_id, null), local.root_id)
}

resource "aws_organizations_policy" "baseline_scp" {
  count = local.effective_baseline_scp_json == "" ? 0 : 1

  name        = "baseline-scp"
  description = "Central IT baseline SCP"
  content     = local.effective_baseline_scp_json
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "baseline_scp_root" {
  count = local.effective_baseline_scp_json == "" ? 0 : 1

  policy_id = aws_organizations_policy.baseline_scp[0].id
  target_id = local.root_id
}
