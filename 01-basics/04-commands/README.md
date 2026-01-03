# Terraform Commands

Master the essential Terraform CLI commands that you'll use daily. This guide covers all important commands with practical examples.

## Core Terraform Workflow Commands

### terraform init

**Purpose**: Initialize a Terraform working directory

```bash
terraform init
```

**What it does:**
- Downloads provider plugins
- Initializes backend for state storage
- Downloads modules
- Creates `.terraform` directory and lock file

**Common options:**
```bash
terraform init -upgrade          # Upgrade providers to latest version
terraform init -reconfigure      # Reconfigure backend
terraform init -migrate-state    # Migrate state from one backend to another
terraform init -backend=false    # Skip backend initialization
```

**Example output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.23.0...

Terraform has been successfully initialized!
```

---

### terraform plan

**Purpose**: Create an execution plan showing what Terraform will do

```bash
terraform plan
```

**What it does:**
- Compares desired state (configuration) with actual state
- Shows what will be created, modified, or destroyed
- Does NOT make any changes

**Common options:**
```bash
terraform plan -out=tfplan              # Save plan to file
terraform plan -var="env=production"    # Pass variables
terraform plan -target=aws_instance.web # Plan for specific resource
terraform plan -refresh=false           # Skip state refresh
terraform plan -destroy                 # Plan for destruction
```

**Reading plan output:**
```
  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami           = "ami-12345678"
      + instance_type = "t2.micro"
      + id            = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Symbols:**
- `+` = Create
- `-` = Destroy
- `~` = Modify in-place
- `-/+` = Destroy and recreate
- `<=` = Read during apply

---

### terraform apply

**Purpose**: Apply the changes to reach the desired state

```bash
terraform apply
```

**What it does:**
- Creates an execution plan (like `terraform plan`)
- Prompts for confirmation
- Executes the plan to create/modify/destroy resources
- Updates the state file

**Common options:**
```bash
terraform apply -auto-approve          # Skip confirmation prompt
terraform apply tfplan                 # Apply saved plan file
terraform apply -var="count=3"         # Pass variables
terraform apply -target=aws_instance.web # Apply specific resource
terraform apply -parallelism=10        # Set parallel resource operations
```

**Example:**
```bash
# Apply with automatic approval
terraform apply -auto-approve

# Apply specific resource
terraform apply -target=aws_instance.web -auto-approve

# Apply with variables
terraform apply -var="instance_type=t2.small" -auto-approve
```

---

### terraform destroy

**Purpose**: Destroy all managed infrastructure

```bash
terraform destroy
```

**What it does:**
- Creates a destruction plan
- Prompts for confirmation
- Destroys all resources in the state file

**Common options:**
```bash
terraform destroy -auto-approve               # Skip confirmation
terraform destroy -target=aws_instance.web    # Destroy specific resource
terraform destroy -var="env=staging"          # Pass variables
```

**⚠️ Warning**: This is destructive and cannot be undone!

**Best practice:**
```bash
# Always review before destroying
terraform plan -destroy
# Then if everything looks correct
terraform destroy
```

---

## State Management Commands

### terraform state list

**Purpose**: List all resources in the state

```bash
terraform state list
```

**Example output:**
```
aws_instance.web
aws_security_group.web_sg
aws_vpc.main
local_file.config
```

---

### terraform state show

**Purpose**: Show details about a specific resource

```bash
terraform state show aws_instance.web
```

**Example output:**
```
# aws_instance.web:
resource "aws_instance" "web" {
    ami                    = "ami-12345678"
    instance_type          = "t2.micro"
    availability_zone      = "us-west-2a"
    id                     = "i-0123456789abcdef"
    public_ip              = "54.123.45.67"
    ...
}
```

---

### terraform state mv

**Purpose**: Move/rename resources in the state

```bash
terraform state mv aws_instance.web aws_instance.web_server
```

**Use cases:**
- Renaming resources
- Moving resources between modules
- Reorganizing resource structure

**Example:**
```bash
# Rename a resource
terraform state mv aws_instance.old_name aws_instance.new_name

# Move to a module
terraform state mv aws_instance.web module.web.aws_instance.server
```

---

### terraform state rm

**Purpose**: Remove resource from state (doesn't destroy actual resource)

```bash
terraform state rm aws_instance.web
```

**⚠️ Caution**: Resource will be orphaned! Terraform will no longer manage it.

**Use cases:**
- Removing accidentally imported resources
- Transferring management to another Terraform state
- Manually managing resources outside Terraform

---

### terraform state pull

**Purpose**: Download and display the current state

```bash
terraform state pull > terraform.tfstate.backup
```

**Use case:** Backup or inspect remote state

---

### terraform state push

**Purpose**: Upload a local state file to remote backend

```bash
terraform state push terraform.tfstate
```

**⚠️ Warning**: Use with extreme caution! Can overwrite remote state.

---

## Validation and Formatting Commands

### terraform validate

**Purpose**: Validate Terraform configuration syntax

```bash
terraform validate
```

**What it checks:**
- Syntax errors
- Valid attribute names
- Required attributes
- Valid references

**Example output:**
```
Success! The configuration is valid.
```

**Or with errors:**
```
Error: Missing required argument

  on main.tf line 10, in resource "aws_instance" "web":
  10: resource "aws_instance" "web" {

The argument "ami" is required, but no definition was found.
```

---

### terraform fmt

**Purpose**: Format Terraform files to canonical style

```bash
terraform fmt
```

**Common options:**
```bash
terraform fmt -recursive    # Format files in subdirectories
terraform fmt -check       # Check if formatting is needed (exit 0 if formatted)
terraform fmt -diff        # Show formatting differences
```

**Example:**
```bash
# Format all files in current directory
terraform fmt

# Format recursively and show what changed
terraform fmt -recursive -diff

# Check formatting in CI/CD
terraform fmt -check -recursive
```

---

## Output Commands

### terraform output

**Purpose**: Display output values from the state

```bash
terraform output
```

**Display specific output:**
```bash
terraform output instance_ip
```

**Get output as JSON:**
```bash
terraform output -json
```

**Example:**
```bash
# Show all outputs
terraform output

# Output:
# instance_ip = "54.123.45.67"
# instance_id = "i-0123456789abcdef"

# Get specific output
terraform output instance_ip
# Output: "54.123.45.67"

# Get JSON format
terraform output -json
# Output: {"instance_ip": {"value": "54.123.45.67", "type": "string"}, ...}
```

---

## Utility Commands

### terraform show

**Purpose**: Display the state or plan in human-readable format

```bash
terraform show
```

**Show a saved plan:**
```bash
terraform show tfplan
```

**Show as JSON:**
```bash
terraform show -json
```

---

### terraform graph

**Purpose**: Generate a visual dependency graph

```bash
terraform graph | dot -Tpng > graph.png
```

**Requires**: GraphViz (`dot` command)

**Install GraphViz:**
```bash
# macOS
brew install graphviz

# Ubuntu
sudo apt install graphviz

# Windows
choco install graphviz
```

---

### terraform version

**Purpose**: Show Terraform and provider versions

```bash
terraform version
```

**Example output:**
```
Terraform v1.6.0
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v5.23.0
+ provider registry.terraform.io/hashicorp/local v2.4.0
```

---

## Workspace Commands

**Purpose**: Manage multiple environments with separate states

```bash
terraform workspace list                  # List workspaces
terraform workspace new development       # Create new workspace
terraform workspace select development    # Switch workspace
terraform workspace show                  # Show current workspace
terraform workspace delete staging        # Delete workspace
```

**Example workflow:**
```bash
# Create and switch to development workspace
terraform workspace new development

# Apply configuration
terraform apply -auto-approve

# Switch to production
terraform workspace new production

# Apply with different variables
terraform apply -var="instance_type=t2.large" -auto-approve
```

---

## Import Command

### terraform import

**Purpose**: Import existing infrastructure into Terraform state

```bash
terraform import aws_instance.web i-0123456789abcdef
```

**Example:**
```bash
# First, create the resource block in your configuration
# main.tf
resource "aws_instance" "web" {
  # Configuration will be filled by inspecting imported resource
}

# Import the existing EC2 instance
terraform import aws_instance.web i-0123456789abcdef

# Then update the configuration to match
terraform plan  # Should show "No changes"
```

---

## Taint and Untaint (Deprecated in v1.5+)

### terraform taint (replaced by -replace)

**Old way (deprecated):**
```bash
terraform taint aws_instance.web
terraform apply
```

**New way (Terraform 1.5+):**
```bash
terraform apply -replace="aws_instance.web"
```

**Purpose**: Force recreation of a specific resource

---

## Debugging and Troubleshooting

### Enable detailed logging

```bash
# Set log level
export TF_LOG=DEBUG
export TF_LOG=TRACE  # Most verbose
export TF_LOG=INFO
export TF_LOG=WARN
export TF_LOG=ERROR

# Log to file
export TF_LOG_PATH=./terraform.log

# Run command
terraform apply

# Disable logging
unset TF_LOG
unset TF_LOG_PATH
```

### Common debugging commands

```bash
# Verify provider is correctly initialized
terraform version

# Validate configuration
terraform validate

# Check state
terraform state list
terraform show

# Refresh state from actual infrastructure
terraform refresh
```

---

## Command Cheat Sheet

| Command | Purpose | Common Usage |
|---------|---------|--------------|
| `init` | Initialize directory | `terraform init` |
| `plan` | Preview changes | `terraform plan -out=plan.tfplan` |
| `apply` | Apply changes | `terraform apply -auto-approve` |
| `destroy` | Destroy infrastructure | `terraform destroy -auto-approve` |
| `fmt` | Format code | `terraform fmt -recursive` |
| `validate` | Validate syntax | `terraform validate` |
| `show` | Show state/plan | `terraform show` |
| `output` | Show outputs | `terraform output -json` |
| `state list` | List resources | `terraform state list` |
| `state show` | Show resource | `terraform state show <resource>` |
| `import` | Import resource | `terraform import <resource> <id>` |
| `workspace` | Manage workspaces | `terraform workspace list` |
| `graph` | Dependency graph | `terraform graph` |

---

## Best Practices

1. **Always run `terraform plan` before `apply`**
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

2. **Use version control for state files**
   - Never manually edit state files
   - Use remote backends in teams
   - Commit `.terraform.lock.hcl`

3. **Format and validate regularly**
   ```bash
   terraform fmt -recursive
   terraform validate
   ```

4. **Use meaningful resource names**
   ```hcl
   # Bad
   resource "aws_instance" "i1" { }
   
   # Good
   resource "aws_instance" "web_server" { }
   ```

5. **Review before destroying**
   ```bash
   terraform plan -destroy
   # Review carefully, then:
   terraform destroy
   ```

## Practice Exercises

1. Initialize a new Terraform project and explore the created files
2. Create a plan and save it to a file, then apply that plan
3. Use `terraform state` commands to inspect your infrastructure
4. Format unformatted Terraform code
5. Create multiple workspaces and switch between them

## What's Next?

Now that you master Terraform commands, let's learn about variables and outputs!

➡️ **Next**: [Variables and Outputs](../05-variables-outputs/)

## 📚 Additional Resources

- [Terraform CLI Documentation](https://www.terraform.io/cli)
- [Command Reference](https://www.terraform.io/cli/commands)
- [State Command Reference](https://www.terraform.io/cli/commands/state)

---

[← Back: First Configuration](../03-first-config/) | [Next: Variables & Outputs →](../05-variables-outputs/)
