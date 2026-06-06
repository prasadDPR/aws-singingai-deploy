resource "aws_ecr_repository" "singingai_node" {
  name                 = "singingai-node"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "singingai-node"
  }
}

resource "aws_ecr_repository" "singingai_python" {
  name                 = "singingai-python"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "singingai-python"
  }
}

output "ecr_node_url" {
  value       = aws_ecr_repository.singingai_node.repository_url
  description = "ECR URL for Node.js image"
}

output "ecr_python_url" {
  value       = aws_ecr_repository.singingai_python.repository_url
  description = "ECR URL for Python ML image"
}