# Error page assets are in static/error-pages/
# Upload manually: aws s3 cp static/error-pages/ s3://<bucket-name>/ --recursive


resource "aws_s3_bucket" "error_bucket" {
  bucket = "error-pages-singingai-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "singingai-error-pages"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.error_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

locals {
  files = {
    "index.html"      = "https://raw.githubusercontent.com/prasadDPR/ERROR-PAGE/main/index.html"
    "maintenance.png" = "https://raw.githubusercontent.com/prasadDPR/ERROR-PAGE/main/maintenance.png"
    "CSS.css"         = "https://raw.githubusercontent.com/prasadDPR/ERROR-PAGE/main/CSS.css"
  }
}

resource "null_resource" "create_download_directory" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/downloaded"
  }
}

resource "null_resource" "download_files" {
  for_each = local.files

  provisioner "local-exec" {
    command = "curl -o ${path.module}/downloaded/${each.key} ${each.value}"
  }

  depends_on = [null_resource.create_download_directory]
}

resource "aws_s3_object" "uploaded_files" {
  for_each = local.files

  bucket = aws_s3_bucket.error_bucket.bucket
  key    = each.key
  source = "${path.module}/downloaded/${each.key}"
  
  content_type = lookup({
    "index.html"      = "text/html",
    "maintenance.png" = "image/png",
    "CSS.css"         = "text/css",
  }, each.key, "application/octet-stream")

  depends_on = [null_resource.download_files]
}

resource "aws_s3_bucket_policy" "public_access_policy" {
  bucket = aws_s3_bucket.error_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "Grant CloudFront access to bucket",
        Effect    = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.error_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.error_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rules = jsonencode([
    {
      Condition = {
        KeyPrefixEquals = "docs/"
      },
      Redirect = {
        ReplaceKeyPrefixWith = ""
      }
    }
  ])
}
