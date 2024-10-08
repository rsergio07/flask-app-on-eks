# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Specifies the backend configuration for storing the Terraform state file in an S3 bucket
terraform {
  backend "s3" {
    bucket = "rsergio-terraform-statefile-bucket"
    key    = "terraform.tfstate"
    region = var.region
  }
}

# Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

# Data source to get availability zones
data "aws_availability_zones" "available" {}

# Create Subnets
resource "aws_subnet" "eks_subnets" {
  count                   = length(var.subnet_names)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_names[count.index]
  }
}

# Create Security Group
resource "aws_security_group" "eks_sg" {
  name   = var.security_group_name
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Route traffic for each subnet in the Amazon EKS VPC
resource "aws_route_table" "subnet_route_table" {
  count = length(aws_subnet.eks_subnets)

  vpc_id = aws_vpc.eks_vpc.id
}

# Create Route traffic from each subnet to the Internet Gateway
resource "aws_route" "subnet_route_to_internet_gateway" {
  count                  = length(aws_subnet.eks_subnets)
  route_table_id         = aws_route_table.subnet_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Associate Subnets with Route Tables
resource "aws_route_table_association" "subnet_association" {
  count          = length(aws_subnet.eks_subnets)
  subnet_id      = aws_subnet.eks_subnets[count.index].id
  route_table_id = aws_route_table.subnet_route_table[count.index].id
}

# Create IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : ["eks.amazonaws.com"]
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

# Attach Policy to IAM Role, allowing Kubernetes the permissions required to manage resources
resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
  name       = "eks-cluster-policy-attachment"
  roles      = [aws_iam_role.eks_cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach Policy to IAM Role, allowing ECS to create and manage the necessary resources to operate EKS Clusters
resource "aws_iam_policy_attachment" "eks_service_policy_attachment" {
  name       = "eks-service-policy-attachment"
  roles      = [aws_iam_role.eks_cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Create EKS Cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = aws_subnet.eks_subnets[*].id
    security_group_ids      = [aws_security_group.eks_sg.id]
    endpoint_private_access = false
    endpoint_public_access  = true
  }
}

# Create ECR Repository
resource "aws_ecr_repository" "my_ecr_repo" {
  name = var.ecr_repository_name
}

# Create IAM Role for the Nodes
resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach Policies to the IAM Role
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# Attach Policies to the IAM Role
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# Attach Policies to the IAM Role
resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Create EKS Node Group
resource "aws_eks_node_group" "my_cluster_nodes" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-cluster-nodes"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = aws_subnet.eks_subnets[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.micro"]
}
