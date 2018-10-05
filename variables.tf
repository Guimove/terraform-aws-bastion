variable "bucket_name" {
  description = "Bucket name were the bastion will store the logs"
}

variable "bucket_versioning" {
  default = true
  description = "Enable bucket versioning or not"
}

variable "tags" {
  description = "A mapping of tags to assign"
  default     = {}
  type        = "map"
}

variable "region" {}

variable "cidrs" {
  description = "List of CIDRs than can access to the bastion. Default : 0.0.0.0/0"
  type        = "list"

  default = [
    "0.0.0.0/0",
  ]
}

variable "is_lb_private" {
  description = "If TRUE the load balancer scheme will be \"internal\" else \"internet-facing\""
}

variable "vpc_id" {
  description = "VPC id were we'll deploy the bastion"
}

variable "bastion_host_key_pair" {
  description = "Select the key pair to use to launch the bastion host"
}

variable "hosted_zone_name" {
  description = "Name of the hosted zone were we'll register the bastion DNS name"
  default     = ""
}

variable "bastion_record_name" {
  description = "DNS record name to use for the bastion"
  default     = ""
}

variable "elb_subnets" {
  type        = "list"
  description = "List of subnet were the ELB will be deployed"
}

variable "auto_scaling_group_subnets" {
  type        = "list"
  description = "List of subnet were the Auto Scalling Group will deploy the instances"
}

variable "bastion_amis" {
  type = "map"

  default = {
    "us-east-1"      = "ami-f5f41398"
    "us-west-2"      = "ami-d0f506b0"
    "us-west-1"      = "ami-6e84fa0e"
    "eu-west-1"      = "ami-b0ac25c3"
    "eu-west-2"      = "ami-0135b45434a538069"
    "eu-central-1"   = "ami-d3c022bc"
    "ap-southeast-1" = "ami-1ddc0b7e"
    "ap-northeast-2" = "ami-cf32faa1"
    "ap-northeast-1" = "ami-29160d47"
    "ap-southeast-2" = "ami-0c95b86f"
    "sa-east-1"      = "ami-fb890097"
  }
}

variable "associate_public_ip_address" {
  default = true
}

variable "bastion_instance_count" {
  default = 1
}

variable "create_dns_record" {
  description = "Choose if you want to create a record name for the bastion (LB). If true 'hosted_zone_name' and 'bastion_record_name' are mandatory "
}

variable "log_auto_clean" {
  description = "Enable or not the lifecycle"
  default     = false
}

variable "log_standard_ia_days" {
  description = "Number of days before moving logs to IA Storage"
  default     = 30
}

variable "log_glacier_days" {
  description = "Number of days before moving logs to Glacier"
  default     = 60
}

variable "log_expiry_days" {
  description = "Number of days before logs expiration"
  default     = 90
}

variable "public_ssh_port" {
  description = "Set the SSH port to use from desktop to the bastion"
  default     = 22
}

variable "private_ssh_port" {
  description = "Set the SSH port to use between the bastion and private instance"
  default     = 22
}
