# ---------------------------------------------------------------------------------------------------------------------
# Creates common resources for batch, service, service-lb, service-alb & service-nlb modules
# ---------------------------------------------------------------------------------------------------------------------

locals {
  name_prefix = "${var.cluster_name}-${var.base_name}"
}

resource "aws_ecs_task_definition" "task" {
  family                = local.name_prefix
  container_definitions = var.container_definition
  task_role_arn         = aws_iam_role.fargate_task_role.arn
  execution_role_arn    = aws_iam_role.fargate_task_execution_role.arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.cpu
  memory = var.memory
}

resource "aws_cloudwatch_log_group" "task_log_group" {
  name = var.cloudwatch_log_group_name
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLES FOR THE FARGATE TASK
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "fargate_task_role" {
  name               = "${local.name_prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.fargate_task_policy_document.json
}

data "aws_iam_policy_document" "fargate_task_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.app_policies)
  role       = aws_iam_role.fargate_task_role.name
  policy_arn = var.app_policies[count.index]
}

resource "aws_iam_role" "fargate_task_execution_role" {
  name               = "${local.name_prefix}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.fargate_task_policy_document.json
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM POLICY THAT ALLOWS TASK TO ACCESS Parameter Store SSM
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "access_parameter_store_and_ssm" {
  name   = "${local.name_prefix}-parameters-policy"
  policy = data.aws_iam_policy_document.access_parameter_store_and_ssm.json
}

data "aws_iam_policy_document" "access_parameter_store_and_ssm" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParametersByPath"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "access_parameter_store_and_ssm" {
  role       = aws_iam_role.fargate_task_role.name
  policy_arn = aws_iam_policy.access_parameter_store_and_ssm.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM POLICY THAT ALLOWS TASK TO WRITE LOGS AND PULL IMAGES FROM ECR
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "fargate_task_execution_policy" {
  name   = "${local.name_prefix}-task-excution-policy"
  policy = data.aws_iam_policy_document.fargate_task_execution_policy_document.json
}

data "aws_iam_policy_document" "fargate_task_execution_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy_attachment" "task_execution_policy_attachment" {
  name       = "${var.base_name}-task-execution"
  policy_arn = aws_iam_policy.fargate_task_execution_policy.arn
  roles      = [aws_iam_role.fargate_task_execution_role.name]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "fargate" {
  name   = "${local.name_prefix}-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_outbound_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.fargate.id
}
