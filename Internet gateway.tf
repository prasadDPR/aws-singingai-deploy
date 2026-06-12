# ── INTERNET GATEWAY ─────────────────────────────────────────────────────────

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "singingai-internet-gateway"
  }
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "internet_gateway_id" {
  value       = aws_internet_gateway.ig.id
  description = "Internet Gateway ID"
}
