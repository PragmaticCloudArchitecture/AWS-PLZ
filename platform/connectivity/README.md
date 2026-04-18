# platform/connectivity

Hub-and-spoke connectivity baseline using AWS-recommended community modules.

## Smoke test

1. `terraform init -backend=false`
2. `terraform fmt -check`
3. `terraform validate`
4. `terraform plan -var='region=us-east-1' -var='name_prefix=plz' -var='hub_vpc_cidr=10.0.0.0/16' -var='azs=["us-east-1a","us-east-1b"]' -var='private_subnet_cidrs=["10.0.1.0/24","10.0.2.0/24"]' -var='public_subnet_cidrs=["10.0.101.0/24","10.0.102.0/24"]'`
