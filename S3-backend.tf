# Specifies the backend configuration for storing the Terraform state file in an S3 bucket
backend "s3" {
  bucket         = "rsergio-terraform-statefile-bucket"
  key            = "terraform.tfstate"
  region         = var.AWS_REGION
  dynamodb_table = "terraform-lock-table"
}
