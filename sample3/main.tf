terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}
variable "aws_role_arn" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
  assume_role {
    role_arn = var.aws_role_arn
  }
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "sg_test_vpc" {
  cidr_block = "172.0.0.0/16"

  tags = {
    Name = "sg_test_vpc"
  }
}

################################################################################
# Security Group
################################################################################

module "sg_test-1" {
  source = "../modules/security_group"

  security_group_name = "sg_test-1"
  vpc_id              = aws_vpc.sg_test_vpc.id

  tags = {
    Name = "sg_test-1"
  }
}

module "sg_test-2" {
  source = "../modules/security_group"

  security_group_name = "sg_test-2"
  vpc_id              = aws_vpc.sg_test_vpc.id

  tags = {
    Name = "sg_test-2"
  }
}

module "sg_test-3" {
  source = "../modules/security_group"

  security_group_name = "sg_test-3"
  vpc_id              = aws_vpc.sg_test_vpc.id

  tags = {
    Name = "sg_test-3"
  }
}

################################################################################
# Security Group Rule - Ingress
################################################################################
locals {
  test_sg_ingress = {
      sg_test-1 = {
        source_security_group_id = module.sg_test-1.this_security_group_id
      }
      sg_test-2 = {
        source_security_group_id = module.sg_test-2.this_security_group_id
      }
  }
}

module "test_sg_ingress" {
  source   = "../modules/security_group_rule"
  for_each = {
      for k, v in local.test_sg_ingress: k => {
        source_security_group_id = v["source_security_group_id"]
      }
  }

  sg_rule_type      = "ingress"
  security_group_id = module.sg_test-3.this_security_group_id

  from_port = 80
  to_port = 80
  protocol = "tcp"

  source_security_group_id = each.value["source_security_group_id"]

  description = each.key
}

################################################################################
# Security Group Rule - Egress
################################################################################

module "test_sg_egress" {
  source = "../modules/security_group_rule"

  sg_rule_type      = "egress"
  security_group_id = module.sg_test-3.this_security_group_id
}