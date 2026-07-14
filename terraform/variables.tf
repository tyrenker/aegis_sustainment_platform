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

variable "stig_benchmark_path" {
  description = "Local path to the downloaded DISA STIG SCAP benchmark XML (e.g. ~/Downloads/U_RHEL_9_V2R9_STIG_SCAP_1-3_Benchmark.xml). Set this in a local terraform.tfvars file (already gitignored) — the path is specific to your machine, so it shouldn't be hardcoded in a tracked .tf file."
  type        = string
}

variable "ssh_private_key_path" {
  description = "Local path to the private key used to SSH into the STIG scratch VM (e.g. ~/.ssh/aegis-lab.pem). Set this in a local terraform.tfvars file (already gitignored)."
  type        = string
  default     = "~/.ssh/aegis-lab.pem"
}

