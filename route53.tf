/*
resource "aws_route53_zone" "production_zone" {
  name = "prasad-project.com"
}

resource "aws_route53_record" "production_record" {
  zone_id = aws_route53_zone.production_zone.zone_id
  name    = "www.prasad-project.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.web_alb.dns_name]
}
*/