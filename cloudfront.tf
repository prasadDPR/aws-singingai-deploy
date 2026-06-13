# ── CLOUDFRONT ORIGIN ACCESS IDENTITY ────────────────────────────────────────

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "singingai-cloudfront-oai"
}

# ── CLOUDFRONT DISTRIBUTION ───────────────────────────────────────────────────

resource "aws_cloudfront_distribution" "my_distribution" {

  # ── ALB ORIGIN — main application ────────────────────────────────────────
  origin {
    domain_name = aws_lb.web_alb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # ── S3 ORIGIN — maintenance page ─────────────────────────────────────────
  # Served automatically when ALB returns 502/503/504
  origin {
    domain_name = aws_s3_bucket.static_fallback.bucket_regional_domain_name
    origin_id   = "s3-maintenance"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "SingingAI CloudFront Distribution"

  # ── STATIC ASSETS CACHE BEHAVIOR ─────────────────────────────────────────
  # Cache Next.js static files for 1 day — reduces ALB load

  ordered_cache_behavior {
    path_pattern           = "/_next/static/*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
    compress    = true
  }

  # Cache public static files
  ordered_cache_behavior {
    path_pattern           = "/static/*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
    compress    = true
  }

  # ── DEFAULT CACHE BEHAVIOR ────────────────────────────────────────────────
  # API calls and dynamic pages — pass through without caching

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    compress    = true
  }

  # ── CUSTOM ERROR RESPONSES ────────────────────────────────────────────────
  # When ALB is unavailable, serve maintenance page from S3 automatically
  # No DNS switching required — CloudFront handles failover instantly

  custom_error_response {
    error_code            = 502
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 503
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 504
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  # ── SSL CERTIFICATE ───────────────────────────────────────────────────────
  # Must use us-east-1 certificate — CloudFront global service requirement

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cloudfront_cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # ── GEO RESTRICTIONS ──────────────────────────────────────────────────────

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ── ALIASES ───────────────────────────────────────────────────────────────

  aliases = ["singingai.prasadcloud.com"]

  depends_on = [aws_acm_certificate_validation.cloudfront_cert]

  tags = {
    Name = "singingai-cloudfront"
  }
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "cloudfront_dns" {
  value       = aws_cloudfront_distribution.my_distribution.domain_name
  description = "CloudFront distribution DNS name"
}

output "cloudfront_id" {
  value       = aws_cloudfront_distribution.my_distribution.id
  description = "CloudFront distribution ID"
}
