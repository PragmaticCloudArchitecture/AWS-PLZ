# platform/security-monitoring

Central IT security and telemetry baseline.

## Smoke test

1. `terraform init -backend=false`
2. `terraform fmt -check`
3. `terraform validate`
4. `terraform plan -var='region=us-east-1' -var='name_prefix=plz' -var='cloudtrail_bucket_name=plz-cloudtrail-example'`
