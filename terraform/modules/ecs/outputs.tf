output "ecs_cluster_id" {
  value = aws_ecs_cluster.memos_cluster.id
}

output "ecs_service_id" {
  value = aws_ecs_service.memos_service.id
}
