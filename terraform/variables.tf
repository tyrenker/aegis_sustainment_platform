# TODO (Phase 1): add variables as you need them (e.g., vpc_cidr, environment name,
# cluster_name). Don't pre-build a variable you don't have a use for yet — add them as each
# phase actually needs one.

variable "aws_region" {
  description = "AWS region for this environment"
  type        = string
  default     = "us-east-1"
}

variable "my_ip_cidr" {
  description = "Your current public IP in CIDR form (e.g. 1.2.3.4/32), for SSH access to scratch VMs. Set this in a local terraform.tfvars file (already gitignored) — never hardcode a real IP in a tracked .tf file."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the ASP VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "aegis-eks"
}

