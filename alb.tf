# alb.tf

resource "aws_alb" "main" {
  name            = "brevistay-prod-load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]

}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
/*
 default_action {
  type             = "redirect"
  redirect {
    protocol        = "HTTPS"
    port            = "443"
    status_code     = "HTTP_301"
  }
  } 
}*/
  
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.arn
  } 
}

/*
resource "aws_alb_listener_rule" "rule2" {
  listener_arn = aws_alb_listener.main.arn

  condition {
    path_pattern {
      values = ["/cst/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:540445519516:targetgroup/test-prod-targate/30ae349a38b4f885"

}

} */

# ALB Listener for https
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
 // certificate_arn   = "arn:aws:acm:ap-south-1:540445519516:certificate/76d8d0e0-c04d-48f8-93bf-35dbf8da6b1f"
  certificate_arn   = "arn:aws:acm:ap-south-1:540445519516:certificate/28e96e3b-40c9-4265-8191-35921abb890e"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.arn
  }
}
/*
resource "aws_alb_listener_rule" "rule3" {
  listener_arn = aws_alb_listener.https.arn

  condition {
    path_pattern {
      values = ["/cst/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:540445519516:targetgroup/test-prod-targate/30ae349a38b4f885"

}

}
*/

resource "aws_alb_target_group" "app" {
  name        = "brevistay-prod-target-group"
  port        = 3003
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
/* resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
} */

