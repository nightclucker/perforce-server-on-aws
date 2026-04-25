output "ami_id_output" {
  value = "AMI ID:  ${resource.aws_instance.p4_instance.ami}\nAMI Name: ${data.aws_ami.sdp_ami_base.name}"
}
