terraform {
  backend "s3" {
    bucket       = var.state_bucket
    key          = "tofu.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
