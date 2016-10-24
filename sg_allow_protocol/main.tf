resource "aws_security_group" "mod" {
  name        = "${var.app}-${var.env}-elb-ecs-${var.name}"
  description = "Security group that allows inbound on port ${var.allow_port} and outbound traffic from all instances in the VPC"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.app}-${var.env}-elb-ecs-${var.name}"
    Created-by  = "terraform"
    environment = "${var.env}"
    project     = "${var.app}"
  }

  ingress {
    from_port = "${var.allow_port}"
    to_port   = "${var.allow_port}"
    protocol  = "tcp"

    cidr_blocks = ["${var.allow_subnets}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}