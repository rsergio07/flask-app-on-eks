# Defines an output block to represent the URL of the deployed Flask app
output "app_url" {
  value       = format("%s:%d", aws_eks_cluster.my_cluster.endpoint, var.service_port)
  description = "URL of the deployed Flask app"
}
