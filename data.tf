data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = "137112412989"

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
