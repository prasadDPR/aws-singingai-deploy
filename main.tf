terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "aws-statetf-org"

    workspaces {
      name = "cicd-aws-project"
    }
  }
}