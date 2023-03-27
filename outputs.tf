output "bastion_host_security_group" {
  value = aws_security_group.bastion_host_security_group[*].id
}

output "bucket_kms_key_alias" {
  value = aws_kms_alias.alias.name
}

output "bucket_kms_key_arn" {
  value = aws_kms_key.key.arn
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "elb_ip" {
  value = var.create_elb ? aws_lb.bastion_lb[0].dns_name : null
}

output "elb_arn" {
  value = var.create_elb ? aws_lb.bastion_lb[0].arn : null
}

output "target_group_arn" {
  value = var.create_elb ? aws_lb_target_group.bastion_lb_target_group[0].arn : null
}

output "private_instances_security_group" {
  value = aws_security_group.private_instances_security_group.id
}

output "bastion_auto_scaling_group_name" {
  value = aws_autoscaling_group.bastion_auto_scaling_group.name
}
