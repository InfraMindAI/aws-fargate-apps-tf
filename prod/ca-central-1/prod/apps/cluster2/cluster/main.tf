terraform {
  backend "local" {
    path = "../../../../../../../tf_state/prod/ca-central-1/prod/apps/cluster2/cluster/terraform.tfstate"
  }
}

module "cluster" {
  source = "../../../../../../modules/apps/cluster"

  name                       = "cluster2"
  alb_listener_priority_base = 100
}
