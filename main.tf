data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    aws_region  = var.region
    bucket_name = var.bucket_name
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "bucket-owner-full-control"

  force_destroy = var.bucket_force_destroy

  versioning {
    enabled = var.bucket_versioning
  }

  lifecycle_rule {
    id      = "log"
    enabled = var.log_auto_clean

    prefix = "logs/"

    tags = {
      rule      = "log"
      autoclean = var.log_auto_clean
    }

    transition {
      days          = var.log_standard_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.log_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expiry_days
    }
  }

  tags = merge(var.tags)
}

resource "aws_s3_bucket_object" "bucket_public_keys_readme" {
  bucket  = aws_s3_bucket.bucket.id
  key     = "public-keys/README.txt"
  content = "Drop here the ssh public keys of the instances you want to control"
}

resource "aws_security_group" "bastion_host_security_group" {
  description = "Enable SSH access to the bastion host from external via SSH port"
  name        = "${local.name_prefix}-host"
  vpc_id      = var.vpc_id

  tags = merge(var.tags)
}

resource "aws_security_group_rule" "ingress_bastion" {
  description = "Incoming traffic to bastion"
  type        = "ingress"
  from_port   = var.public_ssh_port
  to_port     = var.public_ssh_port
  protocol    = "TCP"
  cidr_blocks = concat(data.aws_subnet.subnets.*.cidr_block, var.cidrs)

  security_group_id = aws_security_group.bastion_host_security_group.id
}

resource "aws_security_group_rule" "egress_bastion" {
  description = "Outgoing traffic from bastion to instances"
  type        = "egress"
  from_port   = "0"
  to_port     = "65535"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.bastion_host_security_group.id
}

resource "aws_security_group" "private_instances_security_group" {
  description = "Enable SSH access to the Private instances from the bastion via SSH port"
  name        = "${local.name_prefix}-priv-instances"
  vpc_id      = var.vpc_id

  tags = merge(var.tags)
}

resource "aws_security_group_rule" "ingress_instances" {
  description = "Incoming traffic from bastion"
  type        = "ingress"
  from_port   = var.public_ssh_port
  to_port     = var.public_ssh_port
  protocol    = "TCP"

  source_security_group_id = aws_security_group.bastion_host_security_group.id

  security_group_id = aws_security_group.private_instances_security_group.id
}

resource "aws_iam_role" "bastion_host_role" {
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "bastion_host_role_policy" {
  role = aws_iam_role.bastion_host_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::${var.bucket_name}/logs/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/public-keys/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.bucket_name}",
      "Condition": {
        "StringEquals": {
          "s3:prefix": "public-keys/"
        }
      }
    }
  ]
}
EOF

}

resource "aws_route53_record" "bastion_record_name" {
  name    = var.bastion_record_name
  zone_id = var.hosted_zone_name
  type    = "A"
  count   = var.create_dns_record && var.create_lb || var.create_dns_record && var.lcdp_bastion_nlb != null ? 1 : 0

  alias {
    evaluate_target_health = true
    name                   = var.lcdp_bastion_nlb != null ? var.lcdp_bastion_nlb.dns_name : aws_lb.bastion_lb[0].dns_name
    zone_id                = var.lcdp_bastion_nlb != null ? var.lcdp_bastion_nlb.zone_id : aws_lb.bastion_lb[0].zone_id
  }
}

resource "aws_lb" "bastion_lb" {
  internal = var.is_lb_private
  name     = "${local.name_prefix}-lb"
  count    = var.create_lb ? 1 : 0

  subnets = var.elb_subnets

  load_balancer_type = "network"
  tags               = merge(var.tags)
}

resource "aws_lb_target_group" "bastion_lb_target_group" {
  name        = "${local.name_prefix}-lb-target"
  count       = var.create_lb || var.lcdp_bastion_nlb != null ? 1 : 0
  port        = var.public_ssh_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    port     = "traffic-port"
    protocol = "TCP"
  }

  tags = merge(var.tags)
}

resource "aws_lb_listener" "bastion_lb_listener_22" {
  count              = var.create_lb || var.lcdp_bastion_nlb != null ? 1 : 0
  default_action {
    target_group_arn = aws_lb_target_group.bastion_lb_target_group[0].arn
    type             = "forward"
  }

  load_balancer_arn = var.lcdp_bastion_nlb != null ? var.lcdp_bastion_nlb.arn : aws_lb.bastion_lb[0].arn
  port              = var.public_ssh_port
  protocol          = "TCP"
}

resource "aws_iam_instance_profile" "bastion_host_profile" {
  role = aws_iam_role.bastion_host_role.name
  path = "/"
}

resource "aws_launch_configuration" "bastion_launch_configuration" {
  name_prefix                 = var.bastion_launch_configuration_name
  image_id                    = data.aws_ami.amazon-linux-2.id
  instance_type               = "t2.nano"
  associate_public_ip_address = var.associate_public_ip_address
  enable_monitoring           = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_host_profile.name
  key_name                    = var.bastion_host_key_pair

  security_groups = [
    aws_security_group.bastion_host_security_group.id
  ]

  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion_auto_scaling_group" {
  name                 = "ASG-${aws_launch_configuration.bastion_launch_configuration.name}"
  launch_configuration = aws_launch_configuration.bastion_launch_configuration.name
  max_size             = var.bastion_instance_count
  min_size             = var.bastion_instance_count
  desired_capacity     = var.bastion_instance_count

  vpc_zone_identifier = var.auto_scaling_group_subnets

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  target_group_arns = var.create_lb || var.lcdp_bastion_nlb != null ? [
    aws_lb_target_group.bastion_lb_target_group[0].arn,
  ] : []

  termination_policies = [
    "OldestLaunchConfiguration",
  ]

  tags = concat(
    list(map("key", "Name", "value", "ASG-${aws_launch_configuration.bastion_launch_configuration.name}", "propagate_at_launch", true)),
    local.tags_asg_format
  )

  lifecycle {
    create_before_destroy = true
  }
}

