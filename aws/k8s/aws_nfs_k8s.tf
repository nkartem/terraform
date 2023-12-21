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
  region = "eu-west-1"
}



resource "aws_instance" "k8s_nfs" {
    ami                   = "ami-09e67e426f25ce0d7"
    instance_type         = "t3.micro"
#   count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.
    vpc_security_group_ids = [ aws_security_group.k8s-nfs-sg.id ]
    user_data = file("nfs.sh")
    vpc_id = aws_vpc.k8s.id
#    key_name = "ssh"

lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
}
    tags = {
      Name = "k8s-nfs"
      OS = "RHEL8"
      Project = "k8s"
    }
}

resource "aws_eip" "static_ip" {
  instance=aws_instance.k8s_nfs.id
}

