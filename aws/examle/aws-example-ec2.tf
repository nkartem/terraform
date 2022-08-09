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
#  region = "eu-central-1"
#  region = "eu-north-1"
  region = "eu-west-2"
}


resource "aws_instance" "AL2" {
#    ami = "ami-0c956e207f9d113d5" # eu-central-1
#    ami = "ami-01977e30682e5df74" # eu-north-1
    ami = "ami-0e34bbddc66def5ac" # eu-west-2
    instance_type = "t2.micro"
#    count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.de
#    key_name = "aml2" # You must create key

    tags = {
      Name = "Amazon Linux 2"
      OS = "Amazon Linux 2"
    }
}