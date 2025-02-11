variable "env_name" {
  description = "Environment name. For example: prod."
}

variable "cluster_name" {
  description = "Cluster name."
}

variable "service_name" {
  description = "The name of the Fargate service."
}

# Service-specific parameters

variable "image" {
  description = "ARN of Docker image"
}

variable "cpu" {
  description = "The number of CPU units to give to the Task."
}

variable "memory" {
  description = "The amount of memory to give to the Task (in MB)."
}

variable "app_policies" {
  description = "A list of policies to grant application access to specific AWS resources."
  type        = list
  default     = []
}

variable "container_port" {
  type        = number
  description = "The port on the container to associate with the Load Balancer."
}

variable "vpc_subnet_cidr_blocks" {
  description = "The list of CIDR blocks of the VPC that will have access to this ECS service."
  type        = list
  default     = []
}


# Health check parameters

variable "health_check_interval" {
  description = "Time between health checks."
  type        = number
  default     = 30
}
