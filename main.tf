terraform {
  cloud {
    organization = "JustInOps"
    workspaces {
      name = "perforce-server-on-aws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "sdp_ami_base" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = var.ami_filters
  }
}

locals {
  instance_name        = "p4-helix-core-${var.environment}"
  depot_volume_name    = "p4-${var.environment}-hxdepots-p4"
  logs_volume_name     = "p4-${var.environment}-hxlogs-p4"
  metadata_volume_name = "p4-${var.environment}-hxmetadata-p4"
  p4d_auth_id          = "P4-${var.environment == "prod" ? "MAIN" : "SECONDARY"}-AWS"

  common_tags = {
    project     = var.project_name
    component   = var.tag_component
    Environment = var.environment
    Service     = var.tag_service
  }
}

module "vpc" {
  source            = "./modules/vpc"
  cidr_block        = var.vpc_cidr_block
  environment       = var.environment
  availability_zone = var.availability_zone
  project_name      = var.project_name
  tag_component     = var.tag_component
  tag_service       = var.tag_service
}

module "security_group" {
  source               = "./modules/security_group"
  vpc_id               = module.vpc.vpc_id
  p4_port              = var.p4_port
  ssh_port             = var.ssh_port
  allowed_p4_cidrs     = var.allowed_p4_cidrs
  allowed_ssh_cidrs    = var.allowed_ssh_cidrs
  allowed_egress_cidrs = var.allowed_egress_cidrs
  tags                 = local.common_tags
}

resource "aws_instance" "p4_instance" {
  ami           = data.aws_ami.sdp_ami_base.id
  instance_type = var.instance_type
  subnet_id     = module.vpc.subnet_ids

  associate_public_ip_address = true
  availability_zone           = var.availability_zone
  key_name                    = var.instance_key

  vpc_security_group_ids = [module.security_group.security_group_id]

  # script that runs to setup P4. 
  # I will add the script later, for now just a placeholder
  user_data = templatefile("${path.module}/scripts/p4_userdata.sh", {
    region      = var.region,
    p4d_auth_id = local.p4d_auth_id
  })

  tags = merge(local.common_tags, { Name = local.instance_name })

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

resource "aws_ebs_volume" "depots" {
  availability_zone = var.availability_zone
  size              = 128
  type              = "st1"
  encrypted         = true

  tags = merge(local.common_tags, {
    "Backup" = "true"
    "Name"   = local.depot_volume_name
  })
}

resource "aws_volume_attachment" "depots" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.depots.id
  instance_id = aws_instance.p4_instance.id
}

resource "aws_ebs_volume" "logs" {
  availability_zone = var.availability_zone
  size              = 16
  type              = "gp3"
  iops              = 3000
  throughput        = 125
  encrypted         = true

  tags = merge(local.common_tags, {
    "Backup" = "true"
    "Name"   = local.logs_volume_name
  })
}

resource "aws_volume_attachment" "logs" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.logs.id
  instance_id = aws_instance.p4_instance.id
}

resource "aws_ebs_volume" "metadata" {
  availability_zone = var.availability_zone
  size              = 16
  type              = "gp3"
  iops              = 3000
  throughput        = 125
  encrypted         = true

  tags = merge(local.common_tags, { "Name" = local.metadata_volume_name })
}

resource "aws_volume_attachment" "metadata" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.metadata.id
  instance_id = aws_instance.p4_instance.id
}
