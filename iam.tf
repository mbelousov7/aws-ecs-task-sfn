data "aws_iam_policy_document" "sfn_iam" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn_iam_role" {
  name                 = local.sfn_iam_role_name
  assume_role_policy   = join("", data.aws_iam_policy_document.sfn_iam.*.json)
  permissions_boundary = var.permissions_boundary == "" ? null : var.permissions_boundary
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.sfn_iam_role_name }
  )
}

resource "aws_iam_role_policy" "sfn_role_policy" {
  name = local.sfn_iam_role_policy_name
  role = aws_iam_role.sfn_iam_role.id
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks"
        ],
        Resource = [
          "${var.task_definition_arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "${var.task_iam_role_arn}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
        ],
        Resource = [
          "arn:aws:events:${var.region}:${var.account_number}:rule/StepFunctionsGetEventsForECSTaskRule"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy" "sfn_role_policy_logs" {
  name = "${local.sfn_iam_role_policy_name}-logs"
  role = aws_iam_role.sfn_iam_role.id
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogDelivery",
          "logs:CreateLogStream",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutLogEvents",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "sfn_iam_role" {
  for_each = var.sfn_role_policy_statements
  name     = "${local.sfn_iam_role_name}-${each.key}"
  role     = aws_iam_role.sfn_iam_role.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = each.value
  })
}

locals {
  sfn_role_policy_arns_map = { for idx, val in var.sfn_role_policy_arns : idx => val }
}

resource "aws_iam_role_policy_attachment" "sfn_iam_role" {
  for_each   = local.sfn_role_policy_arns_map
  role       = aws_iam_role.sfn_iam_role.name
  policy_arn = each.value
}