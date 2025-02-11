variable "env_name" {
  description = "Environment name. For example: prod."
}

variable "cluster_name" {
  description = "Cluster name."
}

variable "service_name" {
  description = "The name of the Fargate service to run."
}

variable "target_group_arn" {
  description = "Target group ARN."
}

# Service-specific parameters

variable "image" {
  description = "ARN of Docker image"
}

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

variable "port" {
  description = "Port."
}


