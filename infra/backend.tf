terraform {
  backend "s3" {
    bucket       = "deployguard-tfstate-799025182804"
    key          = "deployguard/dev/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}