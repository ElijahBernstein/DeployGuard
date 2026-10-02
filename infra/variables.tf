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

variable "alert_email" {
  description = "Email address that receives DeployGuard monitoring alerts"
  type        = string
  sensitive   = true
}
