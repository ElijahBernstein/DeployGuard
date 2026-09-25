provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DeployGuard"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}