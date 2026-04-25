resource "aws_security_group" "perforce_access" {
  name        = "perforce_security_group"
  description = "Allow TLS inbound traffic for 1666 and all outbound traffic.  Allow SSH from JustInOps office IPs."
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.perforce_access.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = var.p4_port
  ip_protocol       = "tcp"
  to_port           = var.p4_port
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress" {
  for_each          = toset(var.allowed_ssh_cidrs)
  security_group_id = aws_security_group.perforce_access.id
  cidr_ipv4         = each.value
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.perforce_access.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"  # all protocols
}
