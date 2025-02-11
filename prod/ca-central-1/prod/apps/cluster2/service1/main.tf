terraform {
  backend "local" {
    path = "../../../../../../../tf_state/prod/ca-central-1/prod/apps/cluster2/service1/terraform.tfstate"
  }
}

module "service" {
  source = "../../../../../../modules/apps/service"

  env_name     = "prod"
  cluster_name = "cluster2"
  service_name = "service1"

  cpu    = 1024
  memory = 2048
  image  = "ecr_image_uri"
}
