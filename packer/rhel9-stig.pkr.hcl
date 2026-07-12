# This wrapper shape is fine to use as-is — it's infra tooling, not your learning objective.
# Your actual work is in ../ansible/stig-remediation.yml.

source "amazon-ebs" "rhel9" {
  ami_name      = "aegis-rhel9-stig-{{timestamp}}"
  instance_type = "t3.micro"
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
