terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # access_key = "" # AWS account rajesh_rajendiran
  # secret_key = "" # AWS account rajesh_rajendiran
}

# Configure the AWS S3 under rajesh_rajendiran
terraform {
  backend "s3" {
    bucket = "vpc-s3-task"
    key    = "base-file"
    region = "us-east-1"
  }
}

# Configure the AWS VPC
resource "aws_vpc" "Vpc_Terraform" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "Vpc_Terraform"
  }
}

# Configure the AWS VPC Subnet 
resource "aws_subnet" "VPc_Pub_Subnet_Terraform" {
  vpc_id            = aws_vpc.Vpc_Terraform.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  #map_public_ip_on_launch = "true"

  tags = {
    Name = "VPc_Pub_Subnet_Terraform"
  }
}

# Configure the AWS VPC IGW
resource "aws_internet_gateway" "IGW_Terraform" {
  vpc_id = aws_vpc.Vpc_Terraform.id

  tags = {
    Name = "IGW_Terraform"
  }
}

# resource "aws_egress_only_internet_gateway" "EgressOnlyGateway_Terraform" {
#   vpc_id = aws_vpc.Vpc_Terraform.id
# 
#   tags = {
# Name = "EgressOnlyGateway_Terraform"
#   }
# }

# Configure the AWS VPC RT
resource "aws_route_table" "Routetable_Terraform" {
  vpc_id = aws_vpc.Vpc_Terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_Terraform.id
  }
  #   route {
  #     ipv6_cidr_block        = "::/0"
  #     egress_only_gateway_id = aws_egress_only_internet_gateway.EgressOnlyGateway_Terraform.id
  #   }

  tags = {
    Name = "Routetable_Terraform"
  }
}

# Configure the AWS VPC RTA
resource "aws_route_table_association" "Routetable_Association_Terraform" {
  subnet_id      = aws_subnet.VPc_Pub_Subnet_Terraform.id
  route_table_id = aws_route_table.Routetable_Terraform.id
}

# Configure the AWS Security Group
resource "aws_security_group" "MySG_Terraform" {
  name        = "MySG_Terraform"
  description = "Allow 22,80,443 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.Vpc_Terraform.id

  tags = {
    Name = "MySG_Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_port_22" {
  security_group_id = aws_security_group.MySG_Terraform.id
  cidr_ipv4         = "0.0.0.0/0" # Allows traffic from anywhere
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_port_80" {
  security_group_id = aws_security_group.MySG_Terraform.id
  cidr_ipv4         = "0.0.0.0/0" # Allows traffic from anywhere
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_port_443" {
  security_group_id = aws_security_group.MySG_Terraform.id
  cidr_ipv4         = "0.0.0.0/0" # Allows traffic from anywhere
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.MySG_Terraform.id
#   cidr_ipv4         = "0.0.0.0/0" # Allows all outbound IPv4 traffic
#   ip_protocol       = "-1"        # Semantically equivalent to all protocols and ports
# }

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.MySG_Terraform.id
  cidr_ipv6         = "::/0" # Allows all outbound IPv6 traffic
  ip_protocol       = "-1"   # Semantically equivalent to all protocols and ports
}
