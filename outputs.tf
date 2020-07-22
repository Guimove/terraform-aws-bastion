output "bastion_host_security_group" {
  value       = aws_security_group.bastion_host_security_group.id
  description = "The security group ID of the Bastion Host"
}

output "bucket_kms_key_alias" {
  value       = aws_kms_alias.alias.name
  description = "The alias of the buckets kms key"
}

output "bucket_kms_key_arn" {
  value       = aws_kms_key.key.arn
  description = "The arn of the buckets kms key"
}

output "bucket_name" {
  value       = aws_s3_bucket.bucket.bucket
  description = "The name of the bucket where logs are sent"
}

output "elb_ip" {
  value       = aws_lb.bastion_lb.dns_name
  description = "The ELB DNS Name for the Bastion Host instances"
}

output "private_instances_security_group" {
  value       = aws_security_group.private_instances_security_group.id
  description = "The security group ID of the the private instances that allow Bastion SSH ingress"
}

