variable environment {
  type    = string
  default = "dev"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet."
  type        = string
  default     = "us-east-1c"
}

variable "route_table_cidr_block" {
  description = "CIDR block for the route table."
  type        = string
  default     = "0.0.0.0/0"
}

variable project_name {
  type    = string
  default = "JustInOps"
}

variable "tag_component" {
  type = string
  default = "perforce"
}

variable "tag_service" {
  type = string
  default = "P4"
}