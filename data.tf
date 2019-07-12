locals {
  tags = merge(
    var.tags,
    {
      vpc     = var.vpc_id
      tenancy = "shared"
    },
  )
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    aws_region          = var.region
    bucket_name         = "${module.label.id}-access-logs"
    additional_userdata = var.userdata
  }
}

