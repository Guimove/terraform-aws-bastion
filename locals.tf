locals {
  tags_asg_format = null_resource.tags_as_list_of_maps.*.triggers

  name_prefix = var.bastion_launch_configuration_name

  has_created_lb = var.create_lb ? true : false
  has_injected_lb = var.bastion_nlb != null ? true : false
  has_lb = local.has_created_lb || local.has_injected_lb
}

resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(var.tags))

  triggers = {
    "key"                 = element(keys(var.tags), count.index)
    "value"               = element(values(var.tags), count.index)
    "propagate_at_launch" = "true"
  }
}