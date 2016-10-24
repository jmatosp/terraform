resource "aws_alb" "mod" {
  name            = "${var.app}-${var.env}-${var.name}"
  internal        = false
  security_groups = ["${var.security_groups}"]
  subnets         = ["${split(",", var.subnets)}"]

  tags {
    environment = "${var.env}"
    Name        = "${var.app}-${var.env}-ecs-${var.name}"
    project     = "${var.app}"
  }
}

resource "aws_alb_listener" "mod" {
  load_balancer_arn = "${aws_alb.mod.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.mod.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "mod" {
  name     = "${var.app}-${var.env}-ecs-${var.name}"
  port     = "${var.target_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_route53_record" "mod" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.name}"
  type    = "A"

  alias {
    name    = "${aws_alb.mod.dns_name}"
    zone_id = "${aws_alb.mod.zone_id}"

    // we only have a single resource in the alias so we dont need to evaluate health of endpoints.
    evaluate_target_health = false
  }
}
