output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "elb_ip" {
  value = var.create_lb ? aws_lb.bastion_lb[0].dns_name : ""
}

output "bastion_host_security_group" {
  value = aws_security_group.bastion_host_security_group.id
}

output "private_instances_security_group" {
  value = aws_security_group.private_instances_security_group.id
}

output "bastion_target_group" {
  value = aws_lb_target_group.bastion_lb_target_group
}