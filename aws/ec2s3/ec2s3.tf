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
    vpc_security_group_ids = [ aws_security_group.kafka_al2.id ]
#    count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.de
    key_name = "terra" # You must create key

    tags = {
      Name = "AL2"
      OS = "Amazon Linux 2"
      Project = "Kafka"
    }
}

resource "aws_security_group" "kafka_al2" {
  name        = "WebServer Security Group"
  description = "SecurityGroup ports 80 443 22"
# vpc_id      = aws_vpc.main.id


dynamic "ingress" {
 for_each = ["8080", "22", "9092", "9093"]

   content    {
      description      = "ssh web"
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
    Name = "Security Group WebServer"
    MQ = "Kafka"
  }
}


resource "aws_s3_bucket" "mybucket" {
  bucket = "bucketname-kafka"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


# #### IAM policy
# resource "aws_iam_role_policy" "s3_one_bucket" {
#   name = "s3_one_bucket"
#   role = aws_iam_role.s3roleec2.id

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:GetObject",
#                 "s3:PutObject",
#                 "s3:PutObjectAcl"
#             ],
#             "Resource": "arn:aws:s3:::bucketname-kafka/*"
#         }
#     ]
#   })
# }

# #### IAM role
# resource "aws_iam_role" "s3roleec2" {
#   name = "s3roleec2"

#   assume_role_policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "ec2.amazonaws.com"
#             },
#             "Action": "sts:AssumeRole"
#         }
#       ]
#   })
# }