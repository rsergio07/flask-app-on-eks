terraform {
  backend "s3" {
    bucket = "rsergio-terraform-statefile-bucket"
    key    = "terraform.tfstate"
    region = var.AWS_REGION
  }
}
