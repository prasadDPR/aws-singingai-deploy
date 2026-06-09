resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "public-routetable"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-routetable"
  }
}


resource "aws_route_table_association" "public-rt-association-1a" {
  subnet_id      = aws_subnet.publicsubnet1a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-rt-association-1b" {
  subnet_id      = aws_subnet.publicsubnet1b.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-rt-association-1a" {
  subnet_id      = aws_subnet.privatesubnet1a-App.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-rt-association-1b" {
  subnet_id      = aws_subnet.privatesubnet1b-App.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-rt-association-1a-DB" {
  subnet_id      = aws_subnet.privatesubnet1a-DB.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-rt-association-1b-DB" {
  subnet_id      = aws_subnet.privatesubnet1b-DB.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route" "private-route-to-nat" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

