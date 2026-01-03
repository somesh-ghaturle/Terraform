# AWS Infrastructure Example

A complete, production-ready AWS infrastructure setup using Terraform.

## What This Builds

- ✅ VPC with public and private subnets
- ✅ Internet Gateway and NAT Gateway
- ✅ EC2 instances (web servers)
- ✅ Application Load Balancer
- ✅ RDS Database (optional)
- ✅ S3 bucket for storage
- ✅ Security Groups
- ✅ IAM roles and policies

## Architecture

```
Internet
    |
    v
[ ALB ] ─────┐
             │
    ┌────────┴────────┐
    │   Public Subnet  │
    └────────┬────────┘
             │
    ┌────────┴────────┐
    │  Private Subnet  │
    │  [ EC2 Instances]│
    │  [ RDS Database ]│
    └─────────────────┘
```

## Prerequisites

1. AWS Account
2. AWS CLI configured
3. Terraform installed
4. SSH key pair for EC2 access

## Setup

### 1. Configure AWS Credentials

```bash
aws configure
```

### 2. Create SSH Key (if needed)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/terraform-aws
```

### 3. Customize Variables

Copy and edit the variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Review Plan

```bash
terraform plan
```

### 6. Apply Configuration

```bash
terraform apply
```

## Configuration

### Variables

Edit `terraform.tfvars`:

```hcl
aws_region         = "us-west-2"
project_name       = "my-project"
environment        = "dev"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
instance_type      = "t2.micro"
instance_count     = 2
enable_rds         = false  # Set to true for database
```

## Outputs

After applying, you'll get:

- VPC ID
- Load Balancer DNS name
- EC2 instance IDs
- S3 bucket name
- RDS endpoint (if enabled)

View outputs:

```bash
terraform output
terraform output alb_dns_name
```

## Costs

Estimated monthly costs (us-west-2):
- VPC components: Free
- NAT Gateway: ~$32/month
- EC2 t2.micro (2x): ~$17/month
- ALB: ~$16/month
- RDS t3.micro (if enabled): ~$15/month

**Total: ~$65-80/month**

Use free tier resources when possible!

## Security

- All sensitive data uses AWS Secrets Manager
- Security groups follow least privilege
- Private subnets for application tier
- Encrypted RDS storage
- S3 bucket encryption enabled

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

⚠️ **Warning**: This will delete all created resources!

## Customization

### Add More EC2 Instances

```hcl
# terraform.tfvars
instance_count = 5
```

### Enable RDS Database

```hcl
# terraform.tfvars
enable_rds = true
db_instance_class = "db.t3.small"
```

### Change Instance Type

```hcl
# terraform.tfvars
instance_type = "t2.small"
```

## Troubleshooting

### Error: No default VPC
```bash
# Create a VPC manually or ensure your configuration creates one
```

### Error: Insufficient capacity
```bash
# Try a different availability zone or instance type
```

### Connection timeout
```bash
# Check security group rules
# Verify route table configuration
```

## Production Considerations

Before using in production:

1. ✅ Use remote state backend (S3 + DynamoDB)
2. ✅ Enable state locking
3. ✅ Set up monitoring (CloudWatch)
4. ✅ Configure backup strategies
5. ✅ Implement proper IAM policies
6. ✅ Use AWS WAF for ALB
7. ✅ Enable VPC Flow Logs
8. ✅ Set up auto-scaling
9. ✅ Configure CloudTrail
10. ✅ Implement disaster recovery

## Next Steps

- Add auto-scaling groups
- Implement blue-green deployment
- Add CloudFront CDN
- Configure Route53 DNS
- Set up monitoring and alerting

## 📚 Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

[← Back to Examples](../README.md)
