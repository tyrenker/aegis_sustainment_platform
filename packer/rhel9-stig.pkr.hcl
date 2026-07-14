# This wrapper shape is fine to use as-is — it's infra tooling, not your learning objective.
# Your actual work is in ../ansible/stig-remediation.yml.

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "rhel9" {
  ami_name = "aegis-rhel9-stig-{{timestamp}}"
  # t3.micro (1GiB) OOM-kills dnf during its first-ever metadata/cache sync on a fresh
  # instance, even for a small package — same failure mode as the earlier scratch-VM install.
  # This only affects the temporary build instance (a few minutes, a few cents), not anything
  # about the resulting AMI or what instance types can later boot from it.
  instance_type = "t3.small"
  region        = "us-east-1"
  source_ami_filter {
    filters     = { name = "RHEL-9*", virtualization-type = "hvm" }
    owners      = ["309956199498"] # Red Hat's official AMI owner ID
    most_recent = true
  }
  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.rhel9"]
  provisioner "ansible" {
    playbook_file = "../ansible/stig-remediation.yml"
  }
}
