data "aws_route53_zone" "main" {
  name         = "prasadcloud.com"
  private_zone = false
}

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

# Always pointing to S3 static page
resource "aws_route53_record" "maintenance" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "maintenance.prasadcloud.com"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_s3_bucket.static_fallback.bucket}.s3-website.eu-west-2.amazonaws.com"]
}

output "singingai_url" {
  value       = "https://singingai.prasadcloud.com"
  description = "SingingAI production URL"
}