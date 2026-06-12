# ── S3 BUCKET FOR ERROR PAGES ─────────────────────────────────────────────────

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "error_bucket" {
  bucket = "singingai-assets-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "singingai-assets"
    Purpose = "Static assets and error pages for CloudFront"
  }
}

# ── VERSIONING ────────────────────────────────────────────────────────────────

resource "aws_s3_bucket_versioning" "error_bucket_versioning" {
  bucket = aws_s3_bucket.error_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ── ENCRYPTION ────────────────────────────────────────────────────────────────

resource "aws_s3_bucket_server_side_encryption_configuration" "error_bucket_encryption" {
  bucket = aws_s3_bucket.error_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ── PUBLIC ACCESS BLOCK ───────────────────────────────────────────────────────

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.error_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ── BUCKET POLICY ─────────────────────────────────────────────────────────────

resource "aws_s3_bucket_policy" "public_access_policy" {
  bucket = aws_s3_bucket.error_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "CloudFrontAccess"
      Effect = "Allow"
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.error_bucket.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access_block]
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "s3_bucket_name" {
  value       = aws_s3_bucket.error_bucket.bucket
  description = "S3 bucket name for assets"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.error_bucket.arn
  description = "S3 bucket ARN"
}
