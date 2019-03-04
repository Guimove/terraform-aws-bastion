variable "namespace" {
  type        = "string"
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = "string"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "environment" {
  type        = "string"
  default     = ""
  description = "Environment, e.g. 'testing', 'UAT'"
}

variable "name" {
  type        = "string"
  default     = "app"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `{ BusinessUnit = \"XYZ\" }`"
}

variable "enabled" {
  type        = "string"
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources"
  default     = "true"
}

variable "region" {}

variable "cidrs" {
  description = "List of CIDRs than can access to the bastion. Default : 0.0.0.0/0"
  type        = "list"

  default = [
    "0.0.0.0/0",
  ]
}

variable "bucket_versioning" {
  default = "true"
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

variable "ssh_port" {
  description = "Set the SSH port to use between the bastion and private instance"
  default     = 22
}

variable "vpc_id" {
  description = "VPC id were we'll deploy the bastion"
}

variable "is_lb_private" {
  description = "If TRUE the load balancer scheme will be \"internal\" else \"internet-facing\""
  default     = "false"
}

variable "create_dns_record" {
  description = "Choose if you want to create a record name for the bastion (LB). If true 'hosted_zone_name' and 'bastion_record_name' are mandatory "
  default     = true
}

variable "domain_name" {
  description = "Name of the hosted zone were we'll register the bastion DNS name"
  default     = ""
}

variable "lb_record_name" {
  description = "DNS record name to use for the asg behind load balancer"
  default     = ""
}

variable "key_name" {
  description = "Select the key pair to use to launch the bastion host"
}

variable "lb_subnets" {
  type        = "list"
  description = "List of subnet were the ELB will be deployed"
}

variable "auto_scaling_group_subnets" {
  type        = "list"
  description = "List of subnet were the Auto Scalling Group will deploy the instances"
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "instance_type" {
  default = "t3.micro"
}

variable "health_check_type" {
  default = "EC2"
}

variable "auto_scaling_enabled" {
  default = ""
}
