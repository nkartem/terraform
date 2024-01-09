data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}


########################################################
########################################################

resource "aws_eks_cluster" "example" {
  name     = var.aws_eks_cluster_name
  role_arn = "arn:aws:iam::1234567890:role/AmazonEKSCluster_PersonDevOps"

  vpc_config {
    security_group_ids = [ aws_security_group.eks_cluster_sg_emulations.id ]
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = [aws_subnet.k8s_subnet_private1_eu_west_1a.id, aws_subnet.k8s_subnet_private2_eu_west_1b.id, 
                  aws_subnet.k8s_subnet_public1_eu_west_1a.id, aws_subnet.k8s_subnet_public2_eu_west_1b.id]
  }
}

output "endpoint" {
  value = aws_eks_cluster.example.endpoint
}


resource "aws_eks_addon" "vpccni" {
  cluster_name                = aws_eks_cluster.example.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.14.1-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name                = aws_eks_cluster.example.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.28.1-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

# resource "aws_eks_addon" "coredns" {
#   cluster_name                = aws_eks_cluster.example.name
#   addon_name                  = "coredns"
#   addon_version               = "v1.10.1-eksbuild.2"
#   resolve_conflicts_on_update = "PRESERVE"
# }

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name                = aws_eks_cluster.example.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = "v1.0.0-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}


resource "aws_eks_node_group" "ng2" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "ng2"
  disk_size = var.disk_size_ng
  ami_type = "AL2_x86_64"
  instance_types = [var.instance_types_ng]
  node_role_arn   = "arn:aws:iam::1234567890:role/AmazonEKSNodeRole_PersonDevOps" 
  subnet_ids      = [aws_subnet.k8s_subnet_public1_eu_west_1a.id]
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
}