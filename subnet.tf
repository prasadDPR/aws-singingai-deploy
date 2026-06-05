resource "aws_subnet" "publicsubnet1a" {
  availability_zone       = "eu-west-2a"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "prod-publicsub1a" }
}

resource "aws_subnet" "privatesubnet1a-App" {
  availability_zone = "eu-west-2a"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  tags = { Name = "prod-privatesub1a-App" }
}

resource "aws_subnet" "privatesubnet1a-DB" {
  availability_zone = "eu-west-2a"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  tags = { Name = "prod-privatesub1a-DB" }
}

resource "aws_subnet" "publicsubnet1b" {
  availability_zone       = "eu-west-2b"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "prod-publicsub1b" }
}

resource "aws_subnet" "privatesubnet1b-App" {
  availability_zone = "eu-west-2b"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  tags = { Name = "prod-privatesub1b-App" }
}

resource "aws_subnet" "privatesubnet1b-DB" {
  availability_zone = "eu-west-2b"
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.6.0/24"
  tags = { Name = "prod-privatesub1b-DB" }
}