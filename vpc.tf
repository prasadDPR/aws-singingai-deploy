# ── VPC ───────────────────────────────────────────────────────────────────────

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "singingai-production-vpc"
  }
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.vpc.cidr_block
  description = "VPC CIDR block"
}
