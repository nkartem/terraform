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

resource "aws_instance" "rabbitmq" {
    ami                   = "ami-09e67e426f25ce0d7"
    instance_type         = "t2.micro"
#   count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.
    vpc_security_group_ids = [ aws_security_group.rabbitmq.id ]
    user_data = file("rabbitmq.sh")
    key_name = "rra"

lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
}
    tags = {
      Name = "rabbitmq"
      OS = "Ununtu"
      Project = "rabbitmq"
    }
}

resource "aws_eip" "static_ip" {
  instance=aws_instance.rabbitmq.id 
}


resource "aws_security_group" "rabbitmq" {
  name        = "rabbitmq Security Group"
  description = "SecurityGroup ports 22 5672 15672"
# vpc_id      = aws_vpc.main.id

dynamic "ingress" {
 for_each = ["22","5672","15672"]

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
    Name = "Security Group for RabbitMQ"
  }
}