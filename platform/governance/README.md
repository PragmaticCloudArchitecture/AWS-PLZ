# platform/governance

Central IT governance baseline for AWS Organizations hierarchy and SCP guardrails.

## Smoke test

1. `terraform init -backend=false`
2. `terraform fmt -check`
3. `terraform validate`
4. `terraform plan -var='region=us-east-1'`
