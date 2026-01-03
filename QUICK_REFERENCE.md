# Quick Reference Guide

Quick reference for common Terraform commands and patterns.

## Essential Commands

```bash
# Initialize
terraform init

# Format code
terraform fmt -recursive

# Validate
terraform validate

# Plan
terraform plan
terraform plan -out=tfplan

# Apply
terraform apply
terraform apply -auto-approve
terraform apply tfplan

# Destroy
terraform destroy
terraform destroy -auto-approve

# Show state
terraform show
terraform state list
terraform state show <resource>

# Output values
terraform output
terraform output <name>
terraform output -json
```

## File Structure

```
project/
├── main.tf          # Main configuration
├── variables.tf     # Variable declarations
├── outputs.tf       # Output declarations
├── terraform.tfvars # Variable values (gitignored)
└── modules/         # Reusable modules
    └── my-module/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Variable Syntax

```hcl
# Declaration
variable "name" {
  description = "Description"
  type        = string
  default     = "value"
  sensitive   = false
  
  validation {
    condition     = length(var.name) > 0
    error_message = "Name cannot be empty."
  }
}

# Usage
resource "type" "name" {
  attribute = var.name
}
```

## Resource Syntax

```hcl
resource "provider_type" "name" {
  argument1 = "value"
  argument2 = 123
  
  nested_block {
    nested_arg = "value"
  }
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [tags]
  }
}
```

## Output Syntax

```hcl
output "name" {
  description = "Description"
  value       = resource.type.name.attribute
  sensitive   = false
}
```

## Module Syntax

```hcl
module "name" {
  source = "./modules/module-name"
  
  input_var1 = "value"
  input_var2 = var.some_var
}

# Access module outputs
output "from_module" {
  value = module.name.output_name
}
```

## Common Patterns

### Count
```hcl
resource "type" "name" {
  count = 3
  name  = "item-${count.index}"
}
```

### For Each
```hcl
resource "type" "name" {
  for_each = toset(["a", "b", "c"])
  name     = each.key
}
```

### Conditional
```hcl
resource "type" "name" {
  count = var.create ? 1 : 0
}
```

### Locals
```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

## Data Sources

```hcl
data "provider_type" "name" {
  filter {
    name   = "key"
    values = ["value"]
  }
}

# Usage
resource "type" "example" {
  attribute = data.provider_type.name.id
}
```

## Functions

```hcl
# String functions
upper("hello")              # "HELLO"
lower("HELLO")              # "hello"
format("Hello %s", "World") # "Hello World"

# Collection functions
length([1, 2, 3])           # 3
concat([1, 2], [3, 4])      # [1, 2, 3, 4]
merge({a=1}, {b=2})         # {a=1, b=2}

# Encoding functions
jsonencode({key="value"})   # JSON string
base64encode("hello")       # Base64 string

# Filesystem functions
file("path/to/file")        # Read file
templatefile("file", vars)  # Render template

# Network functions
cidrsubnet("10.0.0.0/16", 8, 1)  # "10.0.1.0/24"
```

## Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "project/terraform.tfstate"
    region = "us-west-2"
  }
}
```

## Provider Configuration

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

## Debugging

```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

## Best Practices

✅ Use version control
✅ Use remote state
✅ Enable state locking
✅ Use modules for reusability
✅ Validate inputs
✅ Document with comments
✅ Format with `terraform fmt`
✅ Plan before apply
✅ Use meaningful names
✅ Keep secrets out of code

❌ Don't edit state files manually
❌ Don't commit secrets
❌ Don't use `terraform apply` without `plan`
❌ Don't ignore `.terraform.lock.hcl`

---

For more details, see the full documentation in each section.
