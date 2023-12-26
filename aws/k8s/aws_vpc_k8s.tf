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


resource "aws_vpc" "k8s" {
  cidr_block = "10.20.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "k8s"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s.id
  tags = {
    Name = "k8s-igw"
  }
}


resource "aws_subnet" "k8s_subnet_public1_eu_west_1a" {
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = "10.20.0.0/20"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                            = "public1-eu-west-1a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cleuter/demo-2"    = "owned"
  }
}

resource "aws_subnet" "k8s_subnet_private1_eu_west_1a" {
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = "10.20.128.0/20"
  availability_zone = "eu-west-1a"

  tags = {
    "Name"                            = "private1-eu-west-1a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cleuter/demo-2"    = "owned"
  }
}

resource "aws_subnet" "k8s_subnet_public2_eu_west_1b" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.20.16.0/20"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                         = "public2-eu-west-1a"
    "kubernetes.io/role/elb"       = "1"
    "kubernetes.io/cleuter/demo-2" = "owned"
  }
}

resource "aws_subnet" "k8s_subnet_private2_eu_west_1b" {
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = "10.20.144.0/20"
  availability_zone       = "eu-west-1b"

  tags = {
    "Name"                         = "private2-eu-west-1b"
    "kubernetes.io/role/elb"       = "1"
    "kubernetes.io/cleuter/demo-2" = "owned"
  }
}






resource "aws_route_table" "k8s_rtb_public" {
  vpc_id = aws_vpc.k8s.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "k8s-rtb-public"
    network = "public and local"
  }
}

resource "aws_route_table_association" "k8s_subnet_public1_eu_west_1a" {
  subnet_id      = aws_subnet.k8s_subnet_public1_eu_west_1a.id
  route_table_id = aws_route_table.k8s_rtb_public.id
}


resource "aws_route_table_association" "k8s_subnet_public2_eu_west_1b" {
  subnet_id      = aws_subnet.k8s_subnet_public2_eu_west_1b.id
  route_table_id = aws_route_table.k8s_rtb_public.id
}



resource "aws_route_table" "k8s_rtb_private1_eu_west_1a" {
    vpc_id = aws_vpc.k8s.id

  
  tags = {
    Name = "k8s_rtb_private1_eu_west_1a"
    network = "local"
  }
}

resource "aws_route_table_association" "k8s_subnet_private1_eu_west_1a" {
  subnet_id      = aws_subnet.k8s_subnet_private1_eu_west_1a.id
  route_table_id = aws_route_table.k8s_rtb_private1_eu_west_1a.id
}


resource "aws_route_table" "k8s_rtb_private2_eu_west_1b" {
    vpc_id = aws_vpc.k8s.id

  
  tags = {
    Name = "k8s_rtb_private2_eu_west_1a"
    network = "local"
  }
}

resource "aws_route_table_association" "k8s_subnet_private2_eu_west_1b" {
  subnet_id      = aws_subnet.k8s_subnet_private2_eu_west_1b.id
  route_table_id = aws_route_table.k8s_rtb_private2_eu_west_1b.id
}






##### Security group #####

resource "aws_security_group" "eks_cluster_sg_emulations" {
  name        = "eks-cluster-sg-emulations"
  description = "KS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  vpc_id      = aws_vpc.k8s.id

dynamic "ingress" {
 for_each = ["5066","5022"]

    content    {
      description      = "Asterisk"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}

dynamic "ingress" {
 for_each = ["9300", "9200"]

    content    {
      description      = "elasticsearch"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      #cidr_blocks = eks_cluster_sg_emulations.id
    }
}

  ingress    {
      description      = "Asterisk"
      from_port        = 10000
      to_port          = 20000
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress    {
      description      = "phpmyadmin"
      from_port        = 32511
      to_port          = 32511
      protocol         = "tcp"
      cidr_blocks      = ["1.2.3.4/32"]
  }

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "eks-cluster-sg-emulations"
    aws-eks-cluster-name = "emulations"
    owner = "kubernetes.io/cluster/emulations"
  }
}


resource "aws_security_group" "k8s-nfs-sg" {
  name        = "k8s-nfs-sg"
  description = "k8s-nfs-sg"
  vpc_id      = aws_vpc.k8s.id

  ingress    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["80.82.31.110/32", "212.90.172.68/32", "54.80.194.73/32"]
  }

  ingress    {
      description      = "NFS"
      from_port        = 2049
      to_port          = 2049
      protocol         = "tcp"
      cidr_blocks      = ["10.20.0.0/16"]
  }

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "k8s-nfs-sg"
  }
}