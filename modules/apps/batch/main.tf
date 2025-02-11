# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create resources to run Docker batch app as Fargate Task
#
# ECS cluster should be deployed before using this module
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

provider "aws" {
  region = local.aws_region
}

locals {
  aws_region                = "ca-central-1"
  cloudwatch_log_group_name = "/company/${var.cluster_name}/${var.task_name}"
  name_prefix               = "${var.cluster_name}-${var.task_name}"
}

module "ecs_template" {
  source = "../template"

  cpu                       = var.cpu
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  memory                    = var.memory
  base_name                 = var.task_name
  cluster_name              = var.cluster_name
  app_policies              = var.app_policies
  cloudwatch_log_group_name = local.cloudwatch_log_group_name
  container_definition = templatefile("${path.module}/../container-definition.tpl", {
    cpu             = var.cpu
    image           = var.image
    memory          = var.memory
    aws_region      = local.aws_region
    cluster_name    = var.cluster_name
    awslogs_group   = local.cloudwatch_log_group_name
    container_name  = var.task_name
    container_ports = []
  })
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../tf_state/${var.env_name}/${local.aws_region}/${var.env_name}/vpc/terraform.tfstate"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLE AND POLICY FOR CLOUDWATCH EVENT TARGET
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "cloudwatch_event_target_role" {
  name               = "${local.name_prefix}-ecs-events-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_event_target_policy_document.json
}

data "aws_iam_policy_document" "cloudwatch_event_target_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ecs_events_policy" {
  name   = "${local.name_prefix}-ecs-events-policy"
  policy = data.aws_iam_policy_document.ecs_events_policy_document.json
}

data "aws_iam_policy_document" "ecs_events_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy_attachment" "ecs_events_policy_attachment" {
  name       = "${var.task_name}-ecs-events"
  policy_arn = aws_iam_policy.ecs_events_policy.arn
  roles      = [aws_iam_role.cloudwatch_event_target_role.name]
}

# --------------------------------------------------------------------------------------------------------------------
# CREATE CLOUDWATCH EVENT TARGET AND RULE FOR SCHEDULING TASK EXECUTIONS
# --------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  arn      = "arn:aws:ecs:${local.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
  rule     = aws_cloudwatch_event_rule.rule.name
  role_arn = aws_iam_role.cloudwatch_event_target_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = module.ecs_template.task_definition_arn
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      subnets         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
      security_groups = [module.ecs_template.security_group_id]
    }
  }
}

resource "aws_cloudwatch_event_rule" "rule" {
  name                = "${local.name_prefix}-cloudwatch_event_rule"
  schedule_expression = var.schedule_expression
  is_enabled          = var.is_enable_invocation_on_schedule
}
