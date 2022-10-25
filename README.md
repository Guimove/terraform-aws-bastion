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
  source = "Guimove/bastion/aws"
  bucket_name = "my_famous_bucket_name"
  region = "eu-west-1"
  vpc_id = "my_vpc_id"
  is_lb_private = "true|false"
  bastion_host_key_pair = "my_key_pair"
  create_dns_record = "true|false"
  hosted_zone_id = "my.hosted.zone.name."
  bastion_record_name = "bastion.my.hosted.zone.name."
  bastion_iam_policy_name = "myBastionHostPolicy"
  elb_subnets = [
    "subnet-id1a",
    "subnet-id1b"
  ]
  auto_scaling_group_subnets = [
    "subnet-id1a",
    "subnet-id1b"
  ]
  tags = {
    "name" = "my_bastion_name",
    "description" = "my_bastion_description"
  }
}
```

## Requirements

| Name                                                                      | Version |
|---------------------------------------------------------------------------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | ~> 4.0  |

## Providers

| Name                                              | Version |
|---------------------------------------------------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0  |

## Resources

| Name                                                                                                                                                                                    | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [aws_autoscaling_group.bastion_auto_scaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)                                       | resource    |
| [aws_iam_instance_profile.bastion_host_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)                                       | resource    |
| [aws_iam_policy.bastion_host_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                            | resource    |
| [aws_iam_role.bastion_host_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                  | resource    |
| [aws_iam_role_policy_attachment.bastion_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                   | resource    |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                                                            | resource    |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                                  | resource    |
| [aws_launch_template.bastion_launch_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)                                              | resource    |  
| [aws_lb.bastion_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)                                                                                     | resource    |
| [aws_lb_listener.bastion_lb_listener_22](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener)                                                       | resource    |
| [aws_lb_target_group.bastion_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group)                                              | resource    |  
| [aws_route53_record.bastion_record_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                                    | resource    |        
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket_acl.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                   | resource    |
| [aws_s3_bucket_lifecycle_configuration.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                           | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_versioning.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource    |
| [aws_s3_object.bucket_public_keys_readme](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object)                                                        | resource    |
| [aws_security_group.bastion_host_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                            | resource    || [aws_security_group.private_instances_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                               | resource    |   
| [aws_security_group_rule.ingress_bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                              | resource    |  
| [aws_security_group_rule.ingress_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)                                            | resource    || [aws_ami.amazon-linux-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.assume_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                    | data source |
| [aws_iam_policy_document.bastion_host_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                              | data source |
| [aws_kms_alias.kms-ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias)                                                                       | data source |
| [aws_subnet.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet)                                                                             | data source |

## Inputs

| Name                                                                                                                                           | Description                                                                                                                                                                            | Type           | Default                            | Required |
|------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|------------------------------------|:--------:|
| <a name="input_allow_ssh_commands"></a> [allow\_ssh\_commands](#input\_allow\_ssh\_commands)                                                   | Allows the SSH user to execute one-off commands. Pass true to enable. Warning: These commands are not logged and increase the vulnerability of the system. Use at your own discretion. | `bool`         | `false`                            |    no    |     
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address)                      | n/a                                                                                                                                                                                    | `bool`         | `true`                             |    no    | 
| <a name="input_auto_scaling_group_subnets"></a> [auto\_scaling\_group\_subnets](#input\_auto\_scaling\_group\_subnets)                         | List of subnet were the Auto Scalling Group will deploy the instances                                                                                                                  | `list(string)` | n/a                                |   yes    |
| <a name="input_bastion_additional_security_groups"></a> [bastion\_additional\_security\_groups](#input\_bastion\_additional\_security\_groups) | List of additional security groups to attach to the launch template                                                                                                                    | `list(string)` | `[]`                               |    no    |
| <a name="input_bastion_ami"></a> [bastion\_ami](#input\_bastion\_ami)                                                                          | The AMI that the Bastion Host will use.                                                                                                                                                | `string`       | `""`                               |    no    |
| <a name="input_bastion_host_key_pair"></a> [bastion\_host\_key\_pair](#input\_bastion\_host\_key\_pair)                                        | Select the key pair to use to launch the bastion host                                                                                                                                  | `any`          | n/a                                |   yes    |
| <a name="input_bastion_iam_permissions_boundary"></a> [bastion\_iam\_permissions\_boundary](#input\_bastion\_iam\_permissions\_boundary)       | IAM Role Permissions Boundary to constrain the bastion host role                                                                                                                       | `string`       | `""`                               |    no    |
| <a name="input_bastion_iam_policy_name"></a> [bastion\_iam\_policy\_name](#input\_bastion\_iam\_policy\_name)                                  | IAM policy name to create for granting the instance role access to the bucket                                                                                                          | `string`       | `"BastionHost"`                    |    no    |
| <a name="input_bastion_iam_role_name"></a> [bastion\_iam\_role\_name](#input\_bastion\_iam\_role\_name)                                        | IAM role name to create                                                                                                                                                                | `string`       | `null`                             |    no    |
| <a name="input_bastion_instance_count"></a> [bastion\_instance\_count](#input\_bastion\_instance\_count)                                       | n/a                                                                                                                                                                                    | `number`       | `1`                                |    no    |
| <a name="input_bastion_launch_template_name"></a> [bastion\_launch\_template\_name](#input\_bastion\_launch\_template\_name)                   | Bastion Launch template Name, will also be used for the ASG                                                                                                                            | `string`       | `"bastion-lt"`                     |    no    |
| <a name="input_bastion_record_name"></a> [bastion\_record\_name](#input\_bastion\_record\_name)                                                | DNS record name to use for the bastion                                                                                                                                                 | `string`       | `""`                               |    no    |
| <a name="input_bastion_security_group_id"></a> [bastion\_security\_group\_id](#input\_bastion\_security\_group\_id)                            | Custom security group to use                                                                                                                                                           | `string`       | `""`                               |    no    |
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy)                                             | The bucket and all objects should be destroyed when using true                                                                                                                         | `bool`         | `false`                            |    no    |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)                                                                          | Bucket name were the bastion will store the logs                                                                                                                                       | `any`          | n/a                                |   yes    |
| <a name="input_bucket_versioning"></a> [bucket\_versioning](#input\_bucket\_versioning)                                                        | Enable bucket versioning or not                                                                                                                                                        | `bool`         | `true`                             |    no    |       
| <a name="input_cidrs"></a> [cidrs](#input\_cidrs)                                                                                              | List of CIDRs than can access to the bastion. Default : 0.0.0.0/0                                                                                                                      | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> |    no    |
| <a name="input_create_dns_record"></a> [create\_dns\_record](#input\_create\_dns\_record)                                                      | Choose if you want to create a record name for the bastion (LB). If true 'hosted\_zone\_id' and 'bastion\_record\_name' are mandatory                                                  | `any`          | n/a                                |   yes    |
| <a name="input_disk_encrypt"></a> [disk\_encrypt](#input\_disk\_encrypt)                                                                       | Instance EBS encrypt                                                                                                                                                                   | `bool`         | `true`                             |    no    |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size)                                                                                | Root EBS size in GB                                                                                                                                                                    | `number`       | `8`                                |    no    |
| <a name="input_elb_subnets"></a> [elb\_subnets](#input\_elb\_subnets)                                                                          | List of subnet were the ELB will be deployed                                                                                                                                           | `list(string)` | n/a                                |   yes    |      
| <a name="input_enable_logs_s3_sync"></a> [enable\_logs\_s3\_sync](#input\_enable\_logs\_s3\_sync)                                              | Enable cron job to copy logs to S3                                                                                                                                                     | `bool`         | `true`                             |    no    |
| <a name="input_extra_user_data_content"></a> [extra\_user\_data\_content](#input\_extra\_user\_data\_content)                                  | Additional scripting to pass to the bastion host. For example, this can include installing postgresql for the `psql` command.                                                          | `string`       | `""`                               |    no    |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id)                                                               | Name of the hosted zone were we'll register the bastion DNS name                                                                                                                       | `string`       | `""`                               |    no    |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)                                                                    | Instance size of the bastion                                                                                                                                                           | `string`       | `"t3.nano"`                        |    no    |
| <a name="input_ipv6_cidrs"></a> [ipv6\_cidrs](#input\_ipv6\_cidrs)                                                                             | List of IPv6 CIDRs than can access to the bastion. Default : ::/0                                                                                                                      | `list(string)` | <pre>[<br>  "::/0"<br>]</pre>      |    no    |
| <a name="input_is_lb_private"></a> [is\_lb\_private](#input\_is\_lb\_private)                                                                  | If TRUE the load balancer scheme will be "internal" else "internet-facing"                                                                                                             | `any`          | n/a                                |   yes    |
| <a name="input_kms_enable_key_rotation"></a> [kms\_enable\_key\_rotation](#input\_kms\_enable\_key\_rotation)                                  | Enable key rotation for the KMS key                                                                                                                                                    | `bool`         | `false`                            |    no    |
| <a name="input_log_auto_clean"></a> [log\_auto\_clean](#input\_log\_auto\_clean)                                                               | Enable or not the lifecycle                                                                                                                                                            | `bool`         | `false`                            |    no    |
| <a name="input_log_expiry_days"></a> [log\_expiry\_days](#input\_log\_expiry\_days)                                                            | Number of days before logs expiration                                                                                                                                                  | `number`       | `90`                               |    no    |     
| <a name="input_log_glacier_days"></a> [log\_glacier\_days](#input\_log\_glacier\_days)                                                         | Number of days before moving logs to Glacier                                                                                                                                           | `number`       | `60`                               |    no    |
| <a name="input_log_standard_ia_days"></a> [log\_standard\_ia\_days](#input\_log\_standard\_ia\_days)                                           | Number of days before moving logs to IA Storage                                                                                                                                        | `number`       | `30`                               |    no    |
| <a name="input_private_ssh_port"></a> [private\_ssh\_port](#input\_private\_ssh\_port)                                                         | Set the SSH port to use between the bastion and private instance                                                                                                                       | `number`       | `22`                               |    no    |
| <a name="input_public_ssh_port"></a> [public\_ssh\_port](#input\_public\_ssh\_port)                                                            | Set the SSH port to use from desktop to the bastion                                                                                                                                    | `number`       | `22`                               |    no    |
| <a name="input_region"></a> [region](#input\_region)                                                                                           | n/a                                                                                                                                                                                    | `any`          | n/a                                |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                                 | A mapping of tags to assign                                                                                                                                                            | `map(string)`  | `{}`                               |    no    |
| <a name="input_use_imds_v2"></a> [use\_imds\_v2](#input\_use\_imds\+v2)                                                                        | Use (IMDSv2) Instance Metadata Service V2                                                                                                                                              | `bool`         | `false`                            |    no    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                                                         | VPC id were we'll deploy the bastion                                                                                                                                                   | `any`          | n/a                                |   yes    |

## Outputs

| Name                                                                                                                                       | Description |
|--------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| <a name="output_bastion_auto_scaling_group_name"></a> [bastion\_auto\_scaling\_group\_name](#output\_bastion\_auto\_scaling\_group\_name)  | n/a         |        
| <a name="output_bastion_host_security_group"></a> [bastion\_host\_security\_group](#output\_bastion\_host\_security\_group)                | n/a         |
| <a name="output_bucket_kms_key_alias"></a> [bucket\_kms\_key\_alias](#output\_bucket\_kms\_key\_alias)                                     | n/a         |
| <a name="output_bucket_kms_key_arn"></a> [bucket\_kms\_key\_arn](#output\_bucket\_kms\_key\_arn)                                           | n/a         |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name)                                                                    | n/a         |
| <a name="output_elb_ip"></a> [elb\_ip](#output\_elb\_ip)                                                                                   | n/a         |
| <a name="output_private_instances_security_group"></a> [private\_instances\_security\_group](#output\_private\_instances\_security\_group) | n/a         |  

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
