# Contributing to Terraform Learning Repository

Thank you for your interest in contributing! This repository aims to help people learn Terraform from basic to advanced concepts.

## How to Contribute

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR-USERNAME/Terraform.git
cd Terraform
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Make Your Changes

- Add new examples
- Fix errors or typos
- Improve documentation
- Add new sections

### 4. Test Your Changes

If you're adding Terraform code:

```bash
cd your-example-directory
terraform init
terraform validate
terraform fmt -recursive
terraform plan
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "Add: descriptive message about your changes"
```

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Contribution Guidelines

### Code Style

- Use consistent formatting: `terraform fmt -recursive`
- Add comments for complex logic
- Follow naming conventions (snake_case for resources)
- Include descriptive variable descriptions

### Documentation

- Update README files when adding new content
- Use clear, beginner-friendly language
- Include practical examples
- Add troubleshooting tips

### Examples

- Test all examples before submitting
- Include terraform.tfvars.example files
- Add cost estimates where applicable
- Document prerequisites clearly
- Provide cleanup instructions

### Structure

Follow the existing structure:
```
section/
├── README.md           # Overview and navigation
├── subsection/
│   ├── README.md      # Detailed explanation
│   ├── main.tf        # Example code
│   ├── variables.tf
│   ├── outputs.tf
│   └── *.example      # Example configurations
```

## What We're Looking For

- ✅ Beginner-friendly explanations
- ✅ Real-world practical examples
- ✅ Best practices and patterns
- ✅ Common pitfalls and solutions
- ✅ Updated provider versions
- ✅ Security considerations

## What to Avoid

- ❌ Overly complex examples for beginners
- ❌ Deprecated Terraform features
- ❌ Hardcoded sensitive information
- ❌ Untested code
- ❌ Incomplete documentation

## Questions?

Feel free to open an issue for:
- Questions about contributing
- Suggestions for new content
- Reporting errors or issues
- General feedback

## Code of Conduct

- Be respectful and inclusive
- Help others learn
- Provide constructive feedback
- Keep discussions on-topic

## License

By contributing, you agree that your contributions will be licensed under the same license as this project.

---

Thank you for helping others learn Terraform! 🎉
