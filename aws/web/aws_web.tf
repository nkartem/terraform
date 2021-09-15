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



resource "aws_instance" "web_server" {
    ami                   = "ami-09e67e426f25ce0d7"
    instance_type         = "t2.micro"
#    count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.
    vpc_security_group_ids = [ aws_security_group.web_server.id ]
    user_data = file("apache.sh")

lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
}
    tags = {
      Name = "web-server"
      OS = "Ubuntu 20.04"
      Project = "web server"
    }
}

resource "aws_eip" "static_ip" {
  instance=aws_instance.web_server.id 
}


resource "aws_security_group" "web_server" {
  name        = "WebServer Security Group"
  description = "SecurityGroup ports 80 443 22"
# vpc_id      = aws_vpc.main.id

dynamic "ingress" {
 for_each = ["80", "443", "22"]

   content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}

/*   ingress    {
      description      = "open port 80"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }*/

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Security Group for WebServer"
  }
}