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

# Required for CloudFront ACM certificate
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "SingingAI"
      Environment = "production"
      ManagedBy   = "Terraform"
      Repository  = "github.com/prasadDPR/aws-singingai-deploy"
    }
  }
}