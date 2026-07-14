# Stock upstream RHEL 9 — no longer used by STIG_test_vm below, kept only as a reference for
# what Packer's own source_ami_filter builds from.
data "aws_ami" "rhel9" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9*_HVM-*-x86_64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Phase 2 step 5: the actual AMI Packer baked (name set in packer/rhel9-stig.pkr.hcl's
# ami_name). Launching from this instead of the stock AMI is the real proof that hardening
# persists into a brand-new instance automatically, not just the VM you hand-fixed.
data "aws_ami" "aegis_hardened" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["aegis-rhel9-stig-*"]
  }
}


resource "aws_security_group" "stig_test_ssh" {
  name        = "stig-test-ssh"
  description = "SSH access for the STIG scratch VM, from my IP only"
  vpc_id      = aws_vpc.aegis.id

  ingress {
    description = "SSH from my current public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "stig-test-ssh"
  }
}

resource "aws_instance" "STIG_test_vm" {
  ami                         = data.aws_ami.aegis_hardened.id
  instance_type               = "t3.micro"
  key_name                    = "aegis-lab"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.stig_test_ssh.id]

  # t3.micro only has 1GiB RAM, not enough for dnf to resolve/install
  # scap-security-guide without swap headroom (this is what was OOM-killing the install).
  # Runs once on first boot via cloud-init; user_data_replace_on_change means editing this
  # script forces a relaunch instead of silently no-op'ing on the existing instance.
  user_data                   = <<-EOF
    #!/bin/bash
    set -euo pipefail

    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab

    dnf install -y openscap-scanner scap-security-guide openscap-utils
  EOF
  user_data_replace_on_change = true

  tags = {
    Name = "STIG_test_vm"
  }

  # Pushes the STIG benchmark XML to the instance on every create, instead of scp'ing it by
  # hand each time you destroy/recreate this scratch VM. Runs from your local machine (not the
  # instance), so it needs a live SSH connection back to the instance right after boot.
  provisioner "file" {
    source      = var.stig_benchmark_path
    destination = "/home/ec2-user/stig_benchmark.xml"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.ssh_private_key_path))
      host        = self.public_ip
    }
  }
}

# Keeps ansible/inventory.ini pointed at whatever IP this instance currently has, so you don't
# have to hand-edit it after every terraform apply/destroy cycle. Regenerated on every apply,
# not just on replace, since local_file just diffs its content like any other resource.
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOF
    [stig_test]
    ${aws_instance.STIG_test_vm.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${var.ssh_private_key_path}
  EOF
}

