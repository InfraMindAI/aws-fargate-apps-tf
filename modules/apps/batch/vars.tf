variable "env_name" {
  description = "Environment name. For example: prod."
}

variable "cluster_name" {
  description = "Cluster name."
}

variable "task_name" {
  description = "The name of the Fargate task."
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
  description = "A list of policies ARNs to grant application access to specific AWS resources."
  type        = list
  default     = []
}

# Scheduling task execution

variable "is_enable_invocation_on_schedule" {
  description = "Schedule_expression will be disabled until you set this to true."
  default     = false
}

variable "schedule_expression" {
  description = "Schedule expression for running task."
}
