variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "Region where create EKS"
}

variable "instance_types_ng" {
  default = "t3.medium"
  type    = string
}

variable "disk_size_ng" {
  default = 20
}

variable "vpc_name" {
  default = "k8s-vpc"
  type    = string
}

variable "aws_eks_cluster_name" {
  default = "example-k8s"
  type    = string
}