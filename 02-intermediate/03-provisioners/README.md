# Terraform Provisioners

Provisioners allow you to execute scripts and commands on resources after creation. Use them as a last resort when native provider features aren't available.

## ⚠️ Important Note

**Provisioners should be used sparingly.** Terraform recommends using native provider features or configuration management tools (Ansible, Chef, Puppet) instead.

## Types of Provisioners

### 1. local-exec Provisioner

Runs commands on the machine running Terraform.

```hcl
resource "local_file" "example" {
  filename = "${path.module}/output/example.txt"
  content  = "Hello, Terraform!"
  
  provisioner "local-exec" {
    command = "echo 'File created at ${self.filename}'"
  }
}
```

**Common use cases:**
- Running local scripts
- Updating DNS records
- Sending notifications
- Triggering CI/CD pipelines

### 2. remote-exec Provisioner

Runs commands on the remote resource.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  key_name      = var.key_name
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }
}
```

### 3. file Provisioner

Copies files to the remote resource.

```hcl
resource "aws_instance" "web" {
  # ... instance configuration ...
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }
  
  provisioner "file" {
    source      = "app.conf"
    destination = "/tmp/app.conf"
  }
  
  provisioner "file" {
    content     = "Hello from Terraform"
    destination = "/tmp/hello.txt"
  }
}
```

## Connection Types

### SSH Connection
```hcl
connection {
  type        = "ssh"
  user        = "ubuntu"
  private_key = file("~/.ssh/id_rsa")
  host        = self.public_ip
  timeout     = "5m"
}
```

### WinRM Connection (Windows)
```hcl
connection {
  type     = "winrm"
  user     = "Administrator"
  password = var.admin_password
  host     = self.public_ip
  timeout  = "10m"
}
```

## Creation-Time vs Destroy-Time

### Creation-Time (Default)
Runs when resource is created:
```hcl
provisioner "local-exec" {
  command = "echo 'Resource created'"
}
```

### Destroy-Time
Runs when resource is destroyed:
```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo 'Resource will be destroyed'"
}
```

## Failure Behavior

### Continue on Failure (Default)
```hcl
provisioner "remote-exec" {
  inline = ["some-command"]
  
  on_failure = continue  # Continue even if provisioner fails
}
```

### Fail on Error
```hcl
provisioner "remote-exec" {
  inline = ["some-command"]
  
  on_failure = fail  # Stop and mark resource as tainted
}
```

## Practical Examples

### Example 1: Bootstrap Script
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/terraform")
    host        = self.public_ip
  }
  
  # Upload bootstrap script
  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  
  # Execute bootstrap script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh"
    ]
  }
}
```

### Example 2: Send Notification
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  provisioner "local-exec" {
    command = <<-EOT
      curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL \
        -H 'Content-Type: application/json' \
        -d '{"text":"EC2 instance ${self.id} created"}'
    EOT
  }
}
```

### Example 3: Configuration Management
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' playbook.yml"
  }
}
```

## Best Practices

### ✅ Do:
- Use user_data or cloud-init when possible
- Use configuration management tools
- Keep provisioners simple
- Use for emergency fixes only
- Test provisioners thoroughly

### ❌ Don't:
- Rely on provisioners for critical operations
- Use for application deployment
- Use instead of proper configuration management
- Create complex provisioning logic

## Alternatives to Provisioners

### 1. User Data / Cloud-Init
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
  EOF
}
```

### 2. Configuration Management
- Ansible
- Chef
- Puppet
- SaltStack

### 3. Container Images
- Build with Packer
- Use Docker/Kubernetes

### 4. Custom AMIs
```hcl
data "aws_ami" "custom" {
  most_recent = true
  owners      = ["self"]
  
  filter {
    name   = "name"
    values = ["my-custom-ami-*"]
  }
}
```

## Troubleshooting

### Connection Timeout
```hcl
connection {
  type    = "ssh"
  host    = self.public_ip
  timeout = "10m"  # Increase timeout
}
```

### SSH Key Issues
```bash
# Ensure correct permissions
chmod 600 ~/.ssh/id_rsa

# Test connection manually
ssh -i ~/.ssh/id_rsa user@host
```

### Debugging
```hcl
provisioner "local-exec" {
  command = "echo 'Debug: ${self.id}' >> debug.log"
}
```

## Summary

- Provisioners are a last resort
- Use native provider features when possible
- Prefer configuration management tools
- Keep provisioners simple and idempotent
- Test thoroughly before production use

---

[← Back: State Management](../02-state-management/) | [Next: Data Sources →](../04-data-sources/)
