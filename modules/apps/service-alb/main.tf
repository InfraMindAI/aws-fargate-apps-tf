# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a Fargate service and attach it to the ALB
#
# ALB and ECS cluster should be deployed before using this module
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

provider "aws" {
  region = local.aws_region
}

locals {
  aws_region     = "ca-central-1"
  container_port = 8443
  load_balancer  = data.terraform_remote_state.alb_internal.outputs
}

module "service_lb" {
  source = "../service-lb"

  cpu              = var.cpu
  port             = local.container_port
  image            = var.image
  memory           = var.memory
  env_name         = var.env_name
  app_policies     = var.app_policies
  cluster_name     = var.cluster_name
  service_name     = var.service_name
  target_group_arn = aws_lb_target_group.fargate_service.arn
}

resource "aws_alb_listener_rule" "paths_to_route_to_this_service" {
  priority     = data.terraform_remote_state.cluster.outputs.alb_listener_priority_base + var.alb_listener_priority_offset
  listener_arn = local.load_balancer.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fargate_service.arn
  }

  condition {
    path_pattern {
      values = ["/${var.service_name}*"]
    }
  }

  condition {
    host_header {
      values = ["${var.cluster_name}.${var.env_name}.example.com"]
    }
  }
}

resource "aws_security_group_rule" "allow_inbound_from_security_groups" {
  type      = "ingress"
  from_port = local.container_port
  to_port   = local.container_port
  protocol  = "tcp"

  source_security_group_id = local.load_balancer.security_group_id
  security_group_id        = module.service_lb.security_group_id
}

resource "aws_lb_target_group" "fargate_service" {
  name        = "${var.cluster_name}-${var.service_name}"
  port        = 80
  protocol    = "HTTPS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "ip"

  deregistration_delay = 300

  health_check {
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    path                = "/${var.service_name}/health"
    port                = "traffic-port"
    protocol            = "HTTPS"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = var.health_check_success_http_codes
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = false
  }
}

# --------------------------------------------------------------------------------------------------------------------
# GET VPC, ALB AND ECS CLUSTER
# --------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../tf_state/${var.env_name}/${local.aws_region}/${var.env_name}/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "alb_internal" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../tf_state/${var.env_name}/${local.aws_region}/${var.env_name}/apps/alb-internal/terraform.tfstate"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../tf_state/${var.env_name}/${local.aws_region}/${var.env_name}/apps/${var.cluster_name}/cluster/terraform.tfstate"
  }
}
