terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# S3 backend file
terraform {
  backend "s3" {
    bucket = "aws-statefile-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}