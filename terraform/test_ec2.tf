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


resource "aws_security_group" "stig_test_ssh" {
  name        = "stig-test-ssh"
  description = "SSH access for the STIG scratch VM, from my IP only"

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
  ami                    = data.aws_ami.rhel9.id
  instance_type          = "t3.micro"
  key_name               = "aegis-lab"
  vpc_security_group_ids = [aws_security_group.stig_test_ssh.id]

  tags = {
    Name = "STIG_test_vm"
  }
}

