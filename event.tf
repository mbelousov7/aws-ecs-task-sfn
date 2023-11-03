resource "aws_cloudwatch_event_rule" "step_function_event" {
  name                = local.sfn_event_name
  description         = "Runs Fargate task ${local.sfn_event_name}"
  schedule_expression = var.sfn_event_schedule_expression
}

resource "aws_cloudwatch_event_target" "step_function_event" {
  rule      = aws_cloudwatch_event_rule.step_function_event.name
  target_id = local.sfn_event_name
  arn       = local.step_function_arn
  role_arn  = aws_iam_role.step_function_event_role.arn
  input     = var.event_input
}

resource "aws_iam_role" "step_function_event_role" {
  name = local.sfn_event_role_name

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Principal = {
            Service = [
              "states.amazonaws.com",
              "events.amazonaws.com"
            ]
          }
          Effect = "Allow"
        }
      ]
    }
  )
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.sfn_event_role_name }
  )

}

resource "aws_iam_role_policy_attachment" "step_function_event_iam_role" {
  for_each   = toset(var.sfn_event_role_policy_arns)
  role       = aws_iam_role.step_function_event_role.name
  policy_arn = each.key
}

resource "aws_iam_role_policy" "sfn_event_role_policy" {
  name = local.sfn_event_policy_name
  role = aws_iam_role.step_function_event_role.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "states:StartExecution"
          ],
          Resource = [
            local.step_function_arn
          ]
        }
      ]
    }
  )
}
