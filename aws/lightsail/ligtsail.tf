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
  region = "us-west-2"
}

resource "aws_lightsail_instance" "server_nj" {
  name              = "server-nj"
  availability_zone = "us-west-2a"
  blueprint_id      = "nodejs"
  bundle_id         = "nano_2_0"
#  key_pair_name     = "some_key_name"
  user_data = file("install.sh")

  # provisioner "file" {
  #   source      = "~/files/test1.txt"
  #   destination = "/home/bitnami/"
  # }

  lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
  }

  tags = {
    foo = "bar"
    project = "nj"
  }
}

resource "aws_lightsail_instance_public_ports" "test" {
  instance_name = aws_lightsail_instance.server_nj.name

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }

    port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }

    port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }
}


resource "aws_lightsail_static_ip_attachment" "test" {
  static_ip_name = aws_lightsail_static_ip.static_ip.id
  instance_name  = aws_lightsail_instance.server_nj.id
}

resource "aws_lightsail_static_ip" "static_ip" {
  name = "example"
}