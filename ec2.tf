resource "aws_instance" "pubic-server-1" {
  tags = {
    "Name" = "public-server1"
  }
  ami               = "ami-0150189e4c09ffab5"
  instance_type     = "t2.micro"
  key_name          = "singingai-key"
  subnet_id         = aws_subnet.publicsubnet1a.id
  security_groups   = [aws_security_group.public-sg.id]
  availability_zone = "eu-west-2a"
}

resource "aws_instance" "public-server-2" {
  tags = {
    "Name" = "public-server2"
  }
  ami               = "ami-0150189e4c09ffab5"
  instance_type     = "t2.micro"
  key_name          = "singingai-key"
  subnet_id         = aws_subnet.publicsubnet1b.id
  security_groups   = [aws_security_group.public-sg.id]
  availability_zone = "eu-west-2b"
}
