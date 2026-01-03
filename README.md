# Terraform Learning Path - From Basic to Advanced

Welcome to the comprehensive Terraform learning repository! This guide will take you from complete beginner to advanced Terraform user with hands-on examples and best practices.

## 📚 Table of Contents

- [About Terraform](#about-terraform)
- [Prerequisites](#prerequisites)
- [Learning Path](#learning-path)
- [Repository Structure](#repository-structure)
- [How to Use This Repository](#how-to-use-this-repository)
- [Contributing](#contributing)

## 🎯 About Terraform

Terraform is an open-source Infrastructure as Code (IaC) tool created by HashiCorp. It allows you to define and provision infrastructure using a declarative configuration language. With Terraform, you can manage infrastructure across multiple cloud providers (AWS, Azure, GCP, etc.) using a single workflow.

### Key Benefits:
- **Infrastructure as Code**: Version control your infrastructure
- **Multi-Cloud**: Manage resources across different providers
- **Declarative Syntax**: Define what you want, not how to get there
- **Plan & Predict**: Preview changes before applying them
- **Resource Graph**: Understand dependencies between resources

## 📋 Prerequisites

Before starting this learning path, you should have:
- Basic understanding of cloud computing concepts
- Familiarity with command-line interfaces
- A text editor (VS Code, Sublime, etc.)
- An account with a cloud provider (AWS, Azure, or GCP) for hands-on practice

## 🚀 Learning Path

This repository is organized into progressive modules:

### 1. [Basics](./01-basics/) 
Start here if you're new to Terraform
- Introduction to Infrastructure as Code
- Installing Terraform
- Your first Terraform configuration
- Understanding Terraform commands
- Variables and outputs
- Basic resource management

### 2. [Intermediate](./02-intermediate/)
Build upon the basics
- Creating and using modules
- State management
- Provisioners
- Data sources
- Workspaces
- Terraform functions

### 3. [Advanced](./03-advanced/)
Master advanced concepts
- Remote state configuration
- Dynamic blocks and expressions
- For and for_each loops
- Advanced functions
- Custom providers
- Best practices and design patterns

### 4. [Real-World Examples](./04-real-world-examples/)
Practical implementations
- Complete AWS infrastructure
- Multi-cloud deployments
- CI/CD integration
- Production-ready patterns

## 📁 Repository Structure

```
.
├── 01-basics/
│   ├── 01-introduction/
│   ├── 02-installation/
│   ├── 03-first-config/
│   ├── 04-commands/
│   └── 05-variables-outputs/
├── 02-intermediate/
│   ├── 01-modules/
│   ├── 02-state-management/
│   ├── 03-provisioners/
│   ├── 04-data-sources/
│   └── 05-workspaces/
├── 03-advanced/
│   ├── 01-remote-state/
│   ├── 02-dynamic-blocks/
│   ├── 03-loops-expressions/
│   ├── 04-functions/
│   └── 05-best-practices/
└── 04-real-world-examples/
    ├── aws-infrastructure/
    ├── multi-cloud/
    └── cicd-integration/
```

## 💡 How to Use This Repository

1. **Clone the repository**:
   ```bash
   git clone https://github.com/somesh-ghaturle/Terraform.git
   cd Terraform
   ```

2. **Start with the basics**: Navigate to `01-basics/` and follow the modules in order

3. **Practice**: Each module contains examples you can run. Make sure to:
   - Read the README in each section
   - Try the examples
   - Modify and experiment
   - Clean up resources after practice

4. **Progress gradually**: Don't skip ahead - each section builds on previous knowledge

## ⚠️ Important Notes

- **Cost Warning**: Running examples may incur costs in your cloud provider account. Always:
  - Use free tier resources when possible
  - Run `terraform destroy` after practicing
  - Monitor your cloud provider billing

- **Safety First**: 
  - Never commit sensitive information (API keys, passwords)
  - Use variables and environment variables for credentials
  - Review changes with `terraform plan` before applying

## 🤝 Contributing

Contributions are welcome! If you find errors or want to add examples:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📚 Additional Resources

- [Official Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## 📄 License

This project is open source and available for educational purposes.

---

**Happy Learning! 🎉**

Start your journey with [01-basics](./01-basics/) →