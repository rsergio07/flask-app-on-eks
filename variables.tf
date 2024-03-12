# Specifies the AWS region where resources will be provisioned
variable "region" {
  default = "us-east-1"
}

# Specifies the name of the Virtual Private Cloud (VPC) to be created for Amazon EKS
variable "vpc_name" {
  default = "vpc-for-eks"
}

# Specifies a list of subnet names for the Amazon EKS cluster
variable "subnet_names" {
  default = ["subnet-01-for-eks", "subnet-02-for-eks"]
}

# Specifies the name of the security group for the Amazon EKS cluster
variable "security_group_name" {
  default = "eks-security-group"
}

# Specifies the name of the Amazon EKS cluster
variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-eks-cluster"
}

# Specifies the name of the Amazon ECR repository
variable "ecr_repository_name" {
  description = "The name of the ECR repository"
  default     = "my-ecr-repo"
}

# Specifies the port on which the service will be exposed
variable "service_port" {
  description = "Port on which the service is exposed"
  type        = number
  default     = 5000
}
