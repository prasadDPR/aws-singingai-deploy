# Bastion host for private subnet access
resource "aws_instance" "bastion" {
  ami               = "ami-0dbec48abfe298cab"
  instance_type     = "t3.nano"
  key_name          = "singingai-key"
  subnet_id         = aws_subnet.publicsubnet1a.id
  vpc_security_group_ids = [aws_security_group.public-sg.id]
  availability_zone = "eu-west-2a"

  tags = {
    Name    = "bastion-host"
    Purpose = "Private subnet access for database queries"
  }
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Bastion host IP for SSH tunneling"
}