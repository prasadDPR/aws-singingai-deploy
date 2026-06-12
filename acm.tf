# ── ACM CERTIFICATE (eu-west-2) ───────────────────────────────────────────────
# Used by ALB HTTPS listener

resource "aws_acm_certificate" "main" {
  domain_name               = "*.prasadcloud.com"
  subject_alternative_names = ["prasadcloud.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "prasadcloud-wildcard-cert-alb"
    Purpose = "ALB HTTPS listener"
  }
}

# ── DNS VALIDATION RECORDS ────────────────────────────────────────────────────

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]

  timeouts {
    create = "10m"
  }
}

# ── ACM CERTIFICATE (us-east-1) ───────────────────────────────────────────────
# CloudFront requires certificates in us-east-1 — AWS global service requirement

resource "aws_acm_certificate" "cloudfront_cert" {
  provider                  = aws.us_east_1
  domain_name               = "*.prasadcloud.com"
  subject_alternative_names = ["prasadcloud.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "prasadcloud-wildcard-cert-cloudfront"
    Purpose = "CloudFront distribution"
  }
}

resource "aws_acm_certificate_validation" "cloudfront_cert" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]

  timeouts {
    create = "10m"
  }
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "acm_certificate_arn" {
  value       = aws_acm_certificate_validation.main.certificate_arn
  description = "ACM certificate ARN for ALB (eu-west-2)"
}

output "cloudfront_certificate_arn" {
  value       = aws_acm_certificate_validation.cloudfront_cert.certificate_arn
  description = "ACM certificate ARN for CloudFront (us-east-1)"
}
