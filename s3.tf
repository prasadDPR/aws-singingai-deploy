data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "error_bucket" {
  bucket = "error-pages-singingai-${data.aws_caller_identity.current.account_id}"
  tags   = { Name = "singingai-error-pages" }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.error_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_access_policy" {
  bucket = aws_s3_bucket.error_bucket.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "CloudFrontAccess"
      Effect    = "Allow"
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.error_bucket.arn}/*"
    }]
  })
}