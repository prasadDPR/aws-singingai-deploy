resource "aws_s3_bucket" "static_fallback" {
  bucket = "singingai-fallback-prasadcloud"

  tags = {
    Name = "singingai-static-fallback"
  }
}

resource "aws_s3_bucket_website_configuration" "static_fallback" {
  bucket = aws_s3_bucket.static_fallback.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "static_fallback" {
  bucket                  = aws_s3_bucket.static_fallback.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static_fallback" {
  bucket = aws_s3_bucket.static_fallback.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.static_fallback.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.static_fallback]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_fallback.id
  key          = "index.html"
  content_type = "text/html"
  content      = <<-EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SingingAI - AI Vocal Coaching Platform</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: #0a0a0a;
      color: #ffffff;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      text-align: center;
      max-width: 600px;
      padding: 40px 20px;
    }
    .icon {
      font-size: 64px;
      margin-bottom: 16px;
    }
    h1 {
      font-size: 48px;
      color: #3b82f6;
      margin-bottom: 8px;
      font-weight: 700;
    }
    .subtitle {
      font-size: 18px;
      color: #94a3b8;
      margin-bottom: 40px;
    }
    .status {
      background: #1e293b;
      border: 1px solid #334155;
      border-radius: 12px;
      padding: 30px;
      margin-bottom: 30px;
    }
    .status h2 {
      color: #f59e0b;
      margin-bottom: 12px;
      font-size: 20px;
    }
    .status p {
      color: #94a3b8;
      line-height: 1.8;
      font-size: 15px;
    }
    .features {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
      margin-bottom: 10px;
    }
    .feature {
      background: #1e293b;
      border: 1px solid #1e293b;
      border-radius: 8px;
      padding: 14px;
      font-size: 14px;
      color: #94a3b8;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">&#127908;</div>
    <h1>SingingAI</h1>
    <p class="subtitle">AI-Powered Vocal Coaching Platform</p>

    <div class="status">
      <h2>&#128295; Scheduled Maintenance</h2>
      <p>
        SingingAI is currently undergoing scheduled maintenance.<br>
        We will be back shortly.<br><br>
        Thank you for your patience.
      </p>
    </div>

    <div class="features">
      <div class="feature">&#127925; Pitch Accuracy Analysis</div>
      <div class="feature">&#128168; Breath Control Detection</div>
      <div class="feature">&#127754; Vibrato Quality Scoring</div>
      <div class="feature">&#129302; AI Coaching Feedback</div>
      <div class="feature">&#128202; Progress Tracking</div>
      <div class="feature">&#127919; Personalised Learning Paths</div>
    </div>
  </div>
</body>
</html>
  EOF
}

output "fallback_bucket_url" {
  value       = "http://${aws_s3_bucket.static_fallback.bucket}.s3-website.eu-west-2.amazonaws.com"
  description = "S3 static fallback page URL"
}
