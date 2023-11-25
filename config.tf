
provider "aws" {
  region = "us-east-1"
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "bucket-terraform-projeto12345"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    profile = "terraform"
  }
}


