locals {
  tags = "${merge(var.tags, map("vpc", "${var.vpc_id}", "tenancy", "shared"))}"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    aws_region  = "${var.region}"
    bucket_name = "${module.label.id}-access-logs"
  }
}
