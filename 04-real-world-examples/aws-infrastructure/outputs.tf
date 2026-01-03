output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.web[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of EC2 instances"
  value       = aws_instance.web[*].private_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.app_data.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.app_data.arn
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "summary" {
  description = "Deployment summary"
  value = <<-EOT
    ╔═══════════════════════════════════════════════════════╗
    ║           AWS Infrastructure Deployment               ║
    ╚═══════════════════════════════════════════════════════╝
    
    Project: ${var.project_name}
    Environment: ${var.environment}
    Region: ${var.aws_region}
    
    VPC ID: ${aws_vpc.main.id}
    VPC CIDR: ${aws_vpc.main.cidr_block}
    
    Public Subnets: ${length(aws_subnet.public)}
    Private Subnets: ${length(aws_subnet.private)}
    
    EC2 Instances: ${var.instance_count}
    Instance Type: ${var.instance_type}
    
    Load Balancer URL: http://${aws_lb.main.dns_name}
    
    S3 Bucket: ${aws_s3_bucket.app_data.id}
    
    🎉 Infrastructure deployed successfully!
    
    Access your application at: http://${aws_lb.main.dns_name}
  EOT
}
