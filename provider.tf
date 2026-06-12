# ── AWS PROVIDER ─────────────────────────────────────────────────────────────

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Project     = "SingingAI"
      Environment = "production"
      ManagedBy   = "Terraform"
      Repository  = "github.com/prasadDPR/aws-singingai-deploy"
    }
  }
}
