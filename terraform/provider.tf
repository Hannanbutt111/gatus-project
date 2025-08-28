terraform {
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket  = "hannan-terraformstate-bucket"
    key     = "ecs/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
