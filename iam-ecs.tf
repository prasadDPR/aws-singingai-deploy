# ── ECS TASK EXECUTION ROLE ───────────────────────────────────────────────────
# Used by ECS agent to pull images from ECR and fetch secrets from Secrets Manager

resource "aws_iam_role" "ecs_execution_role" {
  name        = "singingai-ecs-execution-role"
  description = "ECS task execution role for pulling images and fetching secrets"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = {
    Name = "singingai-ecs-execution-role"
  }
}

# AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow ECS to fetch secrets from Secrets Manager
resource "aws_iam_role_policy" "ecs_secrets_policy" {
  name = "singingai-secrets-access"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AllowSecretsManagerAccess"
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [aws_secretsmanager_secret.singingai_secrets.arn]
    }]
  })
}

# ── ECS TASK ROLE ─────────────────────────────────────────────────────────────
# Used by the application code running inside containers

resource "aws_iam_role" "ecs_task_role" {
  name        = "singingai-ecs-task-role"
  description = "ECS task role for application code permissions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })

  tags = {
    Name = "singingai-ecs-task-role"
  }
}

# Allow ECS tasks to access only the SingingAI S3 bucket
resource "aws_iam_role_policy" "ecs_task_s3_policy" {
  name = "singingai-s3-access"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowS3BucketAccess"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.error_bucket.arn]
      },
      {
        Sid      = "AllowS3ObjectAccess"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = ["${aws_s3_bucket.error_bucket.arn}/*"]
      }
    ]
  })
}

# Allow ECS tasks to write CloudWatch logs
resource "aws_iam_role_policy" "ecs_task_logs_policy" {
  name = "singingai-cloudwatch-logs"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudWatchLogs"
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = [
        "arn:aws:logs:eu-west-2:*:log-group:/ecs/singingai-*"
      ]
    }]
  })
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "ecs_execution_role_arn" {
  value       = aws_iam_role.ecs_execution_role.arn
  description = "ECS execution role ARN"
}

output "ecs_task_role_arn" {
  value       = aws_iam_role.ecs_task_role.arn
  description = "ECS task role ARN"
}
