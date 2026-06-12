# ── ECR REPOSITORIES ─────────────────────────────────────────────────────────

resource "aws_ecr_repository" "singingai_node" {
  name                 = "singingai-node"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "singingai-node"
    Application = "SingingAI"
    Service     = "nodejs-frontend"
  }
}

resource "aws_ecr_repository" "singingai_python" {
  name                 = "singingai-python"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "singingai-python"
    Application = "SingingAI"
    Service     = "python-ml-backend"
  }
}

# ── LIFECYCLE POLICIES ────────────────────────────────────────────────────────
# Keep only last 5 images to control storage costs

resource "aws_ecr_lifecycle_policy" "node_lifecycle" {
  repository = aws_ecr_repository.singingai_node.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "python_lifecycle" {
  repository = aws_ecr_repository.singingai_python.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "ecr_node_url" {
  value       = aws_ecr_repository.singingai_node.repository_url
  description = "ECR URL for Node.js image — used in GitHub Actions workflow"
}

output "ecr_python_url" {
  value       = aws_ecr_repository.singingai_python.repository_url
  description = "ECR URL for Python ML image — used in GitHub Actions workflow"
}
