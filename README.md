AWS Bastion Terraform module
===========================================

[![Open Source Helpers](https://www.codetriage.com/guimove/terraform-aws-bastion/badges/users.svg)](https://www.codetriage.com/guimove/terraform-aws-bastion)

Terraform module which creates a secure SSH bastion on AWS.

Mainly inspired by [Securely Connect to Linux Instances Running in a Private Amazon VPC](https://aws.amazon.com/blogs/security/securely-connect-to-linux-instances-running-in-a-private-amazon-vpc/)

Features
--------

This module will create an SSH bastion to securely connect in SSH  to your private instances.
![Bastion Infrastrucutre](https://raw.githubusercontent.com/Guimove/terraform-aws-bastion/master/_docs/terraformawsbastion.png)
All SSH  commands are logged on an S3 bucket for security compliance, in the /logs path.

SSH  users are managed by their public key, simply drop the SSH key of the user in  the /public_keys path of the bucket.
Keys should be named like 'username.pub', this will create the user 'username' on the bastion server.

Then after you'll be able to connect to the server with : 

```
ssh [-i path_to_the_private_key] username@bastion-dns-name
```

From this bastion server, you'll able to connect to all instances on the private subnet. 

If there is a missing feature or a bug - [open an issue](https://github.com/Guimove/terraform-aws-bastion/issues/new).

Usage
-----

```hcl
module "bastion" {
  "source" = "terraform-aws-modules/bastion/aws"
  "bucket_name" = "my_famous_bucket_name"
  "region" = "eu-west-1"
  "vpc_id" = "my_vpc_id"
  "bastion_host_key_pair" = "my_key_pair"
  "hosted_zone_name" = "my.hosted.zone.name."
  "bastion_record_name" = "bastion.my.hosted.zone.name."
  "elb_subnets" = [
    "subnet-id1a",
    "subnet-id1b"
  ]
  "auto_scalling_group_subnets" = [
    "subnet-id1a",
    "subnet-id1b"
  ]
  tags = {
    "name" = "my_bastion_name",
    "description" = "my_bastion_description"
  }
}
```

Known issues
------------

Authors
-------

Module managed by [Guimove](https://github.com/Guimove).

License
-------

Apache 2 Licensed. See LICENSE for full details.
