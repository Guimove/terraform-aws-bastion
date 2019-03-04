locals {
  tags        = "${merge(var.tags, map("vpc", ${var.vpc_id}, "tenancy", "shared"))}"
  bucket_name = "${var.namespace}-${var.stage}-${var.name}-access-logs"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

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
    bucket_name = "${local.bucket_name}"
  }
}
