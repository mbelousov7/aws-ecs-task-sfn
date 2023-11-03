######################################## names, labels, tags ########################################
variable "labels" {
  type = object({
    prefix    = string
    stack     = string
    component = string
    env       = string
  })
  description = "Minimum required map of labels(tags) for creating aws resources"
}

variable "asset_id" {
  type = string
}

variable "region_description" {
  type = string
}

variable "environment_type" {
  type = string
}

variable "retry_config" {
  default = {
    IntervalSeconds = 1
    MaxAttempts     = 5
    BackoffRate     = 2
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}


variable "region" {
  type    = string
  default = "us-east-1"
}

variable "account_number" {
  type = string
}

variable "ecs_cluster_name" {
  type        = string
  description = <<-EOT
      optionally define a custom value for the ecs cluster name and tag=Name parameter
      in aws_ecs_cluster. By default, it is defined as a construction from var.labels
    EOT
  default     = "default"
}

variable "ecs_cluster_new" {
  type        = bool
  description = <<-EOT
      optionally set to false, then no new ecs cluster will be created
    EOT
  default     = true
}

variable "ecs_cluster_arn" {
  type        = string
  description = <<-EOT
      provide value if ecs_cluster_new == false
    EOT
  default     = null
}

variable "aws_ecs_cluster_containerInsights" {
  type        = string
  description = "option to enabled | disabled CloudWatch Container Insights for a cluster"
  default     = "enabled"
}

######################################## iam roles and policies vars ########################################
variable "sfn_role_policy_arns" {
  type        = list(string)
  description = "A list of IAM Policy ARNs to attach to the generated sfn role."
  default     = []
}

variable "sfn_role_policy_statements" {
  type        = map(any)
  description = <<-EOT
    A `map` of zero or multiple role policies statements 
    which will be attached to sfn role(in addition to default)
    EOT
  default     = {}
}

variable "permissions_boundary" {
  type        = string
  description = "A permissions boundary ARN to apply to the roles that are created."
  default     = ""
}

######################################## task definition vars ########################################

variable "task_definition_arn" {
  type        = string
  description = <<-EOT
       define task name to run by step function
    EOT
}

variable "task_iam_role_arn" {
  type        = string
  description = <<-EOT
       define task iam role name to run by step function
    EOT
}

variable "task_security_group_id" {
  type = string
}

variable "task_subnet_ids" {
  type = list(string)
}

variable "alarm_topic_arn" {
  type = string
}

variable "alarm_config" {
  type    = string
  default = ""
}

######################################## sfn customization ########################################

variable "sfn_event_schedule_expression" {
  type = string
}

variable "sfn_event_role_policy_arns" {
  type        = list(string)
  description = "A list of IAM Policy ARNs to attach to the generated sfn event role."
  default     = []
}

variable "sfn_type" {
  type        = string
  description = "define custom if you need to use custom sfn.json file"
  default     = "default"
}

variable "sfn_custom_definition" {
  default     = "null"
  description = ""
}

variable "sfn_custom_json_file" {
  type    = string
  default = null
}

variable "sfn_log_group_enabled" {
  type        = bool
  description = "define is it necessary or not to store sfn logs in cloudwatch log group"
  default     = true
}

variable "sfn_log_group_retention_in_days" {
  type    = number
  default = 7
}

variable "event_input" {
  type        = string
  description = "Input payload passed into the sfn by the event"
  default     = null
}


