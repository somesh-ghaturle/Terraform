# Best Practices and Design Patterns

Learn industry-standard practices for writing production-ready Terraform code.

## Code Organization

### Project Structure
```
terraform-project/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── database/
├── global/
│   └── iam/
└── README.md
```

## Naming Conventions

### Resource Naming
```hcl
# Pattern: <resource_type>_<descriptive_name>
resource "aws_instance" "web_server" {}        # ✅ Good
resource "aws_instance" "i1" {}                 # ❌ Bad

# Use underscores, not hyphens
resource "aws_s3_bucket" "app_data" {}         # ✅ Good
resource "aws_s3_bucket" "app-data" {}         # ❌ Bad
```

### Variable Naming
```hcl
variable "vpc_cidr_block" {}                    # ✅ Good
variable "VpcCidr" {}                           # ❌ Bad (PascalCase)
variable "cidr" {}                              # ❌ Bad (not descriptive)
```

## Security Best Practices

### 1. Never Commit Secrets
```hcl
# ❌ Bad
variable "db_password" {
  default = "SuperSecret123"
}

# ✅ Good
variable "db_password" {
  type      = string
  sensitive = true
}
```

```bash
# Set via environment variable
export TF_VAR_db_password="SuperSecret123"
terraform apply
```

### 2. Use .gitignore
```gitignore
# .gitignore
*.tfstate
*.tfstate.*
*.tfvars
!terraform.tfvars.example
.terraform/
crash.log
override.tf
override.tf.json
```

### 3. Encrypt State Files
```hcl
terraform {
  backend "s3" {
    bucket  = "my-tf-state"
    encrypt = true
    kms_key_id = "arn:aws:kms:..."
  }
}
```

## DRY Principle

### Use Locals
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Team        = var.team_name
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_instance" "web" {
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-web"
    }
  )
}
```

### Use Modules
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  for_each = toset(["dev", "staging", "prod"])
  
  name        = "${each.key}-vpc"
  cidr_block  = var.vpc_cidrs[each.key]
  common_tags = local.common_tags
}
```

## Version Constraints

### Terraform Version
```hcl
terraform {
  required_version = "~> 1.6"  # 1.6.x
}
```

### Provider Versions
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## State Management

### Remote Backend
```hcl
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "project/environment/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Separate State Per Environment
```
s3://company-terraform-state/
├── project/
│   ├── dev/terraform.tfstate
│   ├── staging/terraform.tfstate
│   └── prod/terraform.tfstate
```

## Testing Strategy

### Validation
```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# Security scanning
tfsec .
```

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
```

## Documentation

### Module Documentation
```hcl
/**
 * # VPC Module
 *
 * Creates a VPC with public and private subnets.
 *
 * ## Usage
 *
 * ```hcl
 * module "vpc" {
 *   source = "./modules/vpc"
 *   
 *   name       = "my-vpc"
 *   cidr_block = "10.0.0.0/16"
 * }
 * ```
 */
```

### Variable Documentation
```hcl
variable "instance_type" {
  description = "EC2 instance type (e.g., t2.micro, t2.small)"
  type        = string
  default     = "t2.micro"
}
```

## Performance Optimization

### Use -target Sparingly
```bash
# Only when absolutely necessary
terraform apply -target=aws_instance.web
```

### Parallelism
```bash
# Adjust parallel operations
terraform apply -parallelism=20
```

### Refresh Control
```bash
# Skip refresh when not needed
terraform plan -refresh=false
```

## Error Handling

### Lifecycle Rules
```hcl
resource "aws_instance" "web" {
  # ...
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags]
  }
}
```

### Timeouts
```hcl
resource "aws_instance" "web" {
  # ...
  
  timeouts {
    create = "60m"
    delete = "2h"
  }
}
```

## CI/CD Integration

### Example Pipeline
```yaml
# .github/workflows/terraform.yml
name: Terraform

on: [push, pull_request]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        
      - name: Terraform Init
        run: terraform init
        
      - name: Terraform Format
        run: terraform fmt -check
        
      - name: Terraform Validate
        run: terraform validate
        
      - name: Terraform Plan
        run: terraform plan
```

## Monitoring and Alerting

### Track State Changes
```bash
# Compare states
terraform show -json > current-state.json
diff previous-state.json current-state.json
```

### Cost Estimation
```bash
# Use Infracost
infracost breakdown --path .
```

## Common Patterns

### Feature Flags
```hcl
variable "enable_feature" {
  type    = bool
  default = false
}

resource "aws_instance" "feature" {
  count = var.enable_feature ? 1 : 0
  # ...
}
```

### Environment Configuration
```hcl
locals {
  env_config = {
    dev = {
      instance_type = "t2.micro"
      instance_count = 1
    }
    prod = {
      instance_type = "t2.large"
      instance_count = 3
    }
  }
  
  config = local.env_config[var.environment]
}
```

## Troubleshooting Guide

### Enable Debug Logging
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform apply
```

### Common Issues

1. **State Lock**: `terraform force-unlock <lock-id>`
2. **Provider Issues**: `terraform init -upgrade`
3. **State Drift**: `terraform refresh`
4. **Cache Issues**: `rm -rf .terraform && terraform init`

## Checklist for Production

- [ ] Remote state backend configured
- [ ] State locking enabled
- [ ] Secrets not in code
- [ ] .gitignore properly configured
- [ ] Provider versions pinned
- [ ] Variables validated
- [ ] Outputs documented
- [ ] README.md created
- [ ] CI/CD pipeline set up
- [ ] Backup strategy defined
- [ ] Team access configured
- [ ] Monitoring enabled

## 📚 Additional Resources

- [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- [Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Module Best Practices](https://www.terraform.io/docs/language/modules/develop/index.html)

---

[← Back: Functions](../04-functions/) | [Next: Real-World Examples →](../../04-real-world-examples/)
