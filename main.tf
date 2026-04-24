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

resource "aws_instance" "p4_instance" {
  ami           = "ami-00635fb441a02b7fd"
  instance_type = "t3.small"

  tags = {
    Name        = "p4-helix-core-dev"
    project     = "JustInOps"
    component   = "perforce"
    Owner       = "Hair"
    Environment = "dev"
  }
}

