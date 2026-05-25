#Use this to reference VPC ID and Subnet IDs for other modules
output "vpc-id" {
  description = "vpc ID"
  value       = module.vpc.vpc-id
}

output "private-id" {
  description = "private subnet ID"
  value       = module.vpc.private-id
}

output "public-id" {
  description = "public subnet ID"
  value       = module.vpc.public-id
}

output "public-id_2" {
  value = module.vpc.public-id_2
}