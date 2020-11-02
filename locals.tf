locals {
  tags_asg_format = null_resource.tags_as_list_of_maps.*.triggers

  name_prefix = var.bastion_launch_template_name
  security_group = join("", flatten([aws_security_group.bastion_host_security_group[*].id, var.bastion_security_group_id]))
}

resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(var.tags))

  triggers = {
    "key"                 = element(keys(var.tags), count.index)
    "value"               = element(values(var.tags), count.index)
    "propagate_at_launch" = "true"
  }
}

