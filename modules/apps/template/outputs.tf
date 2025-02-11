output "task_definition_arn" {
  value = aws_ecs_task_definition.task.arn
}

output "security_group_id" {
  value = aws_security_group.fargate.id
}