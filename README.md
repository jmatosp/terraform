## Terraform Modules

This repository provides simple Terraform modules for common infrastructure orchestration

Each directory contains one module and a README.md with usage details

## Usage

To use any module in your infrastructure just follow the syntax from Terraform module:

```
module "database" {
  source = "./rds"
  project_name    = "website"
  environment     = "staging"
  name            = "database"
  vpc_id          = "vpc_1234567890"
  db_name         = "job_done"
  username        = "db_username"
  password        = "db_password"
}
```

## Structure

Each module follow the more or less standard structure of a main.tf file do define the infrastructure resources,
a outputs.tf for all exported values and vars.tf for all required parameters

All modules expect at least 3 parameters:

- App - Application name, example: website
- Env - Environment name, example: staging
- Name - Resource group name, example: database

these parameters are used together to build resources unique names, example for a RDS resource with the above example would have the name *website-staging-database*

## Modules

- RDS
- ALB
- ALB-TARGET
- SG_ALLOW_PROTOCOL

## More

If you find this useful of want to contribute leave a message 