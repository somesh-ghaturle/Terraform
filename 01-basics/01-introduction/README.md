# Introduction to Terraform

## What is Infrastructure as Code (IaC)?

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure through machine-readable definition files, rather than manual configuration or interactive tools.

### Traditional Infrastructure Management
```
Manual Process → Click UI → Configure Settings → Document Changes
```

### Infrastructure as Code
```
Write Code → Version Control → Review → Apply Changes → Automated
```

## Why Infrastructure as Code?

### 1. **Version Control**
- Track every change to your infrastructure
- Roll back to previous versions if needed
- Understand who changed what and when

### 2. **Reproducibility**
- Create identical environments (dev, staging, production)
- No configuration drift
- Disaster recovery becomes straightforward

### 3. **Automation**
- Reduce manual errors
- Fast deployment and scaling
- Consistent results every time

### 4. **Documentation**
- Your code IS your documentation
- Self-documenting infrastructure
- Easy onboarding for new team members

## What is Terraform?

Terraform is an open-source Infrastructure as Code tool created by HashiCorp. It allows you to define infrastructure in human-readable configuration files that you can version, reuse, and share.

### Key Features

#### 1. **Declarative Language**
You describe the desired state, Terraform figures out how to achieve it:
```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

#### 2. **Multi-Cloud Support**
Manage resources across multiple providers:
- AWS (Amazon Web Services)
- Azure (Microsoft)
- GCP (Google Cloud Platform)
- Kubernetes
- And 1000+ other providers

#### 3. **State Management**
Terraform keeps track of your infrastructure in a state file, ensuring it can:
- Determine what changes need to be made
- Detect configuration drift
- Manage dependencies between resources

#### 4. **Plan Before Apply**
Always preview changes before applying:
```bash
terraform plan   # See what will change
terraform apply  # Apply the changes
```

## Terraform Workflow

```
┌──────────────┐
│    Write     │  ← Define infrastructure in .tf files
│  Configure   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   terraform  │  ← Initialize and download providers
│     init     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   terraform  │  ← Preview changes
│     plan     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   terraform  │  ← Apply changes to infrastructure
│     apply    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│Infrastructure│  ← Your resources are now live!
│   Created    │
└──────────────┘
```

## Terraform vs Other Tools

### Terraform vs CloudFormation
- **Terraform**: Multi-cloud, larger community, more providers
- **CloudFormation**: AWS-only, deeper AWS integration

### Terraform vs Ansible
- **Terraform**: Infrastructure provisioning (creating resources)
- **Ansible**: Configuration management (configuring existing servers)

### Terraform vs Pulumi
- **Terraform**: HCL (HashiCorp Configuration Language)
- **Pulumi**: General-purpose programming languages (Python, TypeScript, etc.)

## Basic Terraform Concepts

### 1. **Providers**
Plugins that interact with cloud platforms, SaaS providers, and APIs:
```hcl
provider "aws" {
  region = "us-west-2"
}
```

### 2. **Resources**
The most important element - infrastructure objects:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
```

### 3. **Variables**
Parameterize your configurations:
```hcl
variable "instance_type" {
  default = "t2.micro"
}
```

### 4. **Outputs**
Extract information from your infrastructure:
```hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

### 5. **State**
Terraform's memory of your infrastructure - stored in `terraform.tfstate`

## When to Use Terraform

✅ **Good Use Cases:**
- Provisioning cloud infrastructure
- Multi-cloud deployments
- Infrastructure standardization
- Automated infrastructure deployment
- Disaster recovery planning

❌ **Not Ideal For:**
- Application deployment (use CI/CD tools)
- Configuration management (use Ansible, Chef, Puppet)
- Real-time infrastructure changes

## Terraform Architecture

```
┌─────────────────────────────────────────────────┐
│           Terraform Configuration               │
│              (.tf files)                        │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│            Terraform Core                       │
│  (Reads config, manages state, creates plan)   │
└───────────┬─────────────────────┬───────────────┘
            │                     │
            ▼                     ▼
┌─────────────────┐     ┌─────────────────┐
│  AWS Provider   │     │ Azure Provider  │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│   AWS Cloud     │     │  Azure Cloud    │
└─────────────────┘     └─────────────────┘
```

## What's Next?

Now that you understand what Terraform is and why it's useful, let's get it installed on your system!

➡️ **Next**: [Installation Guide](../02-installation/)

## 📚 Additional Resources

- [Official Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)

---

[← Back to Basics](../README.md) | [Next: Installation →](../02-installation/)
