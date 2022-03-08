locals {
  name_prefix    = var.bastion_launch_template_name
  security_group = join("", flatten([aws_security_group.bastion_host_security_group[*].id, var.bastion_security_group_id]))

  // the compact() function checks for null values and gets rid of them 
  // the length is a check to ensure we dont have an empty array, as an empty array would throw an error for the cidr_block argument 
  ipv4_cidr_block = length(compact(data.aws_subnet.subnets[*].cidr_block)) == 0 ? null : concat(data.aws_subnet.subnets[*].cidr_block, var.cidrs)
  ipv6_cidr_block = length(compact(data.aws_subnet.subnets[*].ipv6_cidr_block)) == 0 ? null : concat(data.aws_subnet.subnets[*].ipv6_cidr_block, var.ipv6_cidrs)
}

