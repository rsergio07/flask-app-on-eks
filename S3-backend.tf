# Specifies the backend configuration for storing the Terraform state file in an S3 bucket
terraform {
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "rsergio-terraform-statefile-bucket"
  }
}