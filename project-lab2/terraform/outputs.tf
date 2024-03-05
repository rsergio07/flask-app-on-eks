# Output information about the deployed infrastructure
output "cluster_name" {
  value       = aws_eks_cluster.cluster.name
  description = "Name of the EKS cluster"
}

output "service_url" {
  value = format("${aws_eks_cluster.cluster.endpoint}:%d", var.service_port)  # Use endpoint attribute
  description = "URL of the deployed Flask app service"
}
