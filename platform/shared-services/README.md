# platform/shared-services

Shared platform services consumed by workloads and platform automation.

## Smoke test

1. `terraform init -backend=false`
2. `terraform fmt -check`
3. `terraform validate`
4. `terraform plan -var='region=us-east-1' -var='name_prefix=plz' -var='artifact_bucket_name=plz-artifacts-example'`
