# tf-aws-ecs-task-sfn
Terraform module to create step function to schedule fargate task.

terrafrom module config example:

```
module "ecs_task_security_group" {
  source        = "git::https://github.com/mbelousov7/aws-security-group.git"
  vpc_id        = var.vpc_id
  ingress_rules = var.security_group.ingress_rules
  egress_rules  = var.security_group.egress_rules
  labels        = local.labels
}

module "ecs_task_definition" {
  source                      = "git::https://github.com/mbelousov7/aws-ecs-task-definition.git"
  aws_region                  = var.region
  container_name              = var.container_name
  container_image             = var.container_image
  task_cpu                    = var.task_cpu
  task_memory                 = var.task_memory
  task_role_policy_arns       = local.cloudteam_policy_arns
  task_role_policy_statements = var.task_role_policy_statements
  labels                      = local.labels
}

module "ecs_task_sfn" {
  source                        = "../.."
  alarm_topic_arn               = var.alarm_topic_arn
  environment_type              = "DEVELOPMENT"
  region                        = var.region
  region_description            = "US East (N. Virginia)"
  asset_id                      = "012345"
  task_security_group_id        = module.ecs_task_security_group.id
  task_iam_role_arn             = module.ecs_task_definition.task_role_arn
  task_definition_arn           = module.ecs_task_definition.task_definition_arn
  sfn_event_role_policy_arns    = local.cloudteam_policy_arns
  sfn_role_policy_arns          = local.cloudteam_policy_arns
  account_number                = var.account_number
  task_subnet_ids               = var.subnet_ids
  sfn_event_schedule_expression = "rate(5 minutes)"
  labels                        = local.labels
}
```
more info see [examples/test](examples/test)


terraform run example
```
cd examples/test
export TF_VAR_ENV="exampletest"
terraform init
terraform plan
``` 


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.step_function_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.step_function_event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_role.sfn_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.step_function_event_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.sfn_event_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sfn_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sfn_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sfn_role_policy_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.sfn_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.step_function_event_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sfn_state_machine.step_function_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sfn_state_machine.step_function_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy_document.sfn_iam](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_number"></a> [account\_number](#input\_account\_number) | n/a | `string` | n/a | yes |
| <a name="input_alarm_config"></a> [alarm\_config](#input\_alarm\_config) | n/a | `string` | `""` | no |
| <a name="input_alarm_topic_arn"></a> [alarm\_topic\_arn](#input\_alarm\_topic\_arn) | n/a | `string` | n/a | yes |
| <a name="input_asset_id"></a> [asset\_id](#input\_asset\_id) | n/a | `string` | n/a | yes |
| <a name="input_aws_ecs_cluster_containerInsights"></a> [aws\_ecs\_cluster\_containerInsights](#input\_aws\_ecs\_cluster\_containerInsights) | option to enabled \| disabled CloudWatch Container Insights for a cluster | `string` | `"enabled"` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | provide value if ecs\_cluster\_new == false | `string` | `null` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | optionally define a custom value for the ecs cluster name and tag=Name parameter<br>in aws\_ecs\_cluster. By default, it is defined as a construction from var.labels | `string` | `"default"` | no |
| <a name="input_ecs_cluster_new"></a> [ecs\_cluster\_new](#input\_ecs\_cluster\_new) | optionally set to false, then no new ecs cluster will be created | `bool` | `true` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | n/a | `string` | n/a | yes |
| <a name="input_event_input"></a> [event\_input](#input\_event\_input) | Input payload passed into the sfn by the event | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Minimum required map of labels(tags) for creating aws resources | <pre>object({<br>    prefix    = string<br>    stack     = string<br>    component = string<br>    env       = string<br>  })</pre> | n/a | yes |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | A permissions boundary ARN to apply to the roles that are created. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_region_description"></a> [region\_description](#input\_region\_description) | n/a | `string` | n/a | yes |
| <a name="input_retry_config"></a> [retry\_config](#input\_retry\_config) | n/a | `map` | <pre>{<br>  "BackoffRate": 2,<br>  "IntervalSeconds": 1,<br>  "MaxAttempts": 5<br>}</pre> | no |
| <a name="input_sfn_custom_definition"></a> [sfn\_custom\_definition](#input\_sfn\_custom\_definition) | n/a | `string` | `"null"` | no |
| <a name="input_sfn_custom_json_file"></a> [sfn\_custom\_json\_file](#input\_sfn\_custom\_json\_file) | n/a | `string` | `null` | no |
| <a name="input_sfn_event_role_policy_arns"></a> [sfn\_event\_role\_policy\_arns](#input\_sfn\_event\_role\_policy\_arns) | A list of IAM Policy ARNs to attach to the generated sfn event role. | `list(string)` | `[]` | no |
| <a name="input_sfn_event_schedule_expression"></a> [sfn\_event\_schedule\_expression](#input\_sfn\_event\_schedule\_expression) | n/a | `string` | n/a | yes |
| <a name="input_sfn_log_group_enabled"></a> [sfn\_log\_group\_enabled](#input\_sfn\_log\_group\_enabled) | define is it necessary or not to store sfn logs in cloudwatch log group | `bool` | `true` | no |
| <a name="input_sfn_log_group_retention_in_days"></a> [sfn\_log\_group\_retention\_in\_days](#input\_sfn\_log\_group\_retention\_in\_days) | n/a | `number` | `7` | no |
| <a name="input_sfn_role_policy_arns"></a> [sfn\_role\_policy\_arns](#input\_sfn\_role\_policy\_arns) | A list of IAM Policy ARNs to attach to the generated sfn role. | `list(string)` | `[]` | no |
| <a name="input_sfn_role_policy_statements"></a> [sfn\_role\_policy\_statements](#input\_sfn\_role\_policy\_statements) | A `map` of zero or multiple role policies statements <br>which will be attached to sfn role(in addition to default) | `map(any)` | `{}` | no |
| <a name="input_sfn_type"></a> [sfn\_type](#input\_sfn\_type) | define custom if you need to use custom sfn.json file | `string` | `"default"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | define task name to run by step function | `string` | n/a | yes |
| <a name="input_task_iam_role_arn"></a> [task\_iam\_role\_arn](#input\_task\_iam\_role\_arn) | define task iam role name to run by step function | `string` | n/a | yes |
| <a name="input_task_security_group_id"></a> [task\_security\_group\_id](#input\_task\_security\_group\_id) | n/a | `string` | n/a | yes |
| <a name="input_task_subnet_ids"></a> [task\_subnet\_ids](#input\_task\_subnet\_ids) | n/a | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->