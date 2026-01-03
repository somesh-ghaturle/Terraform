# Terraform Workspaces

Workspaces allow you to manage multiple environments (dev, staging, prod) with a single configuration using separate state files.

## What are Workspaces?

Workspaces are named state containers that allow you to switch between different instances of your infrastructure without changing your configuration files.

### Key Concepts

- Each workspace has its own state file
- Same configuration, different state
- Useful for managing multiple environments
- Default workspace is called "default"

## Workspace Commands

### List Workspaces
```bash
terraform workspace list
```

Output:
```
  default
* dev
  staging
  prod
```

The `*` indicates the current workspace.

### Create Workspace
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

### Switch Workspace
```bash
terraform workspace select dev
terraform workspace select prod
```

### Show Current Workspace
```bash
terraform workspace show
```

### Delete Workspace
```bash
terraform workspace delete staging
```

**Note:** You cannot delete the current workspace or the default workspace.

## Using Workspaces in Configuration

### Current Workspace Name
```hcl
# Access current workspace name
locals {
  environment = terraform.workspace
}

resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name        = "web-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
```

### Environment-Specific Configuration
```hcl
# variables.tf
variable "instance_type" {
  type = map(string)
  default = {
    dev     = "t2.micro"
    staging = "t2.small"
    prod    = "t2.large"
  }
}

# main.tf
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = var.instance_type[terraform.workspace]
  
  tags = {
    Name        = "${terraform.workspace}-web-server"
    Environment = terraform.workspace
  }
}
```

## Practical Examples

### Example 1: Basic Multi-Environment Setup

```hcl
# variables.tf
variable "config" {
  type = map(object({
    instance_type  = string
    instance_count = number
    db_size        = number
  }))
  
  default = {
    dev = {
      instance_type  = "t2.micro"
      instance_count = 1
      db_size        = 20
    }
    staging = {
      instance_type  = "t2.small"
      instance_count = 2
      db_size        = 50
    }
    prod = {
      instance_type  = "t2.large"
      instance_count = 5
      db_size        = 100
    }
  }
}

# main.tf
locals {
  env_config = var.config[terraform.workspace]
}

resource "aws_instance" "web" {
  count         = local.env_config.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.env_config.instance_type
  
  tags = {
    Name        = "${terraform.workspace}-web-${count.index + 1}"
    Environment = terraform.workspace
  }
}

# outputs.tf
output "environment" {
  value = terraform.workspace
}

output "instance_config" {
  value = local.env_config
}

output "instance_ids" {
  value = aws_instance.web[*].id
}
```

### Example 2: Local File Management

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

locals {
  workspace_config = {
    dev = {
      replicas = 1
      debug    = true
    }
    staging = {
      replicas = 2
      debug    = true
    }
    prod = {
      replicas = 5
      debug    = false
    }
  }
  
  config = local.workspace_config[terraform.workspace]
}

resource "local_file" "config" {
  filename = "${path.module}/output/${terraform.workspace}/config.json"
  content = jsonencode({
    environment = terraform.workspace
    replicas    = local.config.replicas
    debug       = local.config.debug
    timestamp   = timestamp()
  })
}

resource "local_file" "readme" {
  filename = "${path.module}/output/${terraform.workspace}/README.md"
  content  = <<-EOT
    # ${upper(terraform.workspace)} Environment
    
    This configuration is for the ${terraform.workspace} environment.
    
    ## Settings
    - Replicas: ${local.config.replicas}
    - Debug Mode: ${local.config.debug}
    - Workspace: ${terraform.workspace}
  EOT
}

output "workspace_info" {
  value = {
    current_workspace = terraform.workspace
    config_file       = local_file.config.filename
    readme_file       = local_file.readme.filename
    settings          = local.config
  }
}
```

## Workflow Example

```bash
# Create and switch to dev workspace
terraform workspace new dev
terraform apply -auto-approve

# Check what was created
terraform output

# Switch to staging
terraform workspace new staging
terraform apply -auto-approve

# Switch to prod
terraform workspace new prod
terraform apply -auto-approve

# List all workspaces
terraform workspace list

# Switch between environments
terraform workspace select dev
terraform show

terraform workspace select prod
terraform show

# Clean up each environment
terraform workspace select dev
terraform destroy -auto-approve

terraform workspace select staging
terraform destroy -auto-approve

terraform workspace select prod
terraform destroy -auto-approve

# Delete workspaces (switch to default first)
terraform workspace select default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod
```

## State File Location

### Local Backend
```
project/
├── terraform.tfstate.d/
│   ├── dev/
│   │   └── terraform.tfstate
│   ├── staging/
│   │   └── terraform.tfstate
│   └── prod/
│       └── terraform.tfstate
└── terraform.tfstate  # default workspace
```

### Remote Backend (S3)
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "project/terraform.tfstate"  # Workspace name added automatically
    region = "us-west-2"
  }
}
```

State files are stored as:
- `project/terraform.tfstate` (default)
- `project/env:/dev/terraform.tfstate`
- `project/env:/staging/terraform.tfstate`
- `project/env:/prod/terraform.tfstate`

## Advanced Patterns

### Pattern 1: Workspace-Specific Backends
```hcl
# Configure different backends per workspace
locals {
  backend_config = {
    dev = {
      bucket = "dev-terraform-state"
      region = "us-west-2"
    }
    prod = {
      bucket = "prod-terraform-state"
      region = "us-east-1"
    }
  }
}
```

### Pattern 2: Conditional Resources
```hcl
# Only create monitoring in prod
resource "aws_cloudwatch_alarm" "high_cpu" {
  count = terraform.workspace == "prod" ? 1 : 0
  
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  threshold           = "80"
}
```

### Pattern 3: Workspace Validation
```hcl
locals {
  valid_workspaces = ["dev", "staging", "prod"]
  is_valid = contains(local.valid_workspaces, terraform.workspace)
}

resource "null_resource" "validate_workspace" {
  count = local.is_valid ? 0 : 1
  
  provisioner "local-exec" {
    command = "echo 'ERROR: Invalid workspace ${terraform.workspace}. Must be one of: ${join(", ", local.valid_workspaces)}' && exit 1"
  }
}
```

## Workspaces vs Separate Directories

### Workspaces (Same Config, Different State)
```
✅ Pros:
- Single codebase
- Easy to maintain consistency
- Quick environment switching

❌ Cons:
- Easy to accidentally apply to wrong environment
- Less isolation
- Can't have different configurations
```

### Separate Directories
```
✅ Pros:
- Complete isolation
- Different configurations per environment
- Safer (harder to make mistakes)

❌ Cons:
- Code duplication
- Harder to maintain consistency
- More files to manage
```

## Best Practices

### ✅ Do:
- Use workspaces for similar environments
- Validate workspace name in code
- Use workspace-specific variables
- Document workspace usage
- Use meaningful workspace names

### ❌ Don't:
- Use workspaces for completely different infrastructure
- Rely solely on workspaces for isolation
- Use workspace names that could be confused
- Delete workspaces without destroying resources first
- Share state files between teams using workspaces

## Common Use Cases

1. **Development environments** - Multiple developers each with their own workspace
2. **Testing** - Temporary test environments
3. **Staging/Production** - Similar configurations with different scale
4. **Feature branches** - Temporary infrastructure for feature development
5. **Customer instances** - Multiple similar deployments for different customers

## Alternatives to Workspaces

### 1. Separate Directories
```
infrastructure/
├── dev/
│   ├── main.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    └── terraform.tfvars
```

### 2. Terragrunt
- Keeps code DRY
- Better suited for complex environments
- More powerful than workspaces

### 3. Separate Repositories
- Complete isolation
- Different teams can manage independently
- Better for different architectures

## Troubleshooting

### Cannot Switch Workspace
```bash
# Ensure no changes are pending
terraform plan

# If clean, then switch
terraform workspace select prod
```

### Wrong Workspace Applied
```bash
# Check current workspace before applying
terraform workspace show

# Always verify before apply
terraform plan
```

### State Lock Issues
```bash
# Force unlock if needed
terraform force-unlock <lock-id>
```

## Summary

- Workspaces enable managing multiple environments
- Same code, separate state
- Use `terraform.workspace` to reference current workspace
- Good for similar environments with different scales
- Consider alternatives for complex setups

---

[← Back: Data Sources](../04-data-sources/) | [Next: Advanced →](../../03-advanced/)
