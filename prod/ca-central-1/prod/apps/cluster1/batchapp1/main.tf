terraform {
  backend "local" {
    path = "../../../../../../../tf_state/prod/ca-central-1/prod/apps/cluster1/batchapp1/terraform.tfstate"
  }
}

module "batch" {
  source = "../../../../../../modules/apps/batch"

  env_name     = "prod"
  cluster_name = "cluster1"
  task_name    = "batchapp1"

  cpu    = 1024
  memory = 2048
  image  = "ecr_image_uri"

  schedule_expression = "cron(0 23 ? * * *)"
}
