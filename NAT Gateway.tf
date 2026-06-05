resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.publicsubnet1a.id
  tags = {
    Name = "prod-nat-gateway"
  }
  depends_on = [aws_internet_gateway.ig]
}