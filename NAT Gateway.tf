resource "aws_eip" "nat_eip" {
  domain = "vpc"
  
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.publicsubnet1a.id

  tags = {
    Name = "production-nat-gateway"
  }

  depends_on = [aws_internet_gateway.ig]
}