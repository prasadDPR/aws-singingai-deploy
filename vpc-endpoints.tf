# ── VPC ENDPOINTS ─────────────────────────────────────────────────────────────
# Keeps AWS service traffic inside private network
# Eliminates NAT Gateway data transfer costs for internal AWS services
# Saves ~$50/month compared to routing through NAT Gateway

# ── SECURITY GROUP FOR VPC ENDPOINTS ─────────────────────────────────────────

resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "singingai-vpc-endpoints-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTPS from ECS tasks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "singingai-vpc-endpoints-sg"
  }
}

# ── ECR API ENDPOINT ──────────────────────────────────────────────────────────
# Handles ECR API calls (authentication, image metadata)

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.eu-west-2.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [
    aws_subnet.privatesubnet1a-App.id,
    aws_subnet.privatesubnet1b-App.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "singingai-ecr-api-endpoint"
  }
}

# ── ECR DKR ENDPOINT ──────────────────────────────────────────────────────────
# Handles actual Docker image layer pulls from ECR

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.eu-west-2.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [
    aws_subnet.privatesubnet1a-App.id,
    aws_subnet.privatesubnet1b-App.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "singingai-ecr-dkr-endpoint"
  }
}

# ── S3 GATEWAY ENDPOINT ───────────────────────────────────────────────────────
# ECR stores image layers in S3 — this keeps that traffic inside AWS network
# Gateway endpoints are FREE — no hourly charge

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.eu-west-2.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private-rt.id]

  tags = {
    Name = "singingai-s3-gateway-endpoint"
  }
}

# ── SECRETS MANAGER ENDPOINT ──────────────────────────────────────────────────
# ECS fetches credentials from Secrets Manager on startup
# Keeps credential traffic inside private network — security improvement

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.eu-west-2.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [
    aws_subnet.privatesubnet1a-App.id,
    aws_subnet.privatesubnet1b-App.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "singingai-secrets-manager-endpoint"
  }
}

# ── CLOUDWATCH LOGS ENDPOINT ──────────────────────────────────────────────────
# ECS ships logs to CloudWatch — keeps log traffic inside private network

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.eu-west-2.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [
    aws_subnet.privatesubnet1a-App.id,
    aws_subnet.privatesubnet1b-App.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoints_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "singingai-cloudwatch-logs-endpoint"
  }
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "ecr_api_endpoint_id" {
  value       = aws_vpc_endpoint.ecr_api.id
  description = "ECR API VPC Endpoint ID"
}

output "ecr_dkr_endpoint_id" {
  value       = aws_vpc_endpoint.ecr_dkr.id
  description = "ECR DKR VPC Endpoint ID"
}

output "s3_endpoint_id" {
  value       = aws_vpc_endpoint.s3.id
  description = "S3 Gateway VPC Endpoint ID"
}
