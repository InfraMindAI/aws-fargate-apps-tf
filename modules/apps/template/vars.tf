variable "vpc_id" {
  description = "VPC id."
}

variable "cluster_name" {
  description = "Cluster name."
}

variable "base_name" {
  description = "Base part of name for resources in module."
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name."
}

variable "container_definition" {
  description = "Container definition."
}

# Service-specific parameters

variable "cpu" {
  description = "The number of CPU units to give to the Task."
}

variable "memory" {
  description = "Amount of memory to give to the Task (in Mb)."
}

variable "app_policies" {
  description = "A list of policies to grant application access to specific AWS resources."
  type        = list
}
