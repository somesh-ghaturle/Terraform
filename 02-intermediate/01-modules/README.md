# Terraform Modules

Modules are the primary way to package and reuse Terraform configurations. Learn how to create, use, and share modules effectively.

## What are Modules?

A module is a container for multiple resources that are used together. Every Terraform configuration has at least one module, called the **root module**, consisting of resources defined in the `.tf` files in the main working directory.

### Benefits of Modules

✅ **Reusability**: Write once, use many times
✅ **Organization**: Group related resources
✅ **Abstraction**: Hide complexity behind simple interfaces
✅ **Consistency**: Ensure standards across projects
✅ **Versioning**: Track changes and updates

## Module Structure

A typical module structure:

```
module/
├── main.tf          # Main resource definitions
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output value declarations
├── README.md        # Module documentation
└── examples/        # Example usage
    └── main.tf
```

## Creating Your First Module

Let's create a simple module for creating configuration files.

### Step 1: Create Module Directory

```bash
mkdir -p modules/config-file
cd modules/config-file
```

### Step 2: Define Module Resources (main.tf)

```hcl
# modules/config-file/main.tf
resource "local_file" "config" {
  filename = "${var.output_path}/${var.filename}"
  content = jsonencode({
    application = var.app_name
    environment = var.environment
    version     = var.version
    settings    = var.settings
  })
}

resource "local_file" "readme" {
  filename = "${var.output_path}/README.txt"
  content  = <<-EOT
    Configuration for ${var.app_name}
    Environment: ${var.environment}
    Version: ${var.version}
    Created: ${timestamp()}
  EOT
}
```

### Step 3: Define Input Variables (variables.tf)

```hcl
# modules/config-file/variables.tf
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "filename" {
  description = "Configuration filename"
  type        = string
  default     = "config.json"
}

variable "output_path" {
  description = "Output directory path"
  type        = string
}

variable "settings" {
  description = "Application settings"
  type        = map(any)
  default     = {}
}
```

### Step 4: Define Outputs (outputs.tf)

```hcl
# modules/config-file/outputs.tf
output "config_file_path" {
  description = "Path to the configuration file"
  value       = local_file.config.filename
}

output "readme_path" {
  description = "Path to the README file"
  value       = local_file.readme.filename
}

output "config_content" {
  description = "Configuration file content"
  value       = local_file.config.content
}
```

## Using the Module

Create a root configuration that uses the module:

```hcl
# main.tf (root module)
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Use the module for development environment
module "dev_config" {
  source = "./modules/config-file"
  
  app_name    = "my-app"
  environment = "dev"
  version     = "1.0.0"
  output_path = "${path.module}/output/dev"
  filename    = "app-config.json"
  
  settings = {
    debug    = true
    log_level = "DEBUG"
    port     = 3000
  }
}

# Use the module for production environment
module "prod_config" {
  source = "./modules/config-file"
  
  app_name    = "my-app"
  environment = "prod"
  version     = "1.0.0"
  output_path = "${path.module}/output/prod"
  filename    = "app-config.json"
  
  settings = {
    debug     = false
    log_level = "INFO"
    port      = 8080
  }
}

# Access module outputs
output "dev_config_path" {
  value = module.dev_config.config_file_path
}

output "prod_config_path" {
  value = module.prod_config.config_file_path
}
```

## Module Sources

Modules can be loaded from various sources:

### Local Path
```hcl
module "example" {
  source = "./modules/my-module"
}
```

### Terraform Registry
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
}
```

### GitHub
```hcl
module "example" {
  source = "github.com/username/terraform-module"
}

# Specific branch or tag
module "example" {
  source = "github.com/username/terraform-module?ref=v1.0.0"
}
```

### Git
```hcl
module "example" {
  source = "git::https://example.com/terraform-module.git"
}
```

### HTTP URL
```hcl
module "example" {
  source = "https://example.com/terraform-module.zip"
}
```

## Module Versioning

When using registry or Git sources, specify versions:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"  # Any 5.x version >= 5.0
}
```

Version constraints:
- `= 1.0.0` - Exactly version 1.0.0
- `!= 1.0.0` - Any version except 1.0.0
- `> 1.0.0` - Greater than 1.0.0
- `>= 1.0.0` - Greater than or equal to 1.0.0
- `< 1.0.0` - Less than 1.0.0
- `<= 1.0.0` - Less than or equal to 1.0.0
- `~> 1.0` - Any 1.x version >= 1.0
- `~> 1.0.0` - Any 1.0.x version >= 1.0.0

## Module Composition

Modules can call other modules:

```hcl
# modules/app-stack/main.tf
module "database" {
  source = "../database"
  
  db_name = var.db_name
  environment = var.environment
}

module "web_server" {
  source = "../web-server"
  
  server_name = var.server_name
  db_host     = module.database.db_host
  environment = var.environment
}
```

## Module Count and For_Each

Create multiple instances of a module:

### Using Count
```hcl
module "config" {
  count  = 3
  source = "./modules/config-file"
  
  app_name    = "app-${count.index}"
  environment = "dev"
  output_path = "${path.module}/output/app-${count.index}"
}
```

### Using For_Each
```hcl
locals {
  environments = {
    dev = {
      port = 3000
      debug = true
    }
    staging = {
      port = 4000
      debug = true
    }
    prod = {
      port = 8080
      debug = false
    }
  }
}

module "configs" {
  for_each = local.environments
  source   = "./modules/config-file"
  
  app_name    = "my-app"
  environment = each.key
  output_path = "${path.module}/output/${each.key}"
  
  settings = {
    port  = each.value.port
    debug = each.value.debug
  }
}

output "all_config_paths" {
  value = {
    for k, m in module.configs : k => m.config_file_path
  }
}
```

## Module Data Flow

```
┌─────────────────────┐
│   Root Module       │
│   (main.tf)         │
└──────────┬──────────┘
           │
           │ Input Variables
           ▼
┌─────────────────────┐
│   Child Module      │
│   (module code)     │
└──────────┬──────────┘
           │
           │ Outputs
           ▼
┌─────────────────────┐
│   Back to Root      │
│   (for use)         │
└─────────────────────┘
```

## Best Practices

### 1. Keep Modules Focused
Each module should have a single, clear purpose:
```
✅ Good: database-module, vpc-module, web-server-module
❌ Bad: entire-infrastructure-module
```

### 2. Use Semantic Versioning
```
v1.0.0 - Major.Minor.Patch
```

### 3. Document Your Modules
Create comprehensive README.md:
```markdown
# Module: Config File Generator

## Description
Creates configuration files for applications.

## Usage
```hcl
module "config" {
  source = "./modules/config-file"
  
  app_name    = "my-app"
  environment = "prod"
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| app_name | Application name | string | n/a | yes |

## Outputs
| Name | Description |
|------|-------------|
| config_file_path | Path to config file |
```

### 4. Validate Inputs
```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Invalid environment."
  }
}
```

### 5. Use Locals for Computed Values
```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "config-file"
  }
}
```

### 6. Avoid Hardcoding
```hcl
# Bad
resource "local_file" "config" {
  filename = "/tmp/config.json"
}

# Good
resource "local_file" "config" {
  filename = "${var.output_path}/${var.filename}"
}
```

## Testing Modules

Create an `examples` directory:

```
modules/config-file/
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
└── examples/
    ├── simple/
    │   └── main.tf
    └── complete/
        └── main.tf
```

Example test:
```hcl
# examples/simple/main.tf
module "test" {
  source = "../../"
  
  app_name    = "test-app"
  environment = "dev"
  output_path = "${path.module}/output"
}

output "result" {
  value = module.test.config_file_path
}
```

## Publishing Modules

### Terraform Registry
1. Host module on GitHub
2. Tag releases with semantic versioning (v1.0.0)
3. Register on Terraform Registry
4. Follow naming convention: `terraform-<PROVIDER>-<NAME>`

### Private Registry
- Use Terraform Cloud/Enterprise
- Host internal registry
- Control access and versioning

## Common Module Patterns

### Environment Configuration
```hcl
variable "environments" {
  type = map(object({
    instance_type = string
    instance_count = number
  }))
}
```

### Feature Flags
```hcl
variable "enable_monitoring" {
  type    = bool
  default = true
}

resource "monitoring" "this" {
  count = var.enable_monitoring ? 1 : 0
  # ...
}
```

### Conditional Resources
```hcl
locals {
  create_database = var.environment == "prod"
}

resource "database" "this" {
  count = local.create_database ? 1 : 0
  # ...
}
```

## Practice Exercises

1. Create a module that generates multiple files with different configurations
2. Use the module with both `count` and `for_each`
3. Create a module that calls another module
4. Add validation to all module inputs
5. Write comprehensive documentation for your module
6. Create example usage in the `examples` directory

## What's Next?

Learn about managing Terraform state effectively!

➡️ **Next**: [State Management](../02-state-management/)

## 📚 Additional Resources

- [Modules Overview](https://www.terraform.io/language/modules)
- [Module Sources](https://www.terraform.io/language/modules/sources)
- [Terraform Registry](https://registry.terraform.io/)
- [Publishing Modules](https://www.terraform.io/registry/modules/publish)

---

[← Back to Intermediate](../README.md) | [Next: State Management →](../02-state-management/)
