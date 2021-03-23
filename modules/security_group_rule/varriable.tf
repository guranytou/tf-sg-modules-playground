################################################################################
# Input Varriable
################################################################################

variable "sg_rule_type" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "from_port" {
  type    = number
  default = 0
}

variable "to_port" {
  type    = number
  default = 0
}

variable "protocol" {
  type    = string
  default = "-1"
}

variable "cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "source_security_group_id" {
  type = string
  default = null
}

variable "description" {
  type    = string
  default = ""
}