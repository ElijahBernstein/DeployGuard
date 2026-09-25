variable "aws_region" {
  description = "AWS region where DeployGuard resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}