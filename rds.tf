resource "aws_db_subnet_group" "subnet-group" {
  name       = "production-db-subnet-group"
  subnet_ids = [
    aws_subnet.privatesubnet1a-DB.id,
    aws_subnet.privatesubnet1b-DB.id
  ]
}

resource "aws_db_instance" "rds-db" {
  skip_final_snapshot       = true
  delete_automated_backups  = true
  deletion_protection       = false
  identifier             = "singingai-production-db"
  allocated_storage      = 20
  db_name                = "singingai"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = "singingai_admin"
  password               = var.db_password
  publicly_accessible    = false
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.subnet-group.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]

  tags = {
    Name = "singingai-production-db"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.rds-db.endpoint
}