# Installing Terraform

This guide will help you install Terraform on your operating system.

## System Requirements

- Any modern operating system (Windows, macOS, Linux)
- Command-line terminal access
- Internet connection for downloading

## Installation Methods

Choose your operating system:

### 🍎 macOS

#### Method 1: Using Homebrew (Recommended)
```bash
# Install using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Method 2: Manual Installation
```bash
# Download the binary
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_darwin_amd64.zip

# Unzip
unzip terraform_1.6.0_darwin_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

### 🐧 Linux

#### Method 1: Using Package Manager (Ubuntu/Debian)
```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update && sudo apt install terraform
```

#### Method 2: Using Package Manager (CentOS/RHEL)
```bash
# Add HashiCorp repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Install Terraform
sudo yum -y install terraform
```

#### Method 3: Manual Installation
```bash
# Download the binary
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip

# Unzip
unzip terraform_1.6.0_linux_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

### 🪟 Windows

#### Method 1: Using Chocolatey (Recommended)
```powershell
# Install using Chocolatey
choco install terraform
```

#### Method 2: Manual Installation
1. Download the Windows binary from [Terraform Downloads](https://www.terraform.io/downloads)
2. Extract the ZIP file
3. Add the directory to your system PATH:
   - Right-click "This PC" → Properties → Advanced System Settings
   - Click "Environment Variables"
   - Edit the "Path" variable and add the Terraform directory
   - Click OK to save

4. Open a new command prompt and verify:
```cmd
terraform version
```

## Verify Installation

After installation, verify Terraform is working:

```bash
terraform version
```

You should see output like:
```
Terraform v1.6.0
on linux_amd64
```

## Installing Specific Versions

### Using tfenv (Version Manager)

`tfenv` allows you to manage multiple Terraform versions:

```bash
# Install tfenv
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# List available versions
tfenv list-remote

# Install a specific version
tfenv install 1.6.0

# Use a specific version
tfenv use 1.6.0
```

## Configure Auto-Completion

Enable tab completion for Terraform commands:

### Bash
```bash
terraform -install-autocomplete
```

### Zsh
```bash
terraform -install-autocomplete
```

### PowerShell (Windows)
Autocomplete is not officially supported but can be enabled with third-party tools.

## Setting Up Your Editor

### Visual Studio Code
Install the Terraform extension:
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "HashiCorp Terraform"
4. Install the official extension

Features:
- Syntax highlighting
- IntelliSense
- Code formatting
- Validation

### Other Editors
- **Vim**: Install [vim-terraform](https://github.com/hashivim/vim-terraform)
- **IntelliJ**: Install HashiCorp Terraform plugin
- **Sublime Text**: Install Terraform package

## Configuring Cloud Provider CLI

To use Terraform with cloud providers, you'll need their CLI tools:

### AWS CLI
```bash
# macOS/Linux
pip3 install awscli

# Verify
aws --version

# Configure
aws configure
```

### Azure CLI
```bash
# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify
az --version

# Login
az login
```

### Google Cloud CLI
```bash
# Follow installation guide at: https://cloud.google.com/sdk/docs/install

# Verify
gcloud --version

# Login
gcloud auth login
```

## Directory Structure Setup

Create a workspace for your Terraform projects:

```bash
# Create main directory
mkdir -p ~/terraform-projects

# Create a test project
mkdir -p ~/terraform-projects/test-project
cd ~/terraform-projects/test-project
```

## Testing Your Installation

Create a simple test file to ensure everything works:

```bash
# Create a test file
cat > test.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
}

output "hello_world" {
  value = "Terraform is working!"
}
EOF

# Initialize
terraform init

# Apply
terraform apply -auto-approve
```

You should see the output:
```
hello_world = "Terraform is working!"
```

## Common Installation Issues

### Issue: Command not found
**Solution**: Ensure Terraform is in your PATH
```bash
# Check if terraform is in PATH
which terraform

# If not, add to PATH
export PATH=$PATH:/path/to/terraform
```

### Issue: Permission denied
**Solution**: Make the binary executable
```bash
chmod +x /path/to/terraform
```

### Issue: Old version installed
**Solution**: Upgrade Terraform
```bash
# Using Homebrew (macOS)
brew upgrade terraform

# Using apt (Linux)
sudo apt update && sudo apt upgrade terraform
```

## Keeping Terraform Updated

### Check for Updates
```bash
terraform version
```

Visit [Terraform Releases](https://github.com/hashicorp/terraform/releases) for the latest version.

### Update Methods

**Homebrew (macOS)**:
```bash
brew upgrade terraform
```

**APT (Ubuntu/Debian)**:
```bash
sudo apt update && sudo apt upgrade terraform
```

**Manual Update**:
Download the new binary and replace the old one.

## What's Next?

Now that Terraform is installed, let's create your first configuration!

➡️ **Next**: [First Configuration](../03-first-config/)

## 📚 Additional Resources

- [Official Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Terraform Downloads](https://www.terraform.io/downloads)
- [Release Notes](https://github.com/hashicorp/terraform/releases)

---

[← Back: Introduction](../01-introduction/) | [Next: First Configuration →](../03-first-config/)
