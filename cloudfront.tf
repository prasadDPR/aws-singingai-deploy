resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "cloudfront-s3-origin_access_identity"
}

resource "aws_cloudfront_distribution" "my_distribution" {
  origin_group {
    origin_id = "primary"

    failover_criteria {
      status_codes = [403, 400, 416, 404, 500, 502, 503, 504]
    }

    member {
      origin_id = "local.alb_origin_id"
    }

    member {
      origin_id = "local.s3_origin_id"
    }
  }

  origin {
    domain_name = aws_lb.web_alb.dns_name
    origin_id   = "local.alb_origin_id"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.error_bucket.bucket_regional_domain_name
    origin_id   = "local.s3_origin_id"

    s3_origin_config {
     origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
  }
 }

  enabled             = true
  comment             = "My CloudFront Distribution"


  default_cache_behavior {
    target_origin_id       = "primary"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    default_ttl = 36
    max_ttl     = 360
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

output "cloudfront_dns" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
}

