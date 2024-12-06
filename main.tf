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

# # Private Subnet1
# resource "aws_subnet" "vterra_pvt1_sn" {
#   vpc_id                  = aws_vpc.vterra_vpc.id
#   availability_zone       = "us-east-1b"
#   cidr_block              = "10.0.2.0/24"
#   map_public_ip_on_launch = "false"

#   tags = {
#     Name = "vterra_pvt1_sn"
#   }
# }


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

# Private Route Table
# resource "aws_route_table" "vterra_pvt1_rt" {
#   vpc_id = aws_vpc.vterra_vpc.id

#   tags = {
#     Name = "vterra_pvt1_rt"
#   }
# }

# Private Route Table Association
# resource "aws_route_table_association" "vterra_Pvt1_rta" {
#   subnet_id      = aws_subnet.vterra_pvt1_sn.id
#   route_table_id = aws_route_table.vterra_pvt1_rt.id

# }

# NAT Gateway
# resource "aws_nat_gateway" "vterra_nat1" {
#   allocation_id = aws_eip.vterra_nat.id
#   subnet_id     = aws_subnet.vterra_pub1_sn.id

#   tags = {
#     Name = "vterra_nat1"
#   }
# }

# Elastic IP
# resource "aws_eip" "vterra_nat" {
#   vpc = true

#   tags = {
#     Name = "ElasticIP-NATGateway"
#   }
# }

# Private Route
# resource "aws_route" "vterra_pvt_route" {
#   route_table_id         = aws_route_table.vterra_pvt1_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.vterra_nat1.id
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


# resource "aws_security_group" "vterra_sg" {
#   name        = "vterra_sg"
#   description = "Security group allowing SSH, HTTP, and HTTPS"
#   vpc_id      = aws_vpc.vterra_vpc.id

#   ingress {
#     description = "Allow SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Allow HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Allow HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     description = "Allow all outbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "vterra_sg"
#   }
# }


# Instance
resource "aws_instance" "Terra_Pub" {
  ami                         = "ami-005fc0f236362e99f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.vterra_pub1_sn.id
  key_name                    = "DevOpskey"
  vpc_security_group_ids      = [aws_security_group.vterra_sg.id]
  associate_public_ip_address = true
  availability_zone           = "us-east-1a"

  # user_data = <<-EOF
  #             #!/bin/bash
  #             sudo apt update -y
  #             sudo apt install -y nginx
  #             echo "<html><body><h1>Hello World</h1></body></html>" | sudo tee /var/www/html/index.html > /dev/null
  #             sudo systemctl start nginx
  #             sudo systemctl enable nginx
  #             EOF

  tags = {
    Name        = "Terra_Pub"
    Owner       = "Rajesh"
    Environment = "Development"
  }

}

# # S3 Bucket
# resource "aws_s3_bucket" "vterra_s3" {
#   bucket = "vterras3"

#   tags = {
#     Name        = "vterra_s3_bucket"
#     Environment = "Development"
#   }
# }

# resource "aws_s3_bucket_versioning" "vterra_s3_versioning" {
#   bucket = aws_s3_bucket.vterra_s3.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }





# aws s3api create-bucket --bucket vterras3 --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1
# aws s3api put-bucket-versioning --bucket vterras3 --versioning-configuration Status=Enabled

# aws s3api create-bucket --bucket vterras3 --region us-east-1
# aws s3api put-bucket-versioning --bucket vterras3 --versioning-configuration Status=Enabled


# Linux
# unset AWS_ACCESS_KEY_ID
# unset AWS_SECRET_ACCESS_KEY
# unset AWS_SESSION_TOKEN

# Powershell
# Remove-ItemEnv:AWS_ACCESS_KEY_ID
# Remove-ItemEnv:AWS_SECRET_ACCESS_KEY
# Remove-ItemEnv:AWS_SESSION_TOKEN
