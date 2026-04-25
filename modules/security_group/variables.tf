variable "tags" {
  type = map(string)
  default = {
    project     = "JustInOps"
    component   = "perforce"
    Environment = "dev"
    Service     = "P4"
  }
}

variable "p4_port" {
  type    = number
  default = 1666  
}

variable "ssh_port" {
  type = number
  default = 22
}

variable "allowed_p4_cidrs" {
  description = "List of CIDRs allowed to access Perforce. Use your public IP e.g. 1.2.3.4/32"
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed to SSH. Use your public IP e.g. 1.2.3.4/32"
  type    = list(string)
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to attach the security group to"
}
