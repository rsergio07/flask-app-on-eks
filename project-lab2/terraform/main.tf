# Ensure the security group and VPC are associated
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"  # Adjust as needed
}

# Create subnets in different availability zones
resource "aws_subnet" "public_subnet" {
  count = 2
  cidr_block = format("10.0.%d.0/24", count.index + 1)
  vpc_id = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

# Create a security group associated with the VPC
resource "aws_security_group" "cluster_sg" {
  name = "eks-cluster-sg"
  description = "Security group for the EKS cluster"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an IAM role for the cluster
resource "aws_iam_role" "cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach managed policies to the IAM role
resource "aws_iam_role_policy_attachment" "cluster_role_attachment" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create an EKS cluster
resource "aws_eks_cluster" "cluster" {
  name          = var.cluster_name
  role_arn      = aws_iam_role.cluster_role.arn
  vpc_config {
    security_group_ids = [aws_security_group.cluster_sg.id]
    subnet_ids        = aws_subnet.public_subnet.*.id
  }
}

data "aws_availability_zones" "available" {}
