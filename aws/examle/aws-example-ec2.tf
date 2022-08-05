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


resource "aws_instance" "AmazonLinux2" {
    ami = "ami-0c956e207f9d113d5"
    instance_type = "t2.micro"
#    count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.de
#    key_name = "aml2" # You must create key

    tags = {
      Name = "Amazon Linux 2"
      OS = "Amazon Linux 2"
    }
}