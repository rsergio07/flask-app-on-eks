output "cluster_endpoint" {
    value = aws_eks_cluster.cluster.endpoint
    description = "Endpoint of the EKS cluster"
}

output "cluster_name" {
    value = aws_eks_cluster.cluster.name
    description = "Name of the EKS cluster"
}

output "service_url" {
    value = format("%s:%d", aws_eks_cluster.cluster.endpoint, var.service_port)
    description = "URL of the deployed Flask app service"
}
