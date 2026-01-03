# Terraform State Management

Understanding and managing Terraform state is crucial for successful infrastructure management.

## What is Terraform State?

Terraform state is a JSON file that maps your configuration to real-world resources. It tracks metadata and improves performance for large infrastructures.

### State File: terraform.tfstate

```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "resources": [
    {
      "type": "local_file",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/hashicorp/local\"]",
      "instances": [
        {
          "attributes": {
            "content": "Hello, Terraform!",
            "filename": "hello.txt",
            "id": "abc123..."
          }
        }
      ]
    }
  ]
}
```

## Why State Matters

✅ **Resource Mapping**: Links configuration to real resources
✅ **Metadata Tracking**: Stores resource dependencies
✅ **Performance**: Caches resource attributes
✅ **Collaboration**: Enables team workflows

## Local vs Remote State

### Local State (Default)
```
project/
├── main.tf
├── terraform.tfstate         # State file
└── terraform.tfstate.backup  # Previous state
```

**Pros:**
- Simple setup
- No additional configuration

**Cons:**
- ❌ No collaboration
- ❌ No state locking
- ❌ Risk of loss
- ❌ Secrets in plain text

### Remote State (Recommended)

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
    
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Pros:**
- ✅ Team collaboration
- ✅ State locking
- ✅ Encryption
- ✅ Versioning
- ✅ Backup

## Backend Types

### S3 Backend (AWS)
```hcl
terraform {
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Azure Backend
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

### GCS Backend (Google Cloud)
```hcl
terraform {
  backend "gcs" {
    bucket = "my-tf-state"
    prefix = "terraform/state"
  }
}
```

### Terraform Cloud
```hcl
terraform {
  cloud {
    organization = "my-org"
    
    workspaces {
      name = "my-workspace"
    }
  }
}
```

## State Commands

### Inspect State
```bash
# List resources
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Pull remote state
terraform state pull > state.json

# View state in readable format
terraform show
```

### Modify State
```bash
# Move resource
terraform state mv aws_instance.old aws_instance.new

# Remove resource from state
terraform state rm aws_instance.old

# Replace provider
terraform state replace-provider old/provider new/provider
```

### Import Existing Resources
```bash
# Import resource into state
terraform import aws_instance.web i-1234567890abcdef0
```

## State Locking

Prevents concurrent modifications:

```hcl
# S3 with DynamoDB locking
terraform {
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"  # Enables locking
  }
}
```

Force unlock if needed:
```bash
terraform force-unlock <lock-id>
```

## Best Practices

### 1. Use Remote Backend
```hcl
# Always use remote backend for teams
terraform {
  backend "s3" {
    bucket = "company-tf-state"
    key    = "project/terraform.tfstate"
    region = "us-west-2"
  }
}
```

### 2. Enable State Locking
```hcl
# Prevent concurrent modifications
terraform {
  backend "s3" {
    dynamodb_table = "terraform-locks"
  }
}
```

### 3. Enable Encryption
```hcl
terraform {
  backend "s3" {
    encrypt = true
    kms_key_id = "arn:aws:kms:..."  # Optional: use specific KMS key
  }
}
```

### 4. Version Your State
```hcl
# S3 automatically supports versioning
# Enable it in S3 bucket configuration
```

### 5. Separate State by Environment
```
s3://my-tf-state/
├── dev/terraform.tfstate
├── staging/terraform.tfstate
└── prod/terraform.tfstate
```

### 6. Never Edit State Manually
```bash
# Use terraform commands instead
terraform state mv ...
terraform state rm ...
```

### 7. Backup State Files
```bash
# Automated backups with S3 versioning
# Manual backup
terraform state pull > backup-$(date +%Y%m%d).tfstate
```

## State Isolation Strategies

### Strategy 1: Separate Directories
```
infrastructure/
├── dev/
│   ├── main.tf
│   └── terraform.tfstate
├── staging/
│   ├── main.tf
│   └── terraform.tfstate
└── prod/
    ├── main.tf
    └── terraform.tfstate
```

### Strategy 2: Workspaces
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

### Strategy 3: Separate State Files
```hcl
terraform {
  backend "s3" {
    bucket = "my-tf-state"
    key    = "${var.environment}/terraform.tfstate"
  }
}
```

## Handling State Issues

### Lost State File
```bash
# Import resources one by one
terraform import aws_instance.web i-1234567890abcdef0
terraform import aws_security_group.web sg-1234567890abcdef0
```

### Corrupted State
```bash
# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Or pull from remote
terraform state pull > terraform.tfstate
```

### State Drift
```bash
# Detect drift
terraform plan

# Refresh state from actual infrastructure
terraform refresh

# Apply to fix drift
terraform apply
```

## Practice Exercise

Create a remote backend setup:

1. Create S3 bucket for state
2. Create DynamoDB table for locking
3. Configure backend
4. Migrate existing local state
5. Test with a team member

## 📚 Additional Resources

- [State Documentation](https://www.terraform.io/language/state)
- [Backend Configuration](https://www.terraform.io/language/settings/backends)
- [State Locking](https://www.terraform.io/language/state/locking)

---

[← Back: Modules](../01-modules/) | [Next: Provisioners →](../03-provisioners/)
