# platform/account-vending

Central IT account factory root for spoke-account creation and handoff metadata.

## Smoke test

1. `terraform init -backend=false`
2. `terraform fmt -check`
3. `terraform validate`
4. `terraform plan -var='region=us-east-1' -var='account_name=example-dev' -var='account_email=example-dev@example.com' -var='parent_ou_id=ou-xxxx-xxxxxxxx'`
