output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.p4_vpc.id
}
