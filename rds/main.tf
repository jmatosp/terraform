resource "aws_security_group" "mod" {
  name        = "${var.app}-${var.env}-rds-${var.name}"
  description = "Allow postgres inbound traffic"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_subnet}"]
  }
}

resource "aws_db_parameter_group" "mod" {
  name        = "${var.app}-${var.env}"
  family      = "postgres9.4"
  description = "RDS default parameter group"
}

resource "aws_db_instance" "mod" {
  identifier                = "${var.app}-${var.env}-${var.name}"
  allocated_storage         = "${var.instance_size}"
  engine                    = "postgres"
  engine_version            = "9.4.5"
  instance_class            = "${var.instance_class}"
  storage_type              = "${var.storage_type}"
  name                      = "${var.db_name}"
  username                  = "${var.username}"
  password                  = "${var.password}"
  vpc_security_group_ids    = ["${aws_security_group.mod.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.mod.name}"
  parameter_group_name      = "${aws_db_parameter_group.mod.name}"
  final_snapshot_identifier = "${var.env}-${var.app}-final-snapshot"
  multi_az                  = true
  backup_retention_period   = 35
}

resource "aws_db_subnet_group" "mod" {
  name        = "${var.env}-main"
  description = "${var.env} environment main group of subnets"
  subnet_ids  = ["${split(",", var.subnets)}"]

  tags {
    Name = "${var.env}-${var.app}"
  }
}

resource "aws_route53_record" "mod" {
  zone_id = "${var.route53_zone_id}"
  name    = "postgres_${var.env}${var.name}"
  type    = "CNAME"
  ttl     = 10
  records = ["${aws_db_instance.mod.address}"]
}
