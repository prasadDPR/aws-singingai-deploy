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

output "singingai_url" {
  value       = "https://singingai.prasadcloud.com"
  description = "SingingAI production URL"
}