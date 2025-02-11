# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a Fargate service
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

provider "aws" {
  region = local.aws_region
}

locals {
  aws_region                = "ca-central-1"
  cloudwatch_log_group_name = "/company/${var.cluster_name}/${var.service_name}"
}

module "ecs_template" {
  source = "../template"

  cpu                       = var.cpu
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  memory                    = var.memory
  base_name                 = var.service_name
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
    container_name  = var.service_name
    container_ports = []
  })
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = "arn:aws:ecs:${local.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
  task_definition = module.ecs_template.task_definition_arn
  launch_type     = "FARGATE"

  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets          = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_groups  = [module.ecs_template.security_group_id]
    assign_public_ip = false
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../tf_state/${var.env_name}/${local.aws_region}/${var.env_name}/vpc/terraform.tfstate"
  }
}
