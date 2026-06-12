# ── BASTION / PUBLIC SECURITY GROUP ──────────────────────────────────────────

resource "aws_security_group" "public-sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host - SSH access only"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from admin IP only"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# ── ALB SECURITY GROUP ────────────────────────────────────────────────────────

resource "aws_security_group" "alb_sg" {
  name        = "singingai-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound to ECS tasks"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "singingai-alb-sg"
  }
}

# ── RDS SECURITY GROUP ────────────────────────────────────────────────────────

resource "aws_security_group" "rds-sg" {
  name        = "rds-security-group"
  description = "Security group for RDS PostgreSQL - private access only"
  vpc_id      = aws_vpc.vpc.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-securitygroup"
  }
}

# PostgreSQL access from ECS tasks
resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_sg.id
  security_group_id        = aws_security_group.rds-sg.id
  description              = "Allow ECS tasks to connect to PostgreSQL"
}

# PostgreSQL access from bastion host for admin queries
resource "aws_security_group_rule" "allow_bastion_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public-sg.id
  security_group_id        = aws_security_group.rds-sg.id
  description              = "Allow bastion host to connect to PostgreSQL for admin queries"
}
