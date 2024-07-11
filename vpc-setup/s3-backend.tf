terraform {
  backend "s3" {
    bucket = "aws-statefile-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}