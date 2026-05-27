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
<<<<<<< HEAD
}
=======
}

output "kms-key" {
  description = "kms key for S3 bucket"
  value       = aws_kms_key.kms-key.arn
}

output "kms-alias-key" {
  description = "kms key for S3 bucket"
  value       = aws_kms_alias.kms-alias.arn
}

>>>>>>> main
