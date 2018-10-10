locals {
  tags_asg_format = ["${null_resource.tags_as_list_of_maps.*.triggers}"]
}

resource "null_resource" "tags_as_list_of_maps" {
  count = "${length(keys(var.tags))}"

  triggers = "${map(
    "key", "${element(keys(var.tags), count.index)}",
    "value", "${element(values(var.tags), count.index)}",
    "propagate_at_launch", "true"
  )}"
}
