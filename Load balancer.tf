# ── APPLICATION LOAD BALANCER ─────────────────────────────────────────────────

resource "aws_lb" "web_alb" {
  name               = "singingai-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.publicsubnet1a.id,
    aws_subnet.publicsubnet1b.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "singingai-alb"
  }
}

# ── HTTP → HTTPS REDIRECT ─────────────────────────────────────────────────────

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ── HTTPS LISTENER ────────────────────────────────────────────────────────────

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

# ── OUTPUTS ───────────────────────────────────────────────────────────────────

output "alb_dns_name" {
  value       = aws_lb.web_alb.dns_name
  description = "ALB DNS name for Route53 alias record"
}

output "alb_zone_id" {
  value       = aws_lb.web_alb.zone_id
  description = "ALB hosted zone ID for Route53 alias record"
}
