# Internet Gateway ID
output "internet_gateway_id" {
  value = aws_internet_gateway.my_igw.id
}

# URL of the deployed Flask app
output "app_url" {
  value       = format("%s:%d", aws_eks_cluster.my_cluster.endpoint, var.service_port)
  description = "URL of the deployed Flask app"
}
