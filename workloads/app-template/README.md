# workloads/app-template

App-team workload template. It assumes platform guardrails and networking already exist.

## Smoke test

1. `terraform init -backend=false`
2. `terraform fmt -check`
3. `terraform validate`
4. `terraform plan -var='region=us-east-1' -var='name_prefix=sample-app' -var='lambda_source_path=./src'`
