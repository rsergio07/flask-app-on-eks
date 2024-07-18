## Flask App Deployment on AWS EKS with Terraform and GitHub Actions

This project demonstrates how to deploy a Flask web application onto an AWS Elastic Kubernetes Service (EKS) cluster using Terraform for infrastructure provisioning.

## Project Structure v2

The project contains the following files:

- `main.tf`: Terraform configuration file for provisioning AWS infrastructure.
- `variables.tf`: Terraform variables file containing variables used in the main configuration.
- `output.tf`: Terraform output file containing output variables to display after deployment.
- `deployment.yaml`: Kubernetes Deployment manifest file for deploying the REST API application.
- `service.yaml`: The Kubernetes Service manifest file exposes the REST API as a service.
- `eks-deploy.yml`: Kubernetes manifest file for deploying the REST API application using GitHub Actions.

Additionally, the project contains the following application files:

- `Dockerfile`: Dockerfile is used to build the Docker image of the REST API.
- `app.py`: Python script containing the code for the simple REST API application.

## Terraform Configuration (`main.tf`)

This file defines the infrastructure components required for AWS EKS deployment, including VPC, subnets, security groups, IAM roles, EKS cluster, ECR repository, and EKS node group.

## Terraform Variables (`variables.tf`)

This file defines Terraform variables used to customize the AWS infrastructure, such as region, VPC name, subnet names, security group name, cluster name, ECR repository name, and service port.

## Terraform Outputs (`outputs.tf`)

This file defines Terraform output variables to display after deployment. This project defines the URL of the deployed Flask app.

## Deployment Workflow (`eks-deploy.yml`)

This GitHub Actions workflow file automates the deployment process. It checks out the code, sets up AWS CLI, installs Terraform, initializes Terraform, validates Terraform configuration, applies Terraform changes, updates kubeconfig, builds the Docker image, pushes the Docker image to Amazon ECR, and deploys the REST API app to EKS.

## Docker Configuration (`Dockerfile`)

The Dockerfile specifies the Docker image configuration for the REST API application. It installs Python dependencies and exposes port 5000 for the Flask application.

## REST API Application (`app.py`)

This Python script contains the code for a simple REST API application built with Flask. It defines endpoints for retrieving store information.

## Kubernetes Manifests (`deployment.yaml` and `service.yaml`)

These YAML files define the Kubernetes Deployment and Service manifests for deploying the REST API application on EKS. The Deployment specifies the container image, ports, and replicas, while the Service exposes the application as a load-balanced service.

## Prerequisites

"Please review the prerequisites page."

## GitHub Actions Secrets

Ensure the following secrets are configured in your GitHub repository:

- `AWS_ACCESS_KEY_ID`: AWS access key ID with permissions to provision resources.
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key corresponding to the access key ID.
- `AWS_REGION`: AWS region where resources will be provisioned.
- `AWS_ACCOUNT_ID`: AWS account ID is used to push the Docker image to ECR.

## Deployment Steps

1. Clone this repository.
2. Configure the GitHub Actions secrets.
3. Update the Terraform variables in `variables.tf` as needed.
4. Push changes to your branch to trigger the deployment workflow.
5. Monitor the GitHub Actions workflow for any errors or failures.
6. Once the deployment workflow is successful, move to the next steps

## Update `kubectl` Configuration

Update your `kubectl` configuration to connect to the Amazon EKS cluster using the following command:

```bash
aws eks --region <region> update-kubeconfig --name <cluster-name>
```

Replace `<region>` with your AWS region and `<cluster-name>` with the name of your Amazon EKS cluster.

## Verify Deployment

Verify that the deployment was successful by checking the status of the pods and services using the following commands:

```bash
kubectl get pods
kubectl get svc my-rest-api-service
```

## Access the API

Once the service is successfully deployed and has an external IP address, you can access the API using the provided external IP.

## Clean Up

You need to trigger the destroy workflow to remove the previously created resources. This process is irreversible, so make sure that you want to remove the resources completely before triggering the destroy workflow.

## Feedback and Contributions

I welcome feedback, suggestions, and contributions. If you encounter issues or have ideas for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
