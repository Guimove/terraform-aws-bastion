locals {
  name_prefix    = var.bastion_launch_template_name
  security_group = join("", flatten([aws_security_group.bastion_host_security_group[*].id, var.bastion_security_group_id]))
}

