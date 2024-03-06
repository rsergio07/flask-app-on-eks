# Flask App Deployment on AWS EKS with Terraform

This project demonstrates how to deploy a Flask web application onto an AWS Elastic Kubernetes Service (EKS) cluster using Terraform for infrastructure provisioning.

## Files

- `main.tf`: Defines the Terraform resources for creating the EKS cluster, VPC, subnets, security group, and IAM role.
- `variables.tf`: Defines the variables used in the Terraform configuration.
- `providers.tf`: Configures the AWS provider for Terraform.
- `deployment.yaml` and `service.yaml`: Kubernetes YAML files defining the deployment and service for the Flask application.
- `Dockerfile`: Defines the Docker image for the Flask application.
- `app.py`: Python Flask application code.

## Prerequisites

Before you begin, ensure you have the following:

- An AWS account with appropriate permissions to create resources.
- Install Terraform and AWS CLI: Follow the installation instructions for your OS from the official documentation:
    https://www.terraform.io/ and https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

## Getting Started

To deploy the Flask application onto an AWS EKS cluster, follow these steps:

1. Clone this repository onto your local machine:

```bash
git clone https://github.com/rsergio07/flask-app-on-eks
```

2. Navigate to the directory containing the application files:

```bash
cd project-lab2
```

## Build and Push Docker Image

To build and push the Docker image to your ECR repository, follow these steps:

1. Build the Docker image:

```bash
docker build -t <image_name>:<image_tag> .
```

Replace `<image_name>` and `<image_tag>` with your desired values.

2. Push the image to your ECR repository:

```bash
docker push <image_repository_uri>/<image_name>:<image_tag>
```

Replace `<image_repository_uri>` with your ECR repository URI.

## Update deployment.yaml

After pushing the Docker image to your ECR repository, update the `deployment.yaml` file to replace the image name with the one you pushed to ECR.

## Deploy the Application

To deploy the application and service on the EKS cluster, use the following commands:

1. Apply the deployment configuration:

```bash
kubectl apply -f deployment.yaml
```

2. Apply the service configuration:

```bash
kubectl apply -f service.yaml
```

This will deploy and expose the application via a service on the EKS cluster.

## Terraform Setup

Before deploying the infrastructure, please ensure Terraform is installed on your local machine and AWS CLI is configured with appropriate permissions.

## Terraform Deployment Steps

To deploy the application infrastructure using Terraform, follow these steps:

1. Navigate to the directory containing the Terraform files:

```bash
cd project-lab2/terraform
```

2. Initialize the Terraform environment:

```bash
terraform init
```

3. Review the changes Terraform will make:

```bash
terraform plan
```

4. Apply the changes to create the EKS cluster and associated resources:

```bash
terraform apply
```

5. Wait for Terraform to finish creating the resources. This may take several minutes.

6. Once the resources are created, you should see an output indicating the name of the EKS cluster and the URL of the deployed Flask app service.

## Clean Up

To destroy the created resources and avoid incurring charges, run:

```bash
terraform destroy
```

## Feedback and Contributions

I welcome feedback, suggestions, and contributions. If you encounter issues or have ideas for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
