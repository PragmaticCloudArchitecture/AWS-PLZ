# AWS-PLZ

Pragmatic Landing Zones: AWS enterprise foundations implemented as layered Terraform roots with clear ownership boundaries.

## Template inventory

| Template | Owner | Layer | Purpose |
|---|---|---|---|
| `platform/governance` | Central IT | Governance | AWS Organizations hierarchy, SCP guardrails, baseline tagging policy |
| `platform/connectivity` | Central IT | Networking | Hub VPC, Transit Gateway, shared route controls |
| `platform/security-monitoring` | Central IT | Security / Monitoring | Central CloudTrail, Config recorder, Security Hub, CloudWatch baseline |
| `platform/shared-services` | Central IT | Shared services | Shared KMS key, S3 artifacts/log buckets |
| `platform/account-vending` | Central IT | Factory | New account creation, OU placement, baseline role/tag handoff |
| `workloads/app-template` | App Teams | Application | Workload-only deployment in a vended account |

## Module strategy

This solution standardizes on:

- `hashicorp/aws` provider (pinned major versions)
- AWS- and community-recommended Terraform modules from `terraform-aws-modules` for reusable primitives (VPC, TGW, S3, Lambda)
- Native AWS resources where account-factory and org-baseline orchestration must remain explicit and auditable

## Repository layout

```text
/platform
  /governance
  /connectivity
  /security-monitoring
  /shared-services
  /account-vending

/workloads
  /app-template
```

## Build order

1. `platform/governance`
2. `platform/connectivity`
3. `platform/security-monitoring`
4. `platform/shared-services`
5. `platform/account-vending`
6. `workloads/app-template`

## Notes

- Keep one Terraform state per root.
- Pass outputs between roots via remote state or CI/CD variables.
- App teams should only deploy from `workloads/app-template`.
