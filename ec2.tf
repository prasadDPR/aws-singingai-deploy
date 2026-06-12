# ── BASTION HOST ──────────────────────────────────────────────────────────────
# Single t3.nano instance for administrative access to private subnet resources
# Used for database queries and troubleshooting via SSH tunneling

resource "aws_instance" "bastion" {
  ami                    = "ami-0dbec48abfe298cab"
  instance_type          = "t3.nano"
  key_name               = "singingai-key"
  subnet_id              = aws_subnet.publicsubnet1a.id
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  availability_zone      = "eu-west-2a"

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "singingai-bastion"
    Purpose = "Administrative access to private subnet resources"
  }
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Bastion host public IP for SSH access"
}
