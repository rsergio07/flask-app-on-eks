variable "region" {
    default = "us-east-1"
}

variable "vpc_name" {
    default = "vpc-for-eks"
}

variable "subnet_names" {
    default = ["subnet-01-for-eks", "subnet-02-for-eks"]
}

variable "security_group_name" {
  default = "eks-security-group"
}

variable "cluster_name" {
    default = "my-eks-cluster"
}

variable "repository_name" {
    default = "my-ecr-repo"
}

variable "service_port" {
    description = "Port on which the service is exposed"
    type        = number
    default     = 5000
}