locals {
  subnet_name = "p4-${var.environment}-subnet"
  gateway_name = "p4-${var.environment}-igw"
  route_table_name = "p4-${var.environment}-rt"
  p4d_auth_id = "P4-${var.environment == "prod" ? "MAIN" : "DEV"}-AWS"

  common_tags = {
    project     = var.project_name
    component   = var.tag_component
    Environment = var.environment
    Service     = var.tag_service
  }
}

resource "aws_vpc" "p4_vpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "p4_subnet" {
  vpc_id                  = aws_vpc.p4_vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { "Name" = local.subnet_name })
}

resource "aws_internet_gateway" "p4_internet_gateway" {
    vpc_id = aws_vpc.p4_vpc.id

    tags = merge(local.common_tags, { "Name" = local.gateway_name })
  
}

resource "aws_route_table" "p4_route_table" {
    vpc_id = aws_vpc.p4_vpc.id

    route {
        cidr_block = var.route_table_cidr_block
        gateway_id = aws_internet_gateway.p4_internet_gateway.id
    }

    tags = merge(local.common_tags, { "Name" = local.route_table_name })
}

resource "aws_route_table_association" "p4_route_table_association" {
    subnet_id = aws_subnet.p4_subnet.id
    route_table_id = aws_route_table.p4_route_table.id
}
