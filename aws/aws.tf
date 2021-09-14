terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}



resource "aws_instance" "ubuntu2004" {
    ami = "ami-09e67e426f25ce0d7"
    instance_type = "t2.micro"
#    count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.de

    tags = {
      Name = "Ubuntu 20.04"
      OS = "Ubuntu"
      Project = "Kubernetes master"
    }
}