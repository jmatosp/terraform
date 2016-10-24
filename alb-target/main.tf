resource "aws_alb_target_group" "mod" {
  name     = "${var.app}-${var.env}-${var.name}-ecs-internal"
  port     = "${var.port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_listener_rule" "mod" {
  listener_arn = "${var.alb_listner_arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.mod.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["${var.url_pattern}"]
  }
}
