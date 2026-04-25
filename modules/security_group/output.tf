output "security_group_id" {
  description = "ID of the Perforce security group"
  value       = aws_security_group.perforce_access.id
}