# Phase 0 boilerplate — this block is fine to use as-is, it's not a learning objective.
# Everything you actually design (VPC, IAM, EKS, GPU nodes) goes in the other files in this
# directory.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

