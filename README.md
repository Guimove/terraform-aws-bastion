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

SSH  users are managed by their public key, simply drop the SSH key of the user in  the /public-keys path of the bucket.
Keys should be named like 'username.pub', this will create the user 'username' on the bastion server. Username must contain alphanumeric characters only.

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
  "source" = "Guimove/bastion/aws"
  "bucket_name" = "my_famous_bucket_name"
  "region" = "eu-west-1"
  "vpc_id" = "my_vpc_id"
  "is_lb_private" = "true|false"
  "bastion_host_key_pair" = "my_key_pair"
  "create_dns_record" = "true|false"
  "hosted_zone_id" = "my.hosted.zone.name."
  "bastion_record_name" = "bastion.my.hosted.zone.name."
  "bastion_iam_policy_name" = "myBastionHostPolicy"
  "elb_subnets" = [
    "subnet-id1a",
    "subnet-id1b"
  ]
  "auto_scaling_group_subnets" = [
    "subnet-id1a",
    "subnet-id1b"
  ]
  tags = {
    "name" = "my_bastion_name",
    "description" = "my_bastion_description"
  }
}
```

# Requirements

- Terraform >= 0.12

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| null | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_ssh\_commands | Allows the SSH user to execute one-off commands. Pass `true` to enable. Warning: These commands are not logged and increase the vulnerability of the system. Use at your own discretion. | `bool` | `false` | no |
| associate\_public\_ip\_address | Wether or not to associate a public ip | `bool` | `true` | no |
| auto\_scaling\_group\_subnets | List of subnet were the Auto Scalling Group will deploy the instances | `list(string)` | n/a | yes |
| bastion\_ami | The AMI that the Bastion Host will use. | `string` | `""` | no |
| bastion\_host\_key\_pair | Select the key pair to use to launch the bastion host | `any` | n/a | yes |
| bastion\_iam\_policy\_name | IAM policy name to create for granting the instance role access to the bucket | `string` | `"BastionHost"` | no |
| bastion\_instance\_count | Number of instances to create | `number` | `1` | no |
| bastion\_launch\_template\_name | Bastion Launch template Name, will also be used for the ASG | `string` | `"bastion-lt"` | no |
| bastion\_record\_name | DNS record name to use for the bastion | `string` | `""` | no |
| bucket\_force\_destroy | The bucket and all objects should be destroyed when using true | `bool` | `false` | no |
| bucket\_name | Bucket name were the bastion will store the logs | `any` | n/a | yes |
| bucket\_versioning | Enable bucket versioning or not | `bool` | `true` | no |
| cidrs | List of CIDRs than can access to the bastion. Default : 0.0.0.0/0 | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| create\_dns\_record | Choose if you want to create a record name for the bastion (LB). If true 'hosted\_zone\_id' and 'bastion\_record\_name' are mandatory | `any` | n/a | yes |
| disk_encrypt | EBS encryption of instance | `bool` | `true` | no |
| disk_size | Root device disk size | `number` | `8` | no |
| elb\_subnets | List of subnet were the ELB will be deployed | `list(string)` | n/a | yes |
| extra\_user\_data\_content | Additional scripting to pass to the bastion host. For example, this can include installing postgresql for the `psql` command. | `string` | `""` | no |
| hosted\_zone\_id | Name of the hosted zone were we'll register the bastion DNS name | `string` | `""` | no |
| instance\_type | Instance size of the bastion | `string` | `"t3.nano"` | no |
| is\_lb\_private | If TRUE the load balancer scheme will be "internal" else "internet-facing" | `any` | n/a | yes |
| enable\_logs\_s3\_sync | Enable cron job to copy logs to S3 | `bool` | `true` | yes |
| log\_auto\_clean | Enable or not the lifecycle | `bool` | `false` | no |
| log\_expiry\_days | Number of days before logs expiration | `number` | `90` | no |
| log\_glacier\_days | Number of days before moving logs to Glacier | `number` | `60` | no |
| log\_standard\_ia\_days | Number of days before moving logs to IA Storage | `number` | `30` | no |
| private\_ssh\_port | Set the SSH port to use between the bastion and private instance | `number` | `22` | no |
| public\_ssh\_port | Set the SSH port to use from desktop to the bastion | `number` | `22` | no |
| region | AWS Region | `any` | n/a | yes |
| tags | A mapping of tags to assign | `map(string)` | `{}` | no |
| vpc\_id | VPC id were we'll deploy the bastion | `any` | n/a | yes |


## Outputs

| Name | Description |
|------|-------------|
| bastion\_host\_security\_group | The security group ID of the Bastion Host |
| bucket\_kms\_key\_alias | The alias of the buckets kms key |
| bucket\_kms\_key\_arn | The arn of the buckets kms key |
| bucket\_name | The name of the bucket where logs are sent |
| elb\_ip | The ELB DNS Name for the Bastion Host instances |
| private\_instances\_security\_group | The security group ID of the the private instances that allow Bastion SSH ingress |
| bastion\_auto\_scaling\_group | The autoscaling group name |

Known issues
------------

Tags are not applied to the instances generated by the auto scaling group do to known terraform issue :
terraform-providers/terraform-provider-aws#290

Change of disk encryption isn't propagate immediately. Change have to trigger manually from AWS CLI:
Auto Scaling Groups -> Instance refresh . Keep in mind all data from instance will be lost in case there are temporary or custom data.

Authors
-------

Module managed by [Guimove](https://github.com/Guimove).

License
-------

Apache 2 Licensed. See LICENSE for full details.
