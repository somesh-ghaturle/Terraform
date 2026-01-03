# Variables and Outputs

Learn how to make your Terraform configurations dynamic, reusable, and maintainable using variables and outputs.

## Understanding Variables

Variables allow you to parameterize your Terraform configurations, making them flexible and reusable across different environments.

### Why Use Variables?

✅ **Reusability**: Same config for dev, staging, production
✅ **Flexibility**: Change values without modifying code
✅ **Security**: Separate sensitive data from code
✅ **Maintainability**: Update values in one place

## Variable Basics

### Declaring Variables

Create a `variables.tf` file:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "demo"
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}
```

### Variable Types

Terraform supports several variable types:

#### Primitive Types

```hcl
# String
variable "region" {
  type    = string
  default = "us-west-2"
}

# Number
variable "port" {
  type    = number
  default = 8080
}

# Boolean
variable "enabled" {
  type    = bool
  default = true
}
```

#### Collection Types

```hcl
# List (ordered)
variable "subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Set (unordered, unique)
variable "security_groups" {
  type    = set(string)
  default = ["sg-123", "sg-456"]
}

# Map (key-value pairs)
variable "tags" {
  type = map(string)
  default = {
    Name = "example"
    Env  = "dev"
  }
}
```

#### Complex Types

```hcl
# Object (structured)
variable "server_config" {
  type = object({
    name          = string
    instance_type = string
    disk_size     = number
  })
  default = {
    name          = "web-server"
    instance_type = "t2.micro"
    disk_size     = 20
  }
}

# Tuple (fixed-length list with specific types)
variable "server_info" {
  type    = tuple([string, number, bool])
  default = ["web-server", 8080, true]
}

# List of objects
variable "servers" {
  type = list(object({
    name = string
    size = number
  }))
  default = [
    { name = "web", size = 10 },
    { name = "db", size = 50 }
  ]
}
```

### Using Variables

Reference variables with `var.` prefix:

```hcl
resource "local_file" "example" {
  filename = "${path.module}/output/${var.environment}.txt"
  content  = "Instance type: ${var.instance_type}"
}

resource "local_file" "config" {
  filename = "${path.module}/config.json"
  content = jsonencode({
    server_name   = var.server_config.name
    instance_type = var.server_config.instance_type
    ports         = var.ports
    tags          = var.tags
  })
}
```

## Setting Variable Values

### Method 1: Default Values

In `variables.tf`:

```hcl
variable "environment" {
  default = "development"
}
```

### Method 2: Command Line

```bash
terraform apply -var="environment=production"
terraform apply -var="instance_count=3" -var="environment=staging"
```

### Method 3: Variable Files

Create `terraform.tfvars`:

```hcl
environment    = "production"
instance_type  = "t2.large"
instance_count = 5
tags = {
  Environment = "production"
  Team        = "platform"
}
```

Apply with:
```bash
terraform apply  # Automatically loads terraform.tfvars
```

Or create custom variable files:

`dev.tfvars`:
```hcl
environment   = "development"
instance_type = "t2.micro"
```

`prod.tfvars`:
```hcl
environment   = "production"
instance_type = "t2.xlarge"
```

Apply with:
```bash
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

### Method 4: Environment Variables

```bash
export TF_VAR_environment="production"
export TF_VAR_instance_type="t2.large"
terraform apply
```

### Variable Precedence (Lowest to Highest)

1. Default value in variable declaration
2. Environment variables (`TF_VAR_*`)
3. `terraform.tfvars` file
4. `*.auto.tfvars` files (alphabetical order)
5. `-var-file` flag
6. `-var` command line flag

## Variable Validation

Add validation rules to variables:

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"

  validation {
    condition     = can(regex("^t2\\.(micro|small|medium)$", var.instance_type))
    error_message = "Instance type must be t2.micro, t2.small, or t2.medium."
  }
}

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "port" {
  type        = number
  description = "Port number"

  validation {
    condition     = var.port > 0 && var.port < 65536
    error_message = "Port must be between 1 and 65535."
  }
}
```

## Sensitive Variables

Mark variables as sensitive to hide values in output:

```hcl
variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "api_key" {
  type      = string
  sensitive = true
}
```

Usage:
```bash
terraform apply -var="db_password=SecretPass123"
```

Output will show:
```
  + db_password = (sensitive value)
```

## Understanding Outputs

Outputs extract information from your infrastructure and make it available for:
- Display after `terraform apply`
- Use in other Terraform configurations
- Integration with other tools

### Declaring Outputs

Create `outputs.tf`:

```hcl
output "file_path" {
  description = "Path to the created file"
  value       = local_file.example.filename
}

output "file_content" {
  description = "Content of the file"
  value       = local_file.example.content
  sensitive   = true  # Hide from console output
}

output "file_id" {
  description = "Unique ID of the file"
  value       = local_file.example.id
}
```

### Output Types

```hcl
# Simple output
output "instance_ip" {
  value = "192.168.1.100"
}

# Computed output
output "instance_details" {
  value = {
    id         = local_file.example.id
    filename   = local_file.example.filename
    created_at = timestamp()
  }
}

# List output
output "all_filenames" {
  value = [
    local_file.file1.filename,
    local_file.file2.filename,
    local_file.file3.filename
  ]
}

# Conditional output
output "status_message" {
  value = var.enabled ? "Service is enabled" : "Service is disabled"
}
```

### Viewing Outputs

```bash
# Show all outputs
terraform output

# Show specific output
terraform output file_path

# Get JSON format
terraform output -json

# Get raw value (no quotes)
terraform output -raw file_path
```

### Sensitive Outputs

```hcl
output "database_password" {
  value     = var.db_password
  sensitive = true
}
```

The output won't be displayed in console but is still available:
```bash
terraform output database_password  # Shows the value
```

## Complete Example

Let's create a complete example with variables and outputs:

### Directory Structure
```
variables-example/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── dev.tfvars
```

### variables.tf
```hcl
variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-demo"
}

variable "file_count" {
  description = "Number of files to create"
  type        = number
  default     = 3

  validation {
    condition     = var.file_count > 0 && var.file_count <= 10
    error_message = "File count must be between 1 and 10."
  }
}

variable "content_prefix" {
  description = "Prefix for file content"
  type        = string
  default     = "Hello"
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}

variable "enabled_features" {
  description = "List of enabled features"
  type        = list(string)
  default     = ["logging", "monitoring"]
}
```

### main.tf
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Create multiple files using count
resource "local_file" "example" {
  count    = var.file_count
  filename = "${path.module}/output/${var.environment}-file-${count.index + 1}.txt"
  content  = <<-EOT
    ${var.content_prefix} from Terraform!
    
    Environment: ${var.environment}
    Project: ${var.project_name}
    File Number: ${count.index + 1}
    Enabled Features: ${join(", ", var.enabled_features)}
    
    Tags:
    ${jsonencode(var.tags)}
  EOT
}

# Create a configuration file
resource "local_file" "config" {
  filename = "${path.module}/output/${var.environment}-config.json"
  content = jsonencode({
    environment       = var.environment
    project_name      = var.project_name
    file_count        = var.file_count
    enabled_features  = var.enabled_features
    tags              = var.tags
  })
}
```

### outputs.tf
```hcl
output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "files_created" {
  description = "List of created files"
  value       = [for f in local_file.example : f.filename]
}

output "total_files" {
  description = "Total number of files created"
  value       = length(local_file.example)
}

output "config_file" {
  description = "Configuration file path"
  value       = local_file.config.filename
}

output "file_details" {
  description = "Details of all created files"
  value = {
    for idx, file in local_file.example :
    "file_${idx + 1}" => {
      path = file.filename
      id   = file.id
    }
  }
}

output "summary" {
  description = "Summary of deployment"
  value = <<-EOT
    Deployment Summary
    ==================
    Environment: ${var.environment}
    Project: ${var.project_name}
    Files Created: ${var.file_count}
    Config File: ${local_file.config.filename}
  EOT
}
```

### terraform.tfvars
```hcl
environment    = "dev"
project_name   = "my-project"
file_count     = 3
content_prefix = "Welcome"
tags = {
  Team  = "DevOps"
  Owner = "John Doe"
}
enabled_features = ["logging", "monitoring", "backup"]
```

### dev.tfvars
```hcl
environment    = "dev"
project_name   = "dev-project"
file_count     = 2
content_prefix = "Hello Dev"
```

### Running the Example

```bash
# Initialize
terraform init

# Plan with default terraform.tfvars
terraform plan

# Apply with default values
terraform apply -auto-approve

# Apply with dev.tfvars
terraform apply -var-file="dev.tfvars" -auto-approve

# View outputs
terraform output
terraform output files_created
terraform output -json

# Clean up
terraform destroy -auto-approve
```

## Local Variables

Define computed values with local variables:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  file_prefix = "${var.environment}-${var.project_name}"
  
  # Computed value
  is_production = var.environment == "prod"
  
  # Conditional value
  instance_type = local.is_production ? "t2.large" : "t2.micro"
}

resource "local_file" "example" {
  filename = "${path.module}/${local.file_prefix}.txt"
  content  = "Instance type: ${local.instance_type}"
}
```

## Best Practices

1. **Always provide descriptions**
   ```hcl
   variable "instance_type" {
     description = "EC2 instance type (e.g., t2.micro, t2.small)"
     type        = string
   }
   ```

2. **Use validation for critical variables**
   ```hcl
   validation {
     condition     = can(regex("^[a-z]", var.name))
     error_message = "Name must start with a lowercase letter."
   }
   ```

3. **Mark sensitive data appropriately**
   ```hcl
   variable "password" {
     sensitive = true
   }
   ```

4. **Use specific types**
   ```hcl
   # Bad
   variable "ports" {
     type = any
   }
   
   # Good
   variable "ports" {
     type = list(number)
   }
   ```

5. **Organize variables logically**
   - Group related variables
   - Use consistent naming
   - Order alphabetically or by importance

6. **Don't commit sensitive values**
   ```gitignore
   # .gitignore
   *.tfvars
   !terraform.tfvars.example
   *.tfstate
   *.tfstate.backup
   ```

## Common Patterns

### Environment-Specific Configuration

```hcl
variable "config" {
  type = map(object({
    instance_type = string
    count         = number
  }))
  default = {
    dev = {
      instance_type = "t2.micro"
      count         = 1
    }
    prod = {
      instance_type = "t2.large"
      count         = 3
    }
  }
}

locals {
  env_config = var.config[var.environment]
}
```

### DRY with Variables

```hcl
variable "regions" {
  type = map(object({
    zone1 = string
    zone2 = string
  }))
  default = {
    us-west = {
      zone1 = "us-west-2a"
      zone2 = "us-west-2b"
    }
    us-east = {
      zone1 = "us-east-1a"
      zone2 = "us-east-1b"
    }
  }
}
```

## Practice Exercises

1. Create a configuration with 5 different variable types
2. Use all 4 methods of setting variable values
3. Add validation to at least 2 variables
4. Create outputs that use expressions and functions
5. Build a multi-environment configuration using variable files

## What's Next?

Congratulations! You've completed the basics. Now move to intermediate concepts!

➡️ **Next**: [Intermediate Topics](../../02-intermediate/)

## 📚 Additional Resources

- [Input Variables](https://www.terraform.io/language/values/variables)
- [Output Values](https://www.terraform.io/language/values/outputs)
- [Local Values](https://www.terraform.io/language/values/locals)
- [Variable Validation](https://www.terraform.io/language/values/variables#custom-validation-rules)

---

[← Back: Commands](../04-commands/) | [Next: Intermediate →](../../02-intermediate/)
