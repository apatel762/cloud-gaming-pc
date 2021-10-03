terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.1.0"
    }
  }

  required_version = ">= 1.0.7"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  # default_tags {
  #   tags = var.resource_tags
  # }
}