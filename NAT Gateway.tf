# ── ELASTIC IP FOR NAT GATEWAY ───────────────────────────────────────────────

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "singingai-nat-eip"
  }

  depends_on = [aws_internet_gateway.ig]
}

# ── NAT GATEWAY ───────────────────────────────────────────────────────────────

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.publicsubnet1a.id

  tags = {
    Name = "singingai-nat-gateway"
  }

  depends_on = [aws_internet_gateway.ig]
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat_gw.id
  description = "NAT Gateway ID"
}

output "nat_eip" {
  value       = aws_eip.nat_eip.public_ip
  description = "NAT Gateway public IP address"
}
