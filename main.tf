data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    aws_region  = "${var.region}"
    bucket_name = "${var.bucket_name}"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "bucket-owner-full-control"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "log"
    enabled = "${var.log_auto_clean}"

    prefix = "logs/"

    tags {
      "rule"      = "log"
      "autoclean" = "${var.log_auto_clean}"
    }

    transition {
      days          = "${var.log_standard_ia_days}"
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = "${var.log_glacier_days}"
      storage_class = "GLACIER"
    }

    expiration {
      days = "${var.log_expiry_days}"
    }
  }

  tags = "${merge(var.tags)}"
}

resource "aws_security_group" "bastion_host_security_group" {
  description = "Enable SSH access to the bastion host from external via SSH port"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "${var.public_ssh_port}"
    protocol    = "TCP"
    to_port     = "${var.public_ssh_port}"
    cidr_blocks = "${var.cidrs}"
  }

  egress {
    from_port = "${var.private_ssh_port}"
    protocol  = "TCP"
    to_port   = "${var.private_ssh_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.tags)}"
}

resource "aws_security_group" "private_instances_security_group" {
  description = "Enable SSH access to the Private instances from the bastion via SSH port"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = "${var.private_ssh_port}"
    protocol  = "TCP"
    to_port   = "${var.private_ssh_port}"

    security_groups = [
      "${aws_security_group.bastion_host_security_group.id}",
    ]
  }

  tags = "${merge(var.tags)}"
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
  role = "${aws_iam_role.bastion_host_role.id}"

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
  name    = "${var.bastion_record_name}"
  type    = "CNAME"
  zone_id = "${var.hosted_zone_name}"
  ttl     = 300
  count   = "${var.create_dns_record}"

  records = [
    "${aws_lb.bastion_lb.dns_name}",
  ]
}

resource "aws_lb" "bastion_lb" {
  internal = "${var.is_lb_private}"

  subnets = [
    "${var.elb_subnets}",
  ]

  load_balancer_type = "network"
  tags               = "${merge(var.tags)}"
}

resource "aws_lb_target_group" "bastion_lb_target_group" {
  port        = "${var.public_ssh_port}"
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  health_check {
    port     = "traffic-port"
    protocol = "TCP"
  }

  tags = "${merge(var.tags)}"
}

resource "aws_lb_listener" "bastion_lb_listener_22" {
  "default_action" {
    target_group_arn = "${aws_lb_target_group.bastion_lb_target_group.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.bastion_lb.arn}"
  port              = "${var.public_ssh_port}"
  protocol          = "TCP"
}

resource "aws_iam_instance_profile" "bastion_host_profile" {
  role = "${aws_iam_role.bastion_host_role.name}"
  path = "/"
}

resource "aws_launch_configuration" "bastion_launch_configuration" {
  image_id                    = "${lookup(var.bastion_amis, var.region)}"
  instance_type               = "t2.nano"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  enable_monitoring           = true
  iam_instance_profile        = "${aws_iam_instance_profile.bastion_host_profile.name}"
  key_name                    = "${var.bastion_host_key_pair}"

  security_groups = [
    "${aws_security_group.bastion_host_security_group.id}",
  ]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion_auto_scaling_group" {
  launch_configuration = "${aws_launch_configuration.bastion_launch_configuration.name}"
  max_size             = "${var.bastion_instance_count}"
  min_size             = "${var.bastion_instance_count}"
  desired_capacity     = "${var.bastion_instance_count}"

  vpc_zone_identifier = [
    "${var.auto_scaling_group_subnets}",
  ]

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  target_group_arns = [
    "${aws_lb_target_group.bastion_lb_target_group.arn}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}
