## Flask App Deployment on AWS EKS with Terraform and GitHub Actions

This project demonstrates how to deploy a Flask web application onto an AWS Elastic Kubernetes Service (EKS) cluster using Terraform for infrastructure provisioning.

## Files

- `main.tf`: Defines the Terraform resources for creating the EKS cluster, VPC, subnets, security group, and IAM role.
- `variables.tf`: Defines the variables used in the Terraform configuration.
- `providers.tf`: Configures the AWS provider for Terraform.
- `outputs.tf`: Provides information about the deployed infrastructure.
- `deployment.yaml`: Defines how Kubernetes should manage the lifecycle of your application's pods.
- `service.yaml`: Defines how clients can access the application running in the Kubernetes cluster.
- `Dockerfile`: Defines the Docker image for the Flask application.
- `app.py`: Python Flask application code.
- `deploy.yml`: GitHub Actions workflow file responsible for automating the application's deployment process.

## Prerequisites

Before you begin, ensure you have the following:

- An AWS account with appropriate permissions to create resources.
- Install kubectl `https://kubernetes.io/docs/tasks/tools/`
- Install Terraform `https://developer.hashicorp.com/terraform/install?product_intent=terraform`
- Install AWS CLI `https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html`

# Getting Started

To deploy the Flask application onto an AWS EKS cluster, follow these steps:

## Clone this repository onto your local machine:

```bash
git clone https://github.com/rsergio07/flask-app-on-eks
```

## Navigate to the directory containing the application files:

```bash
cd project-lab2
```

## Create an ECR Repository

```bash
aws ecr create-repository --repository-name <repository_name>
```

- Replace `<repository_name>` with your desired **ECR repository name**.

## Login to ECR

```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.your-region.amazonaws.com
```

- Replace `<your-region>` with your **AWS region** (e.g., `us-east-1`).
- Replace `<your-account-id>` with your **AWS account ID**.
  
# Build Docker Image

```bash
docker build -t <image_name>:<image_tag> .
```

- Replace `<image_name>` and `<image_tag>` with your desired image name and tag.

## Tag the Image

```bash
docker tag <image_name>:<image_tag> <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<repository_name>:<image_tag>
```

Ensure you use the same values for `<image_name>` and `<image_tag>` as in the previous step.

- Replace `<your-account-id>` with your **AWS account ID**.
- Replace `<your-region>` with your **AWS region** (e.g., `us-east-1`).
- Replace `<repository_name>` with your **ECR repository name**.
- Replace `<image_tag>` with the **tag** you specified earlier.

## Push Image to ECR

```bash
docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<repository_name>:<image_tag>
```

- Replace `<your-account-id>` with your **AWS account ID**.
- Replace `<your-region>` with your **AWS region** (e.g., `us-east-1`).
- Replace `<repository_name>` with your **ECR repository name**.
- Replace `<image_tag>` with the **tag** you specified earlier.

## Update deployment.yaml

After pushing the Docker image to your ECR repository, update the `deployment.yaml` file to replace the image name with the one you pushed to ECR.

# Deploy the Application

To deploy the application and service on the EKS cluster, use the following commands:

## Apply the deployment configuration:

```bash
kubectl apply -f deployment.yaml
```

## Apply the service configuration:

```bash
kubectl apply -f service.yaml
```

This will deploy and expose the application via a service on the EKS cluster.

# Terraform Setup

Before deploying the infrastructure, please ensure Terraform is installed on your local machine and AWS CLI is configured with appropriate permissions.

## Terraform Deployment Steps

To deploy the application infrastructure using Terraform, follow these steps:

## Navigate to the directory containing the Terraform files:

```bash
cd project-lab2/terraform
```

## Initialize the Terraform environment:

```bash
terraform init
```

## Review the changes Terraform will make:

```bash
terraform plan
```

## Apply the changes to create the EKS cluster and associated resources:

```bash
terraform apply
```

## Wait for Terraform to finish creating the resources. This may take several minutes.

# Access the application

The output from `terraform apply` should provide the service URL. You can access your application using this URL.

## Clean Up

To destroy the created resources and avoid incurring charges, run:

```bash
terraform destroy
```

## Feedback and Contributions

I welcome feedback, suggestions, and contributions. If you encounter issues or have ideas for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
