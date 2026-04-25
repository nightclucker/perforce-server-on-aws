provider "aws" {
  region = "us-east-1"
}

# # Using the existing instance to determine how the p4 instance should be configured.
# import {
#   to = aws_instance.p4_instance
#   id = "i-06b2c2ace81412274"
# }

data "aws_ami" "sdp_ami_base" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["Perforce-Helix-Core-SDP-AMI-Base 202*"]
  }
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "security_group" {
  source            = "./modules/security_group"
  vpc_id            = module.vpc.vpc_id
  p4_port           = 1666
  ssh_port          = 22
  allowed_ssh_cidrs = ["0.0.0.0/0"]
  allowed_p4_cidrs  = ["0.0.0.0/0"]
}

resource "aws_instance" "p4_instance" {
  ami           = data.aws_ami.sdp_ami_base.id
  instance_type = "t3.small"

  associate_public_ip_address = true
  availability_zone           = "us-east-1c"
  key_name                    = "perforceKey"

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

output "ami_id_output" {
  value = "AMI ID:  ${resource.aws_instance.p4_instance.ami}\nAMI Name: ${data.aws_ami.sdp_ami_base.name}"
}
