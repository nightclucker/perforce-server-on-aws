provider "aws" {
  region = "us-east-1"
}

# Create a VPC?
# Create a Security Group?
# Create an EC2 instance using Perforce-Helix-Core ami, ami-00635fb441a02b7fd, Perforce-Helix-Core-SDP-AMI-Base 2025.2.1 20260114 114159-a4bd0546-27f6-4fda-bd99-980db4b2792a
# create volumes
# Add tags to everything
# key pair
# backups

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
  tags_all = {
    Name        = "p4-helix-core-dev"
    project     = "JustInOps"
    component   = "perforce"
    Owner       = "Hair"
    Environment = "dev"
    Service     = "P4"
  }

  # vpc
  # security Group
  # ebs block devices - New
  # ebs block devices - from existing?

  # depots volume
  ebs_block_device {
    delete_on_termination = false
    device_name           = "/dev/sdf"
    encrypted             = true
    kms_key_id            = "arn:aws:kms:us-east-1:230572723352:key/fb5ded94-86ca-4f23-bc59-e6b9f81bdf0d"
    tags = {
      "Backup"      = "true"
      "Environment" = "dev"
      "Name"        = "p4-dev-hxdepots-p4"
      "Owner"       = "Hair"
      "Service"     = "P4"
      "component"   = "perforce"
      "project"     = "JustInOps"
    }
    tags_all = {
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
    kms_key_id            = "arn:aws:kms:us-east-1:230572723352:key/fb5ded94-86ca-4f23-bc59-e6b9f81bdf0d"
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
    kms_key_id            = "arn:aws:kms:us-east-1:230572723352:key/fb5ded94-86ca-4f23-bc59-e6b9f81bdf0d"
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

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    encrypted             = false
    iops                  = 100
    snapshot_id           = "snap-014de5d2c596505ee"
    tags                  = {}
    tags_all              = {}
    throughput            = 0
    volume_id             = "vol-0fc6b3e5a3b7264e4"
    volume_size           = 20
    volume_type           = "gp2"
  }

  root_block_device {
    delete_on_termination = true
    device_name           = "/dev/sda2"
    encrypted             = false
    iops                  = 3000
    tags                  = {}
    tags_all              = {}
    throughput            = 125
    volume_size           = 30
    volume_type           = "gp3"
  }

  vpc_security_group_ids = [
    "sg-0024d17ba26256eb7",
  ]

  # script that runs to setup P4. 
  # I will add the script later, for now just a placeholder
  user_data = null


}

output "ami_id_output" {
  value = "AMI ID:  ${resource.aws_instance.p4_instance.ami}\nAMI Name: ${data.aws_ami.sdp_ami_base.name}"
}
