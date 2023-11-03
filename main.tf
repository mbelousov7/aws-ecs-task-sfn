locals {

  name_prefix = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}"

  sfn_iam_role_name        = "${local.name_prefix}-sfn-role-${var.labels.env}"
  sfn_iam_role_policy_name = "${local.name_prefix}-sfn-role-policy-${var.labels.env}"

  sfn_name              = "${local.name_prefix}-sfn-${var.labels.env}"
  sfn_alarm_name        = "${local.name_prefix}-sfn-alarm-${var.labels.env}"
  sfn_alarm_metric_name = "${var.labels.stack}-retry-sfn-alarm"
  sfn_alarm_namespace   = "System/${local.name_prefix}-sfn-alarm/${var.labels.env}"

  sfn_event_name        = "${local.name_prefix}-sfn-event-${var.labels.env}"
  sfn_event_role_name   = "${local.name_prefix}-sfn-event-role-${var.labels.env}"
  sfn_event_policy_name = "${local.name_prefix}-sfn-event-policy-${var.labels.env}"

  ecs_cluster_name = var.ecs_cluster_name == "default" ? (
    "${local.name_prefix}-cl-${var.region}-${var.labels.env}"
  ) : var.ecs_cluster_name

  ecs_cluster_arn = var.ecs_cluster_new == true ? join("", aws_ecs_cluster.ecs_cluster.*.arn) : var.ecs_cluster_arn

  sfn_json_file = var.sfn_custom_json_file == null ? "${path.module}/files/sfn.asl.json" : var.sfn_custom_json_file

  step_function_arn = var.sfn_type == "default" ? join("", aws_sfn_state_machine.step_function_default.*.arn) : join("", aws_sfn_state_machine.step_function_custom.*.arn)

  step_function_log_group_count = var.sfn_log_group_enabled == true ? 1 : 0
  sfn_log_group__name           = "/aws/vendedlogs/states/${local.sfn_name}-logs"
}
resource "aws_ecs_cluster" "ecs_cluster" {
  count = var.ecs_cluster_new == true ? 1 : 0
  name  = local.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = var.aws_ecs_cluster_containerInsights
  }
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.ecs_cluster_name }
  )
}

# wait 30s for IAM policy init
resource "time_sleep" "wait_30_seconds" {
  depends_on      = [aws_iam_role.sfn_iam_role, aws_iam_role_policy.sfn_role_policy, aws_iam_role_policy.sfn_role_policy_logs]
  create_duration = "15s"
  triggers = {
    logs = join("", aws_iam_role_policy.sfn_role_policy_logs.*.policy)
  }
}


resource "aws_sfn_state_machine" "step_function_default" {
  count    = var.sfn_type == "default" ? 1 : 0
  name     = local.sfn_name
  role_arn = aws_iam_role.sfn_iam_role.arn
  depends_on = [
    aws_iam_role.sfn_iam_role, aws_iam_role_policy.sfn_role_policy, aws_iam_role_policy.sfn_role_policy_logs,
    aws_cloudwatch_log_group.default,
    time_sleep.wait_30_seconds
  ]

  definition = templatefile(local.sfn_json_file,
    {
      # configuration required to execute the task itself.
      # having these here gives visbility of dependencies to the StepFunction
      alarm_topic_arn   = var.alarm_topic_arn
      alarm_dscription  = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | ${var.labels.component} ) Fargate task failed to invoke ${var.alarm_config}"
      alarm_name        = local.sfn_alarm_name
      alarm_metric_name = local.sfn_alarm_metric_name
      alarm_namespace   = local.sfn_alarm_namespace
      retry_config      = var.retry_config
      environment       = var.environment_type,
      aws_region_name   = var.region_description,
      aws_region_code   = var.region,
      asset_id          = var.asset_id,

      # configuration needed to spin up the Fargate task
      cluster_arn         = local.ecs_cluster_arn
      task_definition_arn = var.task_definition_arn
      security_group_id   = var.task_security_group_id
      subnet_ids          = var.task_subnet_ids
    }
  )

  dynamic "logging_configuration" {
    for_each = var.sfn_log_group_enabled == true ? [true] : []

    content {
      log_destination        = "${join("", aws_cloudwatch_log_group.default.*.arn)}:*"
      include_execution_data = true
      level                  = "ALL"
    }
  }

  tags = merge(
    var.labels,
    var.tags,
    { Name = local.sfn_name }
  )
}

resource "aws_sfn_state_machine" "step_function_custom" {
  count    = var.sfn_type == "custom" ? 1 : 0
  name     = local.sfn_name
  role_arn = aws_iam_role.sfn_iam_role.arn
  depends_on = [
    aws_iam_role.sfn_iam_role, aws_iam_role_policy.sfn_role_policy, aws_iam_role_policy.sfn_role_policy_logs,
    aws_cloudwatch_log_group.default,
    time_sleep.wait_30_seconds
  ]

  definition = templatefile(local.sfn_json_file,

    merge(
      {
        # configuration required to execute the task itself.
        # having these here gives visbility of dependencies to the StepFunction
        alarm_topic_arn   = var.alarm_topic_arn
        alarm_dscription  = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | ${var.labels.component} ) Fargate task failed to invoke ${var.alarm_config}"
        alarm_name        = local.sfn_alarm_name
        alarm_metric_name = local.sfn_alarm_metric_name
        alarm_namespace   = local.sfn_alarm_namespace
        environment       = var.environment_type,
        aws_region_name   = var.region_description,
        aws_region_code   = var.region,
        asset_id          = var.asset_id,

        # configuration needed to spin up the Fargate task
        cluster_arn         = local.ecs_cluster_arn
        task_definition_arn = var.task_definition_arn
        security_group_id   = var.task_security_group_id
        subnet_ids          = var.task_subnet_ids
      },
      var.sfn_custom_definition
    )

  )

  dynamic "logging_configuration" {
    for_each = var.sfn_log_group_enabled == true ? [true] : []

    content {
      log_destination        = "${join("", aws_cloudwatch_log_group.default.*.arn)}:*"
      include_execution_data = true
      level                  = "ALL"
    }
  }

  tags = merge(
    var.labels,
    var.tags,
    { Name = local.sfn_name }
  )


}

# State machine Log groups

resource "aws_cloudwatch_log_group" "default" {
  count             = local.step_function_log_group_count
  name              = local.sfn_log_group__name
  retention_in_days = var.sfn_log_group_retention_in_days
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.sfn_log_group__name }
  )
}




