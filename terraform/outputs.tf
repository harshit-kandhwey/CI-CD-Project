# Terraform Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.ec2.id
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "EC2 Public IP (Elastic IP)"
  value       = aws_eip.app_server.public_ip
}

output "ec2_private_ip" {
  description = "EC2 Private IP"
  value       = aws_instance.app_server.private_ip
}

output "application_url" {
  description = "Application URL"
  value       = "http://${aws_eip.app_server.public_ip}"
}

output "backend_api_url" {
  description = "Backend API URL"
  value       = "http://${aws_eip.app_server.public_ip}:5000/api"
}

output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i ~/.ssh/todo-app-key ubuntu@${aws_eip.app_server.public_ip}"
}

output "instance_profile_arn" {
  description = "IAM Instance Profile ARN"
  value       = aws_iam_instance_profile.ec2_profile.arn
}