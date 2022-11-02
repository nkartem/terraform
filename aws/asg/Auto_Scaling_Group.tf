 terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58.0"
    }
  }
}

## Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}


## Launch templates
resource "aws_launch_template" "nametmpl" {
  name                    = "mytmpl"
  description             = "mytmplapp"
  image_id                = "ami-08e2d37b6a0129927"
  instance_type           = "t1.micro"
  vpc_security_group_ids  = [aws_security_group.name_security_group1.id]
  ###subnet-08605e280d29b8494
  key_name = "ssh1"
  user_data = filebase64("${path.module}/install.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
      OS   = "AL2"
      app  = "nginx"
    }
  }
}

## Autoscaling Group
resource "aws_autoscaling_group" "asgname" {
  name = "asg"
  desired_capacity   = 1
  min_size           = 1
  max_size           = 3
  health_check_grace_period = 300
  force_delete              = false
  force_delete_warm_pool    = false
  wait_for_capacity_timeout = "10m"
#  vpc_zone_identifier = aws_instance.server1
#  vpc_security_group_ids = aws_security_group.name_security_group1.id
#  availability_zones = "us-west-2b"
  vpc_zone_identifier = [ aws_subnet.name_private_subnet.id ]


  launch_template {
    id      = aws_launch_template.nametmpl.id
    version = "$Latest"
  }
}

# resource "aws_autoscaling_policy" "example" {
#   name = "target-tracking-policy"
#   estimated_instance_warmup = 300
#   autoscaling_group_name = aws_autoscaling_group.asgname.id
#   policy_type               = "TargetTrackingScaling"

#   target_tracking_configuration {
#         disable_scale_in = false
#         target_value     = 50

#         predefined_metric_specification {
#             predefined_metric_type = "ASGAverageCPUUtilization"
#             }
#         }

# }

######################################################

# Create VPC
resource "aws_vpc" "name_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "name-vpc-terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "name_igw" {
  vpc_id = aws_vpc.name_vpc.id

  tags = {
    Name = "Internet Gateway Terraform"
  }
}

# Create subnet
resource "aws_subnet" "name_public_subnet" {
  availability_zone = "us-west-2a"
  vpc_id     = aws_vpc.name_vpc.id
  cidr_block = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "name_private_subnet" {
  availability_zone = "us-west-2b"
  vpc_id     = aws_vpc.name_vpc.id
  cidr_block = "10.10.2.0/24"

  tags = {
    Name = "Private"
  }
}

resource "aws_subnet" "name_database_subnet" {
  availability_zone = "us-west-2b"
  vpc_id     = aws_vpc.name_vpc.id
  cidr_block = "10.10.3.0/24"

  tags = {
    Name = "Database"
  }
}

# Create Route Table
resource "aws_route_table" "name_route_table_public" {
  vpc_id = aws_vpc.name_vpc.id

  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name_igw.id
  }

  tags = {
    Name = "name_route_table_public"
  }
}

resource "aws_route_table" "name_route_table_private" {
  vpc_id = aws_vpc.name_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.name_nat_gateway.id
  }
  
  tags = {
    Name = "name_route_table_private"
  }
}

resource "aws_route_table" "name_route_table_database" {
  vpc_id = aws_vpc.name_vpc.id

  route = []
  
  tags = {
    Name = "name_route_table_database"
  }
}

# association route table whith  subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.name_public_subnet.id
  route_table_id = aws_route_table.name_route_table_public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.name_private_subnet.id
  route_table_id = aws_route_table.name_route_table_private.id
}

resource "aws_route_table_association" "database" {
  subnet_id      = aws_subnet.name_database_subnet.id
  route_table_id = aws_route_table.name_route_table_database.id
}

# Create Elastic IP
resource "aws_eip" "eip1" {
}


# Create NAT Gateway
resource "aws_nat_gateway" "name_nat_gateway" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.name_public_subnet.id
  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.name_igw]
}



###Create security group
resource "aws_security_group" "name_security_bastion" {
  name        = "Bastion Security Group"
  description = "SecurityGroup ports 22 3389"
  vpc_id      = aws_vpc.name_vpc.id

  ingress    {
      description      = "open port ssh 22"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }
  

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Security Group for Bastion server"
  }
}


resource "aws_security_group" "name_security_group_kamailio" {
  name        = "Kamailio Security Group"
  description = "SecurityGroup ports 22 5060 5061"
  vpc_id      = aws_vpc.name_vpc.id

dynamic "ingress" {
 for_each = ["22","25","443","5060","5061","5222","5280","5269","1234","5672","11211","80"]

    content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}

dynamic "ingress" {
 for_each = ["5050","5060","5061","53","69"]

    content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}

  ingress    {
      description      = "open port 10000-20000"
      from_port        = 10000
      to_port          = 20000
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress    {
      description      = "open port  4000-5999"
      from_port        = 4000
      to_port          = 5999
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Security Group for Kamailio"
  }
}



resource "aws_security_group" "name_security_group_asterisk" {
  name        = "Asterisk Security Group"
  description = "SecurityGroup ports 22 5060 5061 4569 5036 2727"
  vpc_id      = aws_vpc.name_vpc.id

dynamic "ingress" {
 for_each = ["22","5060","5061","4569","5036","2727"]

   content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}

  ingress    {
      description      = "open port  10000-20000"
      from_port        = 10000
      to_port          = 20000
      protocol         = "udp"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Security Group for Asterisk"
  }
}


resource "aws_security_group" "name_security_group1" {
  name        = "SomeName-1 Security Group"
  description = "SecurityGroup ports 22 443 80 8080"
  vpc_id      = aws_vpc.name_vpc.id

dynamic "ingress" {
 for_each = ["22","443","8080", "80"]

   content    {
      description      = "open ports"
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
    Name = "Security Group for SomeName1"
  }
}

resource "aws_security_group" "name_security_group2" {
  name        = "SomeName-2 Security Group"
  description = "SecurityGroup ports 22 21 3389"
  vpc_id      = aws_vpc.name_vpc.id

dynamic "ingress" {
 for_each = ["22","21"]

   content    {
      description      = "open ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
   }
}

  ingress    {
      description      = "open port RDP 3389"
      from_port        = 3389
      to_port          = 3389
      protocol         = "tcp"
      cidr_blocks      = ["79.81.32.25/32"]
  }

  egress    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Security Group for SomeName2"
  }
}
###################################################################

######## Create EC2 instans ############################

resource "aws_instance" "bastion" {
    ami                   = "ami-08e2d37b6a0129927"
    instance_type         = "t1.micro"
    subnet_id   = aws_subnet.name_public_subnet.id
    count = 1 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.
    vpc_security_group_ids = [ aws_security_group.name_security_bastion ]
#    user_data = file("kamailio.sh")
    key_name = "ssh1"

lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
}
    tags = {
      Name = "Bastion"
      Subnet = "Public"
      OS = "Amazon Linux 2"
      Project = "name Project"
      Terraform = "Yes"
    }
}


resource "aws_instance" "kamailio" {
    ami                   = "ami-08e2d37b6a0129927"
    instance_type         = "t1.micro"
    subnet_id   = aws_subnet.name_private_subnet.id
    count = 2 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.
    vpc_security_group_ids = [ aws_security_group.name_security_group_kamailio.id ]
#    user_data = file("kamailio.sh")
    key_name = "ssh1"

lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
}
    tags = {
      Name = "Kamailio"
      Subnet = "Public"
      OS = "Amazon Linux 2"
      Project = "name Project"
      Terraform = "Yes"
    }
}



resource "aws_instance" "asterisk" {
    ami                   = "ami-08e2d37b6a0129927"
    instance_type         = "t1.micro"
    subnet_id   = aws_subnet.name_private_subnet.id
#   count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.
    vpc_security_group_ids = [ aws_security_group.name_security_group_asterisk.id]
#    user_data = file("script.sh")
    key_name = "ssh1"

lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
}
    tags = {
      Name = "asterisk"
      Subnet = "Private"
      OS = "Amazon Linux 2"
      Project = "name Project"
      Terraform = "Yes"
    }
}





resource "aws_instance" "server1" {
    ami                   = "ami-08e2d37b6a0129927"
    instance_type         = "t1.micro"
    subnet_id   = aws_subnet.name_private_subnet.id
#   count = 3 //the number of servers to create. To delete an instance, enter 0 or use the "terraform destroy" command.
    vpc_security_group_ids = [ aws_security_group.name_security_bastion.id ]
#    user_data = file("script.sh")
    key_name = "ssh1"

lifecycle {
#  privent_destroy = true //can not destroy resource
  create_before_destroy = true //  create a new instance and then remove old
}
    tags = {
      Name = "server1-app"
      Subnet = "Private"
      OS = "Amazon Linux 2"
      Project = "name Project"
      Terraform = "Yes"
    }
}

############### EBS ############
resource "aws_ebs_volume" "example" {
  availability_zone = "us-west-2b"
  type = "io2"
  size = 5
  iops = 100

  tags = {
    Name = "Share"
    Project = "asg"
  }
}

########## RDS #############
module "cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name           = "test-aurora-db-postgres96"
  engine         = "aurora-postgresql"
  engine_version = "11.12"
  instance_class = "db.t4g.medium"
  instances = {
    one = {}
    2 = {
      instance_class = "db.t4g.medium"
    }
  }

  vpc_id = aws_vpc.name_vpc.id
  subnets = aws_subnet.name_database_subnet.id

  allowed_security_groups = [ aws_security_group.name_security_group2.id ]
#  allowed_cidr_blocks     = ["10.20.0.0/20"]

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  db_parameter_group_name         = "default"
  db_cluster_parameter_group_name = "default"

  #enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}



##########  CloudWatch ############
resource "aws_cloudwatch_metric_alarm" "CPU-Hight" {
  alarm_name                = "CPU-Hight"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = "1"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors autoscaling cpu utilization"
  #insufficient_data_actions = ["arn:aws:autoscaling:us-west-2:477686778249:scalingPolicy:1e7b0c9c-ebdb-484f-8d7b-2197c5989ded:autoScalingGroupName/asterisk:policyName/Add-CPU-High",]
  insufficient_data_actions = []
  dimensions                = {
         "AutoScalingGroupName" = "asterisk"
        }
# id                        = "CPU-Hight"
  tags                      = {}
}

resource "aws_cloudwatch_metric_alarm" "CPU-Low" {
  alarm_name                = "CPU-Low"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = "3"
  evaluation_periods        = "3"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "30"
  alarm_description         = "This metric monitors autoscaling cpu utilization"
  insufficient_data_actions = []
  dimensions                = {
         "AutoScalingGroupName" = "asterisk"
        }
# id                        = "CPU-Low"
  tags                      = {}
}