terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "aws-statetf-org"

    workspaces {
      name = "cicd-aws-project"
    }
  }
}

data "aws_caller_identity" "current" {}