locals {
  tags_asg_format = [null_resource.tags_as_list_of_maps.*.triggers]

  name_prefix = var.bastion_launch_configuration_name
}

resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(var.tags))

  triggers = {
    "key"                 = element(keys(var.tags), count.index)
    "value"               = element(values(var.tags), count.index)
    "propagate_at_launch" = "true"
  }
}

