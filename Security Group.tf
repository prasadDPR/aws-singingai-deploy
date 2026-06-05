resource "aws_security_group" "public-sg" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-securitygroup"
  }

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-sg" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-securitygroup"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public-sg.id]
  }


  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "webserver-alb-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds-sg" {
  name   = "rds-security-group"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "allow_private_vm_ingress_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.private-sg.id
  security_group_id        = aws_security_group.rds-sg.id
}




