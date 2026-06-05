resource "aws_lb_target_group" "web_target_group" {
  name        = "private-webserver-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"

  health_check {
    path                = "/healthcheck"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "private-webserver-target-group"
  }
}