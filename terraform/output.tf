output "ec2_instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.STIG_test_vm.id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.STIG_test_vm.public_ip
}
