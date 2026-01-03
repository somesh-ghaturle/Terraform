# Your First Terraform Configuration

Let's write and deploy your first Terraform configuration! We'll start with a simple example using local resources (no cloud account needed).

## What We'll Build

A simple Terraform configuration that:
1. Creates a local file on your computer
2. Demonstrates the basic Terraform workflow
3. Introduces you to Terraform syntax

## Project Setup

Create a new directory for this project:

```bash
mkdir ~/terraform-projects/first-config
cd ~/terraform-projects/first-config
```

## Understanding Terraform Files

Terraform configuration files use the `.tf` extension and are written in HCL (HashiCorp Configuration Language).

### Basic Structure
```hcl
# Block type   Resource type    Local name
resource "local_file" "example" {
  # Arguments
  filename = "hello.txt"
  content  = "Hello, Terraform!"
}
```

## Example 1: Creating a Local File

Create a file named `main.tf`:

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

resource "local_file" "welcome" {
  filename = "${path.module}/output/welcome.txt"
  content  = "Welcome to Terraform! This file was created by IaC."
}

resource "local_file" "info" {
  filename = "${path.module}/output/info.txt"
  content  = <<-EOT
    Terraform Version: ${terraform.version}
    Created at: ${timestamp()}
    
    This demonstrates:
    - Resource creation
    - Heredoc syntax
    - Built-in functions
  EOT
}
```

### Understanding the Code

1. **`terraform` block**: Specifies Terraform and provider requirements
2. **`required_version`**: Minimum Terraform version needed
3. **`required_providers`**: Declares which providers to use
4. **`resource` block**: Defines infrastructure objects
5. **`local_file`**: Resource type (from local provider)
6. **`welcome`**: Resource name (chosen by you)
7. **`filename`**: Argument specifying where to create the file
8. **`content`**: Argument specifying file contents
9. **`${path.module}`**: Expression to get current directory path
10. **`<<-EOT ... EOT`**: Heredoc syntax for multi-line strings

## The Terraform Workflow

### Step 1: Initialize

Initialize the project to download providers:

```bash
terraform init
```

**What happens:**
- Downloads the `local` provider
- Creates `.terraform` directory
- Creates `.terraform.lock.hcl` lock file

**Expected output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/local versions matching "~> 2.0"...
- Installing hashicorp/local v2.4.0...
Terraform has been successfully initialized!
```

### Step 2: Format

Format your code to follow standard conventions:

```bash
terraform fmt
```

This ensures consistent styling across all Terraform files.

### Step 3: Validate

Check if your configuration is syntactically valid:

```bash
terraform validate
```

**Expected output:**
```
Success! The configuration is valid.
```

### Step 4: Plan

Preview what Terraform will do:

```bash
terraform plan
```

**Expected output:**
```
Terraform will perform the following actions:

  # local_file.info will be created
  + resource "local_file" "info" {
      + content              = <<-EOT
            Terraform Version: ...
        EOT
      + filename             = "./output/info.txt"
      + id                   = (known after apply)
    }

  # local_file.welcome will be created
  + resource "local_file" "welcome" {
      + content              = "Welcome to Terraform! This file was created by IaC."
      + filename             = "./output/welcome.txt"
      + id                   = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

**Understanding the plan:**
- `+` means resource will be created
- `~` means resource will be modified
- `-` means resource will be destroyed
- `(known after apply)` means value will be set after creation

### Step 5: Apply

Apply the configuration to create resources:

```bash
terraform apply
```

You'll be prompted to confirm. Type `yes`:

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

Or use auto-approve to skip confirmation:

```bash
terraform apply -auto-approve
```

**Expected output:**
```
local_file.welcome: Creating...
local_file.info: Creating...
local_file.welcome: Creation complete after 0s [id=...]
local_file.info: Creation complete after 0s [id=...]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

### Step 6: Verify

Check that the files were created:

```bash
ls -la output/
cat output/welcome.txt
cat output/info.txt
```

### Step 7: Inspect State

View the current state:

```bash
terraform show
```

This displays all resources managed by Terraform.

List all resources:

```bash
terraform state list
```

**Output:**
```
local_file.info
local_file.welcome
```

### Step 8: Modify Configuration

Let's update the `main.tf` file to change the content:

```hcl
resource "local_file" "welcome" {
  filename = "${path.module}/output/welcome.txt"
  content  = "Welcome to Terraform! This file was updated by IaC."
  # ← Changed "updated" instead of "created"
}
```

Run plan again:

```bash
terraform plan
```

You'll see:
```
  # local_file.welcome must be replaced
-/+ resource "local_file" "welcome" {
      ~ content  = "Welcome to Terraform! This file was created by IaC." -> "Welcome to Terraform! This file was updated by IaC."
        filename = "./output/welcome.txt"
      ~ id       = "..." -> (known after apply)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

Apply the change:

```bash
terraform apply -auto-approve
```

### Step 9: Destroy

Clean up resources when done:

```bash
terraform destroy
```

Type `yes` to confirm, or use:

```bash
terraform destroy -auto-approve
```

**Expected output:**
```
local_file.info: Destroying... [id=...]
local_file.welcome: Destroying... [id=...]
local_file.info: Destruction complete after 0s
local_file.welcome: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```

## Example 2: Multiple Files with Dependencies

Create a more complex example demonstrating dependencies:

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

# Create a directory structure file
resource "local_file" "readme" {
  filename = "${path.module}/project/README.md"
  content  = <<-EOT
    # My Project
    
    Created with Terraform
    
    ## Files
    - config.json: ${local_file.config.filename}
    - data.txt: ${local_file.data.filename}
  EOT
}

resource "local_file" "config" {
  filename = "${path.module}/project/config.json"
  content  = jsonencode({
    app_name = "terraform-demo"
    version  = "1.0.0"
    enabled  = true
  })
}

resource "local_file" "data" {
  filename = "${path.module}/project/data.txt"
  content  = "Sample data file\nLine 2\nLine 3"
}
```

**Notice:**
- The README file references other files
- Terraform automatically determines the correct creation order
- Using `jsonencode()` function for JSON formatting

Apply this configuration:

```bash
terraform apply -auto-approve
```

Check the dependency graph:

```bash
terraform graph
```

## File Organization Best Practices

As projects grow, organize files logically:

```
first-config/
├── main.tf          # Main resources
├── variables.tf     # Variable declarations
├── outputs.tf       # Output declarations
├── providers.tf     # Provider configuration
└── terraform.tfvars # Variable values
```

For now, keeping everything in `main.tf` is fine.

## Common Terraform Files

- **`main.tf`**: Primary configuration
- **`variables.tf`**: Input variable definitions
- **`outputs.tf`**: Output value definitions
- **`terraform.tfvars`**: Variable value assignments
- **`versions.tf`**: Provider version constraints
- **`.terraform.lock.hcl`**: Provider version lock (auto-generated)
- **`terraform.tfstate`**: State file (auto-generated, do not edit)

## Key Concepts Learned

✅ **Terraform Workflow**: init → plan → apply → destroy
✅ **HCL Syntax**: Resource blocks and arguments
✅ **Providers**: Using the local provider
✅ **State Management**: Terraform tracks resources
✅ **Idempotency**: Running apply multiple times = same result
✅ **Dependencies**: Terraform determines resource order

## Practice Exercises

1. **Add more files**: Create 3 more local_file resources with different content
2. **Use expressions**: Reference one file's filename in another's content
3. **Error handling**: Try creating a file in a non-existent directory
4. **State inspection**: Use `terraform state show` for each resource

## What's Next?

Now that you understand the basic workflow, let's explore Terraform commands in depth!

➡️ **Next**: [Terraform Commands](../04-commands/)

## 📚 Additional Resources

- [Terraform Configuration Syntax](https://www.terraform.io/language/syntax)
- [Local Provider Documentation](https://registry.terraform.io/providers/hashicorp/local/latest/docs)
- [Resource Blocks](https://www.terraform.io/language/resources)

---

[← Back: Installation](../02-installation/) | [Next: Commands →](../04-commands/)
