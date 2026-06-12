# ── PUBLIC SUBNETS ────────────────────────────────────────────────────────────

resource "aws_subnet" "publicsubnet1a" {
  availability_zone       = "eu-west-2a"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "prod-public-subnet-2a"
    Tier = "Public"
  }
}

resource "aws_subnet" "publicsubnet1b" {
  availability_zone       = "eu-west-2b"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "prod-public-subnet-2b"
    Tier = "Public"
  }
}

# ── PRIVATE APP SUBNETS ───────────────────────────────────────────────────────

resource "aws_subnet" "privatesubnet1a-App" {
  availability_zone = "eu-west-2a"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "prod-private-app-subnet-2a"
    Tier = "Private"
  }
}

resource "aws_subnet" "privatesubnet1b-App" {
  availability_zone = "eu-west-2b"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"

  tags = {
    Name = "prod-private-app-subnet-2b"
    Tier = "Private"
  }
}

# ── PRIVATE DB SUBNETS ────────────────────────────────────────────────────────

resource "aws_subnet" "privatesubnet1a-DB" {
  availability_zone = "eu-west-2a"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "prod-private-db-subnet-2a"
    Tier = "Database"
  }
}

resource "aws_subnet" "privatesubnet1b-DB" {
  availability_zone = "eu-west-2b"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.6.0/24"

  tags = {
    Name = "prod-private-db-subnet-2b"
    Tier = "Database"
  }
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "private_subnet_1a_id" {
  value       = aws_subnet.privatesubnet1a-App.id
  description = "Private app subnet 2a ID - used for ECS migration tasks"
}

output "private_subnet_1b_id" {
  value       = aws_subnet.privatesubnet1b-App.id
  description = "Private app subnet 2b ID"
}

output "public_subnet_1a_id" {
  value       = aws_subnet.publicsubnet1a.id
  description = "Public subnet 2a ID"
}

output "public_subnet_1b_id" {
  value       = aws_subnet.publicsubnet1b.id
  description = "Public subnet 2b ID"
}
