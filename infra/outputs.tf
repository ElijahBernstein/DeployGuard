output "ecr_repository_url" {
  description = "URL used to push and pull DeployGuard container images"
  value       = aws_ecr_repository.app.repository_url
}

output "vpc_id" {
  description = "ID of the DeployGuard VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets used by DeployGuard"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
  ]
}

output "application_url" {
  description = "Public URL of the DeployGuard application"
  value       = "http://${aws_lb.app.dns_name}"
}

output "github_actions_role_arn" {
  description = "IAM role assumed by GitHub Actions during deployments"
  value       = aws_iam_role.github_actions.arn
}