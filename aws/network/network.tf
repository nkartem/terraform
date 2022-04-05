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


# Create Elastic IP
resource "aws_eip" "eip1" {
  vpc              = true
}

resource "aws_eip" "eip2" {
}

# Create security group
resource "aws_security_group" "name_security_group1" {
  name        = "SomeName1 Security Group"
  description = "SecurityGroup ports 22 443 80 8080"
# vpc_id      = aws_vpc.main.id

dynamic "ingress" {
 for_each = ["22","443","8080", "80"]

   content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Security Group for SomeName1"
  }
}

resource "aws_security_group" "name_security_group2" {
  name        = "SomeName Security Group"
  description = "SecurityGroup ports 22 21 3389"
# vpc_id      = aws_vpc.main.id

dynamic "ingress" {
 for_each = ["22","21"]

   content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
   }
}

  ingress    {
      description      = "open port RDP 3389"
      from_port        = 3389
      to_port          = 3389
      protocol         = "tcp"
      cidr_blocks      = ["79.81.32.25/32"]
  }

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Security Group for SomeName2"
  }
}