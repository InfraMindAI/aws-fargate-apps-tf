# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create a Fargate service and attach it to the NLB
#
# ALB and ECS cluster should be deployed before using this module
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

provider "aws" {
  region = local.aws_region
}

locals {
  aws_region = "ca-central-1"
}

module "service_lb" {
  source = "../service-lb"

  cpu              = var.cpu
  port             = var.container_port
  image            = var.image
  memory           = var.memory
  env_name         = var.env_name
  app_policies     = var.app_policies
  cluster_name     = var.cluster_name
  service_name     = var.service_name
  target_group_arn = aws_lb_target_group.fargate_service.arn
}

resource "aws_lb_listener" "nlb_listeners" {
  port              = var.container_port
  load_balancer_arn = data.terraform_remote_state.nlb_internal.outputs.arn
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fargate_service.arn
  }
}

resource "aws_security_group_rule" "allow_inbound_from_cidr_blocks" {
  count = signum(length(var.vpc_subnet_cidr_blocks))

  type      = "ingress"
  from_port = var.container_port
  to_port   = var.container_port
  protocol  = "tcp"

  cidr_blocks       = var.vpc_subnet_cidr_blocks
  security_group_id = module.service_lb.security_group_id
}

resource "aws_lb_target_group" "fargate_service" {
  name        = "${var.cluster_name}-${var.service_name}"
  port        = 80
  protocol    = "TCP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "ip"

  deregistration_delay = 300

  health_check {
    interval            = var.health_check_interval
    port                = "traffic-port"
    protocol            = "TCP"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  stickiness {
    type    = "source_ip"
    enabled = false
  }
}

# --------------------------------------------------------------------------------------------------------------------
# GET VPC AND NLB
# --------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../tf_state/${var.env_name}/${local.aws_region}/${var.env_name}/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "nlb_internal" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../tf_state/${var.env_name}/${local.aws_region}/${var.env_name}/apps/nlb-internal/terraform.tfstate"
  }
}
