output "ecr_repository_url" {
  description = "URL used to push and pull DeployGuard container images"
  value       = aws_ecr_repository.app.repository_url
}