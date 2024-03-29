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
  region = "eu-central-1"
}


resource "aws_instance" "AL2" {
    ami = "ami-0c956e207f9d113d5" # eu-central-1
    instance_type = "t2.micro"
    user_data = file("install.sh")
    vpc_security_group_ids = [ aws_security_group.web_al2.id ]
#    count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.de
    key_name = "ssh1" # You must create key

    tags = {
      Name = "AL2"
      OS = "Amazon Linux 2"
      Project = "Git"
    }
}

resource "aws_security_group" "web_al2" {
  name        = "WebServer Security Group"
  description = "SecurityGroup ports 80 443 22"
# vpc_id      = aws_vpc.main.id


dynamic "ingress" {
 for_each = ["80", "443", "22"]

   content    {
      description      = "ssh web"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}


dynamic "ingress" {
 for_each = ["1195", "2222"]

   content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "udp"
      cidr_blocks      = ["11.222.111.82/32", "14.214.141.61/32"]
    }
}

dynamic "ingress" {
 for_each = ["13222"]

   content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["1.2.3.4/32", "4.3.2.1/32", "32.34.32.33/32"]
    }
}


  ingress {
      description      = "open ports for SIP"
      from_port        = 10000
      to_port          = 20000
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
}



  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Security Group WebServer"
    WebServer = "nginx"
  }
}