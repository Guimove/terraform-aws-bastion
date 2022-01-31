module "bastion" {
  source                  = "../"
  bucket_name             = "my_famous_bucket_name"
  region                  = "eu-west-1"
  vpc_id                  = "my_vpc_id"
  is_lb_private           = "true"
  bastion_host_key_pair   = "my_key_pair"
  hosted_zone_id          = "my.hosted.zone.name."
  bastion_record_name     = "bastion.my.hosted.zone.name."
  kms_enable_key_rotation = true

  elb_subnets = [
    "subnet-id1a",
    "subnet-id1b",
  ]

  auto_scaling_group_subnets = [
    "subnet-id1a",
    "subnet-id1b",
  ]

  tags = {
    "name"        = "my_bastion_name"
    "description" = "my_bastion_description"
    "toto"        = "tate"
  }

  create_dns_record = true
}
