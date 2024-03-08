## Flask App Deployment on AWS EKS with Terraform and GitHub Actions

This project demonstrates how to deploy a Flask web application onto an AWS Elastic Kubernetes Service (EKS) cluster using Terraform for infrastructure provisioning.

## Project Structure

The project contains the following files and directories:

- `main.tf`: Terraform configuration file for provisioning AWS infrastructure.
- `variables.tf`: Terraform variables file containing variables used in the main configuration.
- `output.tf`: Terraform output file containing output variables to display after deployment.
- `deployment.yaml`: Kubernetes Deployment manifest file for deploying the REST API application.
- `service.yaml`: The Kubernetes Service manifest file exposes the REST API as a service.

Additionally, the project contains the following application files:

- `Dockerfile`: Dockerfile is used to build the Docker image of the REST API.
- `app.py`: Python script containing the code for the simple REST API application.

## Deployment Steps

To deploy the application to Amazon EKS, follow these steps:

1. **Clone the Repository**: Clone this repository to your local machine.

2. **Set Up AWS Credentials**: Ensure you have AWS credentials configured with appropriate permissions for provisioning resources. You can set up AWS credentials using the AWS CLI or by configuring environment variables.

3. **Run Terraform**: Navigate to the cloned repository directory and run the following commands to deploy the infrastructure using Terraform:

    ```bash
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

4. **Build and Push Docker Image**: Build the Docker image of the REST API application and push it to Amazon ECR (Elastic Container Registry) using the following commands:

    ```bash
    docker build -t my-rest-api .
    docker tag my-rest-api:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-ecr-repo:latest
    aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
    docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-ecr-repo:latest
    ```

    Replace `<aws_account_id>` with your AWS account ID and `<region>` with your AWS region.

5. **Update `kubectl` Configuration**: Update your `kubectl` configuration to connect to the Amazon EKS cluster using the following command:

    ```bash
    aws eks --region <region> update-kubeconfig --name <cluster-name>
    ```

    Replace `<region>` with your AWS region and `<cluster-name>` with the name of your Amazon EKS cluster.

6. **Deploy Kubernetes Resources**: Deploy the Kubernetes resources (Deployment and Service) using the following commands:

    ```bash
    kubectl apply -f deployment.yaml
    kubectl apply -f service.yaml
    ```

7. **Verify Deployment**: Verify that the deployment was successful by checking the status of the pods and services using the following commands:

    ```bash
    kubectl get pods
    kubectl get svc my-rest-api-service
    ```

8. **Access the API**: Once the service is successfully deployed and has an external IP address, you can access the API using the provided external IP.

## Clean Up

To destroy the created resources and avoid incurring charges, run:

```bash
terraform destroy -auto-approve
```

## Feedback and Contributions

I welcome feedback, suggestions, and contributions. If you encounter issues or have ideas for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
