# Define variables for customization
variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  default     = "us-east-1" # Replace with your desired AWS region
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  default     = "flask-app-cluster"
}

variable "image_name" {
  description = "Name for the Docker image"
  default     = "flask-app"
}

variable "image_tag" {
  description = "Tag for the Docker image"
  default     = "latest"
}

variable "service_port" {
  description = "Port for the Flask app service"
  default     = 5000
}
