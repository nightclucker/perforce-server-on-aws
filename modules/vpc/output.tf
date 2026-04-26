output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.p4_vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets."
  value       = aws_subnet.p4_subnet.id
}
