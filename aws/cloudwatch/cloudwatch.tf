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


##########  CloudWatch ############
resource "aws_cloudwatch_metric_alarm" "CPU-Hight" {
  alarm_name                = "CPU-Hight"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = "2"
  evaluation_periods        = "3"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors autoscaling cpu utilization"
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