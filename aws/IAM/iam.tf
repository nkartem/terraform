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


#### IAM role
resource "aws_iam_role" "s3roleec2" {
  name = "s3roleec2"
  path = "/"


  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Sid": ""
            "Action": "sts:AssumeRole"
        }
      ]
  })
}


# #### IAM policy
resource "aws_iam_role_policy" "s3_one_bucket" {
  name = "s3_one_bucket"
  role = aws_iam_role.s3roleec2.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "*"
        }
    ]
  })
}

### IAM profile
resource "aws_iam_instance_profile" "s3roleec2_profile" {
  name = "s3roleec2_profile"
  role = aws_iam_role.s3roleec2.id
}