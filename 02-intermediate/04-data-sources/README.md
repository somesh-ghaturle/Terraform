# Terraform Data Sources

Data sources allow Terraform to fetch and use information from existing infrastructure or external systems.

## What are Data Sources?

Data sources read information from infrastructure that was created outside of Terraform or by a different Terraform configuration.

### Resource vs Data Source

```hcl
# Resource: Creates/Manages infrastructure
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

# Data Source: Reads existing infrastructure
data "aws_instance" "web" {
  instance_id = "i-1234567890"
}
```

## Basic Syntax

```hcl
data "provider_type" "name" {
  # Filter criteria
  filter {
    name   = "attribute"
    values = ["value"]
  }
}

# Reference the data
output "result" {
  value = data.provider_type.name.attribute
}
```

## Common Data Sources

### AWS Examples

#### 1. Latest AMI
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}
```

#### 2. Availability Zones
```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "example" {
  count             = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index)
  vpc_id            = aws_vpc.main.id
}
```

#### 3. Current AWS Region
```hcl
data "aws_region" "current" {}

output "current_region" {
  value = data.aws_region.current.name
}
```

#### 4. Current AWS Account
```hcl
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```

#### 5. Existing VPC
```hcl
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["production-vpc"]
  }
}

resource "aws_subnet" "example" {
  vpc_id     = data.aws_vpc.selected.id
  cidr_block = "10.0.1.0/24"
}
```

### Local Provider Examples

#### 1. Read File
```hcl
data "local_file" "config" {
  filename = "${path.module}/config.json"
}

output "config_content" {
  value = data.local_file.config.content
}
```

### Template Provider

#### 1. Template File
```hcl
data "template_file" "init" {
  template = file("${path.module}/init.tpl")
  
  vars = {
    hostname = var.hostname
    region   = var.region
  }
}

resource "aws_instance" "web" {
  user_data = data.template_file.init.rendered
}
```

## Practical Examples

### Example 1: Dynamic AMI Selection

```hcl
# variables.tf
variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "ubuntu"
}

# data.tf
data "aws_ami" "selected" {
  most_recent = true
  
  filter {
    name   = "name"
    values = var.os_type == "ubuntu" ? ["ubuntu/images/hvm-ssd/ubuntu-*"] : ["amzn2-ami-hvm-*"]
  }
  
  owners = var.os_type == "ubuntu" ? ["099720109477"] : ["amazon"]
}

# main.tf
resource "aws_instance" "web" {
  ami           = data.aws_ami.selected.id
  instance_type = "t2.micro"
}
```

### Example 2: Multi-Region Deployment

```hcl
data "aws_regions" "all" {}

output "all_regions" {
  value = data.aws_regions.all.names
}

# Deploy to multiple regions
provider "aws" {
  for_each = toset(data.aws_regions.all.names)
  alias    = each.key
  region   = each.key
}
```

### Example 3: Security Group Lookup

```hcl
data "aws_security_groups" "web" {
  filter {
    name   = "tag:Environment"
    values = ["production"]
  }
  
  filter {
    name   = "tag:Type"
    values = ["web"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = data.aws_security_groups.web.ids
}
```

### Example 4: Remote State Data Source

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  
  config = {
    bucket = "my-terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
  vpc_id    = data.terraform_remote_state.network.outputs.vpc_id
}
```

## Data Source with Count

```hcl
data "aws_subnet" "selected" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

output "subnet_cidrs" {
  value = data.aws_subnet.selected[*].cidr_block
}
```

## Data Source with For_Each

```hcl
variable "instance_ids" {
  type = set(string)
  default = ["i-123", "i-456", "i-789"]
}

data "aws_instance" "selected" {
  for_each    = var.instance_ids
  instance_id = each.key
}

output "instance_ips" {
  value = {
    for k, v in data.aws_instance.selected : k => v.public_ip
  }
}
```

## Complete Example

```hcl
# data.tf - All data sources in one file
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# main.tf - Use the data
resource "aws_instance" "web" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  availability_zone = data.aws_availability_zones.available.names[0]
  subnet_id         = tolist(data.aws_subnets.default.ids)[0]
  
  tags = {
    Name   = "web-server"
    Region = data.aws_region.current.name
  }
}

# outputs.tf
output "instance_info" {
  value = {
    ami_id      = data.aws_ami.ubuntu.id
    ami_name    = data.aws_ami.ubuntu.name
    region      = data.aws_region.current.name
    az          = data.aws_availability_zones.available.names[0]
    vpc_id      = data.aws_vpc.default.id
    instance_id = aws_instance.web.id
  }
}
```

## Best Practices

### ✅ Do:
- Use data sources to avoid hardcoding
- Query for latest AMIs
- Reference existing infrastructure
- Share data between configurations
- Use filters for specific resources

### ❌ Don't:
- Use data sources for resources you manage
- Assume data source will always return results
- Ignore potential API rate limits
- Use data sources for sensitive information without proper access controls

## Common Patterns

### Pattern 1: Environment-Specific Lookups
```hcl
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
}
```

### Pattern 2: Dynamic Resource Discovery
```hcl
data "aws_instances" "web_servers" {
  instance_tags = {
    Type = "web"
    Environment = var.environment
  }
}
```

### Pattern 3: Conditional Data Source
```hcl
data "aws_vpc" "existing" {
  count = var.create_vpc ? 0 : 1
  id    = var.vpc_id
}

locals {
  vpc_id = var.create_vpc ? aws_vpc.new[0].id : data.aws_vpc.existing[0].id
}
```

## Troubleshooting

### No Results Found
```hcl
# Add default handling
locals {
  vpc_id = try(data.aws_vpc.selected.id, aws_vpc.default.id)
}
```

### Multiple Results
```hcl
# Use most_recent or specific filters
data "aws_ami" "selected" {
  most_recent = true  # Get the latest
  # Add more specific filters
}
```

## Summary

- Data sources read existing infrastructure
- Use for dynamic configuration
- Essential for cross-stack references
- Reduce hardcoded values
- Enable infrastructure discovery

---

[← Back: Provisioners](../03-provisioners/) | [Next: Workspaces →](../05-workspaces/)
