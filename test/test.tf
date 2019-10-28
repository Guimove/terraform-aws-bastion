module "bastion" {
  source                = "../"
  bucket_name           = "my_famous_bucket_name"
  region                = "eu-west-1"
  vpc_id                = "my_vpc_id"
  bastion_host_key_pair = "my_key_pair"

  tags = {
    name        = "my_bastion_name"
    description = "my_bastion_description"
    toto        = "tate"
  }

  auto_scaling_group_subnets =  [
    "subnet-id1a",
    "subnet-id1b"
  ]

  create_lb         = false
  create_dns_record = false
}
