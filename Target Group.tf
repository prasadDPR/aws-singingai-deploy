# ── TARGET GROUP ─────────────────────────────────────────────────────────────

resource "aws_lb_target_group" "web_target_group" {
  name        = "singingai-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/api/health"
    port                = "3000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 10
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "singingai-target-group"
  }
}
