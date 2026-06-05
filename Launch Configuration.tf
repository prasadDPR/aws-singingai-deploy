resource "aws_launch_template" "private_lt" {
  name_prefix   = "private-lt-"
  image_id      = "ami-0150189e4c09ffab5"
  instance_type = "t2.micro"
  key_name      = "singingai-key"

  network_interfaces {
    security_groups = [aws_security_group.private-sg.id]
  }

  tags = {
    Name = "private-launch-template"
  }
}