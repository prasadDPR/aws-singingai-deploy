resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Name = "prod-elastic-ip"
  }
}