 terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "name_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "name-vpc-terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "name_igw" {
  vpc_id = aws_vpc.name_vpc.id

  tags = {
    Name = "Internet Gateway Terraform"
  }
}

# Create subnet
resource "aws_subnet" "name_public_subnet" {
  vpc_id     = aws_vpc.name_vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "name_private_subnet" {
  vpc_id     = aws_vpc.name_vpc.id
  cidr_block = "10.10.2.0/24"

  tags = {
    Name = "Private"
  }
}

resource "aws_subnet" "name_database_subnet" {
  vpc_id     = aws_vpc.name_vpc.id
  cidr_block = "10.10.3.0/24"

  tags = {
    Name = "database subnet"
  }
}

# Create Route Table
resource "aws_route_table" "name_route_table_public" {
  vpc_id = aws_vpc.name_vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.name_igw.id
  }
  
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.name_igw.id
  # }

  tags = {
    Name = "name_route_table_public"
  }
}

# association route table whith  subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.name_public_subnet.id
  route_table_id = aws_route_table.name_route_table_public.id
}


# # Create Elastic IP
# # resource "aws_eip" "eip1" {
# #   vpc              = true
# # }

# # resource "aws_eip" "eip2" {
# # }

# # Create security group
# resource "aws_security_group" "name_security_group1" {
#   name        = "SomeName1 Security Group"
#   description = "SecurityGroup ports 22 443 80 8080"
# # vpc_id      = aws_vpc.main.id

# dynamic "ingress" {
#  for_each = ["22","443","8080", "80"]

#    content    {
#       description      = "open ports"
#       from_port        = ingress.value
#       to_port          = ingress.value
#       protocol         = "tcp"
#       cidr_blocks      = ["0.0.0.0/0"]
#     }
# }

#   egress    {
#       from_port        = 0
#       to_port          = 0
#       protocol         = "-1"
#       cidr_blocks      = ["0.0.0.0/0"]
#     }

#   tags = {
#     Name = "Security Group for SomeName1"
#   }
# }

# resource "aws_security_group" "name_security_group2" {
#   name        = "SomeName Security Group"
#   description = "SecurityGroup ports 22 21 3389"
# # vpc_id      = aws_vpc.main.id

# dynamic "ingress" {
#  for_each = ["22","21"]

#    content    {
#       description      = "open ports"
#       from_port        = ingress.value
#       to_port          = ingress.value
#       protocol         = "tcp"
#       cidr_blocks      = ["0.0.0.0/0"]
#    }
# }

#   ingress    {
#       description      = "open port RDP 3389"
#       from_port        = 3389
#       to_port          = 3389
#       protocol         = "tcp"
#       cidr_blocks      = ["79.81.32.25/32"]
#   }

#   egress    {
#       from_port        = 0
#       to_port          = 0
#       protocol         = "-1"
#       cidr_blocks      = ["0.0.0.0/0"]
#     }

#   tags = {
#     Name = "Security Group for SomeName2"
#   }
# }