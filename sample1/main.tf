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

module "sg_test" {
  source = "../modules/security_group"

  security_group_name = "sg_test"
  vpc_id              = aws_vpc.sg_test_vpc.id

  tags = {
    Name = "sg_test"
  }
}

################################################################################
# Security Group Rule - Ingress
################################################################################

# applyすると、ちゃんと（？）test-1とtest-2がぶつかってエラーが出る。
module "test_sg_ingress" {
  source   = "../modules/security_group_rule"
  for_each = toset(["test-1", "test-2"])

  sg_rule_type      = "ingress"
  security_group_id = module.sg_test.this_security_group_id

  description = each.key
}

################################################################################
# Security Group Rule - Egress
################################################################################

module "test_sg_egress" {
  source = "../modules/security_group_rule"

  sg_rule_type      = "egress"
  security_group_id = module.sg_test.this_security_group_id
}