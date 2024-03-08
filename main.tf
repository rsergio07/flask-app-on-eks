# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

# Create Subnets
resource "aws_subnet" "eks_subnets" {
  count                  = length(var.subnet_names)
  vpc_id                 = aws_vpc.eks_vpc.id
  cidr_block             = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_names[count.index]
  }
}

# Create Security Group
resource "aws_security_group" "eks_sg" {
  name   = var.security_group_name
  vpc_id = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name               = "eks-cluster-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

# Attach policy to IAM role allowing EKS cluster to manage worker nodes
resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
  name       = "eks-cluster-policy-attachment"
  roles      = [aws_iam_role.eks_cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach policy to IAM role allowing EKS to manage resources on your behalf
resource "aws_iam_policy_attachment" "eks_service_policy_attachment" {
  name       = "eks-service-policy-attachment"
  roles      = [aws_iam_role.eks_cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Create EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.eks_subnets[*].id
    security_group_ids = [aws_security_group.eks_sg.id]
  }
}

# Create ECR Repository
resource "aws_ecr_repository" "my_ecr_repo" {
  name = "my-ecr-repo"
}

# Data source to get availability zones
data "aws_availability_zones" "available" {}

# Data source to retrieve EKS cluster authentication details
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}
