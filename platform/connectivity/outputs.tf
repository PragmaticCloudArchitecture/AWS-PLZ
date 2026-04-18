output "hub_vpc_id" {
  description = "Hub VPC ID."
  value       = module.hub_vpc.vpc_id
}

output "hub_private_subnet_ids" {
  description = "Hub private subnet IDs."
  value       = module.hub_vpc.private_subnets
}

output "transit_gateway_id" {
  description = "Transit Gateway ID used for spoke attachments."
  value       = module.transit_gateway.ec2_transit_gateway_id
}
