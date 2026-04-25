variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_owners" {
  type    = list(string)
  default = ["aws-marketplace"]
}

variable "ami_filters" {
  type    = list(string)
  default = ["Perforce-Helix-Core-SDP-AMI-Base 202*"]
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "p4_port" {
  type    = number
  default = 1666
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "allowed_p4_cidrs" {
  description = "List of CIDRs allowed to access Perforce. 0.0.0.0/0 allows all IPs."
  type        = list(string)
  default = [
    "0.0.0.0/0"
  ]
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed to SSH. 0.0.0.0/0 allows all IPs. Use your public IP"
  type        = list(string)
}

variable "allowed_egress_cidrs" {
  description = "List of CIDRs allowed for egress."
  type        = list(string)
  default = [
    "0.0.0.0/0"
  ]
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1c"
}

variable "instance_key" {
  type    = string
  default = "perforceKey"
}

