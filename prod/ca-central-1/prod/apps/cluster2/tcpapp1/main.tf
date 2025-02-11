terraform {
  backend "local" {
    path = "../../../../../../../tf_state/prod/ca-central-1/prod/apps/cluster2/tcpapp1/terraform.tfstate"
  }
}

module "service-nlb" {
  source = "../../../../../../modules/apps/service-nlb"

  env_name     = "prod"
  cluster_name = "cluster2"
  service_name = "tcpapp1"

  cpu    = 1024
  memory = 2048
  image  = "ecr_image_uri"

  container_port = 4445
}
