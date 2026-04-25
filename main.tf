provider "aws" {
  region = var.region
}

# # Using the existing instance to determine how the p4 instance should be configured.
# import {
#   to = aws_instance.p4_instance
#   id = "i-06b2c2ace81412274"
# }

data "aws_ami" "sdp_ami_base" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = var.ami_filters
  }
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr_block
}

module "security_group" {
  source               = "./modules/security_group"
  vpc_id               = module.vpc.vpc_id
  p4_port              = var.p4_port
  ssh_port             = var.ssh_port
  allowed_p4_cidrs     = var.allowed_p4_cidrs
  allowed_ssh_cidrs    = var.allowed_ssh_cidrs
  allowed_egress_cidrs = var.allowed_egress_cidrs
}

resource "aws_instance" "p4_instance" {
  ami           = data.aws_ami.sdp_ami_base.id
  instance_type = var.instance_type

  associate_public_ip_address = true
  availability_zone           = var.availability_zone
  key_name                    = var.instance_key

  tags = {
    Name        = "p4-helix-core-dev"
    project     = "JustInOps"
    component   = "perforce"
    Owner       = "Hair"
    Environment = "dev"
    Service     = "P4"
  }

  # depots volume
  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    encrypted             = true
    tags = {
      "Backup"      = "true"
      "Environment" = "dev"
      "Name"        = "p4-dev-hxdepots-p4"
      "Owner"       = "Hair"
      "Service"     = "P4"
      "component"   = "perforce"
      "project"     = "JustInOps"
    }

    throughput  = 0
    volume_size = 128
    volume_type = "st1"
  }

  # logs volume
  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdg"
    encrypted             = true
    iops                  = 3000
    tags = {
      "Backup"      = "true"
      "Environment" = "dev"
      "Name"        = "p4-dev-hxlogs-p4"
      "Owner"       = "Hair"
      "Service"     = "P4"
      "component"   = "perforce"
      "project"     = "buildEngineering"
    }

    throughput  = 125
    volume_size = 16
    volume_type = "gp3"
  }

  # metadata volume
  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdh"
    encrypted             = true
    iops                  = 3000
    tags = {
      "Environment" = "dev"
      "Name"        = "p4-dev-hxmetadata-p4"
      "Owner"       = "Hair"
      "Service"     = "P4"
      "component"   = "perforce"
      "project"     = "buildEngineering"
    }

    throughput  = 125
    volume_size = 16
    volume_type = "gp3"
  }

  # I am not sure if I need this, but I will add it later if I do. For now, just a placeholder.
  # ebs_block_device {
  #   delete_on_termination = true
  #   device_name           = "/dev/sda1"
  #   encrypted             = false
  #   iops                  = 100
  #   # Snapshot from P4
  #   snapshot_id           = "snap-014de5d2c596505ee"
  #   tags                  = {}
  #   throughput            = 0
  #   volume_size           = 20
  #   volume_type           = "gp2"
  # }


  vpc_security_group_ids = [module.security_group.security_group_id]

  # script that runs to setup P4. 
  # I will add the script later, for now just a placeholder
  user_data = null


}
