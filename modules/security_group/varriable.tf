################################################################################
# Input Values
################################################################################

variable "security_group_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}