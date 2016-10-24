# This sample creates a simple infrastructure with:
# 1 Network VPC
# 2 Subnets: private and public
# 1 Loadbalancer
# 1 Web server with 2 instances, on private network
# 1 Postgres server, on private network

variable app { default = "my_company" }
variable env { default = "staging" }

# Create our network
module "base_network" {
  source = "git::ssh://git@github.com/jmatosp/terraform.git//vpc"
  app    = "${var.app}"
  env    = "${var.env}"
  name   = "base"
}

# Security group that allows HTTPS in and ALL out
module "sg_allow_https" {
  source        = "git::ssh://git@github.com/jmatosp/terraform.git//sg_allow_protocol"
  app           = "${var.app}"
  env           = "${var.env}"
  name          = "website"
  vpc_id        = "${module.base_network.vpc_id}"
  allow_subnets = "${module.base_network.public_subnets}"
  allow_port    = "443"
}

# Create an application load balancer
module "load_balancer" {
  source          = "git::ssh://git@github.com/jmatosp/terraform.git//alb"
  app             = "${var.app}"
  env             = "${var.env}"
  name            = "website"
  vpc_id          = "${module.base_network.vpc_id}"
  subnets         = "${module.base_network.public_subnets}"
  route53_zone_id = "${module.base_network.route53_zone_id}"
  security_groups = "${module.sg_allow_https.id}"
  certificate_arn = "${var.alb_ssl_cert_arn_external}"
  target_port     = 80
}

# Listner for the loadbalancer
module "website-alb-target" {
  source          = "git::ssh://git@github.com/jmatosp/terraform.git//alb-target"
  app             = "${var.app}"
  env             = "${var.env}"
  name            = "website"
  vpc_id          = "vpc_1234567890"
  alb_listner_arn = "${module.load_balancer.alb_listner_arn}"
  url_pattern     = "/*"
  port            = 80
}

# Creates a postgres database resource
module "database" {
  source          = "git::ssh://git@github.com/jmatosp/terraform.git//rds"
  app             = "${var.app}"
  env             = "${var.env}"
  name            = "website"
  vpc_id          = "${module.base_network.vpc_id}"
  vpc_subnet      = "${module.base_network.vpc_subnet}"
  route53_zone_id = "${module.base_network.route53_zone_id}"
  subnets         = "${module.base_network.private_subnets}"
  storage_type    = "50"
  db_name         = "website"
  username        = "jobdone"
  password        = "my_very_secret_pass_on_github"
}
