variable "env_name" {
  description = "Environment name. For example: prod."
}

variable "cluster_name" {
  description = "Cluster name."
}

variable "service_name" {
  description = "The name of the service."
}

# Service-specific parameters

variable "image" {
  description = "ARN of Docker image"
}

variable "cpu" {
  description = "The number of CPU units to allocate to the Task."
}

variable "memory" {
  description = "How much memory, in MB, to give to the Task."
}

variable "app_policies" {
  description = "A list of policies to grant application access to specific AWS resources."
  type        = list
  default     = []
}

variable "alb_listener_priority_offset" {
  description = "ALB listener priority offset."
}

# Health check parameters

variable "health_check_timeout" {
  description = "Health check timeout: [2-120] s."
  type        = number
  default     = 120
}

variable "health_check_interval" {
  description = "Time between health checks: [5-300] s."
  type        = number
  default     = 240
}

variable "health_check_success_http_codes" {
  description = "HTTP status codes, considered as a successful response. Format: list '200,201', or range '200-299'."
  type        = string
  default     = 200
}
