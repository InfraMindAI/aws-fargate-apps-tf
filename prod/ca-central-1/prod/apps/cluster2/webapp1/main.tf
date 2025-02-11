terraform {
  backend "local" {
    path = "../../../../../../../tf_state/prod/ca-central-1/prod/apps/cluster2/webapp1/terraform.tfstate"
  }
}

module "service-alb" {
  source = "../../../../../../modules/apps/service-alb"

  env_name     = "prod"
  cluster_name = "cluster2"
  service_name = "webapp1"

  cpu    = 1024
  memory = 2048
  image  = "ecr_image_uri"

  alb_listener_priority_offset = 0
}
