# ── ROUTE 53 HOSTED ZONE ─────────────────────────────────────────────────────

data "aws_route53_zone" "main" {
  name         = "prasadcloud.com"
  private_zone = false
}

# ── DNS RECORDS ───────────────────────────────────────────────────────────────

# SingingAI application → ALB
resource "aws_route53_record" "singingai" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "singingai.prasadcloud.com"
  type    = "A"

  alias {
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = true
  }
}

# Maintenance page → S3 static site
resource "aws_route53_record" "maintenance" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "maintenance.prasadcloud.com"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_s3_bucket.static_fallback.bucket}.s3-website.eu-west-2.amazonaws.com"]
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "singingai_url" {
  value       = "https://singingai.prasadcloud.com"
  description = "SingingAI production URL"
}

output "maintenance_url" {
  value       = "http://maintenance.prasadcloud.com"
  description = "Maintenance page URL — active when app is offline"
}

output "hosted_zone_id" {
  value       = data.aws_route53_zone.main.zone_id
  description = "Route53 hosted zone ID for prasadcloud.com"
}
