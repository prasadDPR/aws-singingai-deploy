# ── SECRETS MANAGER ──────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret" "singingai_secrets" {
  name                    = "singingai/production-v2"
  description             = "SingingAI production credentials and configuration"
  recovery_window_in_days = 0

  tags = {
    Name        = "singingai-production-secrets"
    Application = "SingingAI"
  }
}

# ── SECRET VALUES ─────────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret_version" "singingai_secrets_version" {
  secret_id = aws_secretsmanager_secret.singingai_secrets.id

  secret_string = jsonencode({
    DATABASE_URL         = "postgresql://singingai_admin:${var.db_password}@${aws_db_instance.rds-db.address}:5432/singingai"
    GROQ_API_KEY         = var.groq_api_key
    GOOGLE_CLIENT_ID     = var.google_client_id
    GOOGLE_CLIENT_SECRET = var.google_client_secret
    SESSION_SECRET       = var.session_secret
    PYTHON_BACKEND_URL   = "http://singingai-python.singingai.local:8000"
    NEXTAUTH_URL         = "https://singingai.prasadcloud.com"
  })
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "secret_arn" {
  value       = aws_secretsmanager_secret.singingai_secrets.arn
  description = "ARN of SingingAI secrets — used by ECS task definitions"
}
