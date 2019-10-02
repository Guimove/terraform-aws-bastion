output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "elb_ip" {
  value = aws_lb.bastion_lb.dns_name
}

output "bastion_host_security_group" {
  value = aws_security_group.bastion_host_security_group.id
}

output "private_instances_security_group" {
  value = aws_security_group.private_instances_security_group.id
}

