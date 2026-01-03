# Example: Complete Variables and Outputs Demo

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Create multiple files using count and variables
resource "local_file" "example" {
  count    = var.file_count
  filename = "${path.module}/output/${var.environment}-file-${count.index + 1}.txt"
  content  = <<-EOT
    ${var.content_prefix} from Terraform!
    
    Environment: ${var.environment}
    Project: ${var.project_name}
    File Number: ${count.index + 1}
    Enabled Features: ${join(", ", var.enabled_features)}
    
    Tags:
    ${jsonencode(var.tags)}
  EOT
}

# Create a configuration file
resource "local_file" "config" {
  filename = "${path.module}/output/${var.environment}-config.json"
  content = jsonencode({
    environment      = var.environment
    project_name     = var.project_name
    file_count       = var.file_count
    enabled_features = var.enabled_features
    tags             = var.tags
  })
}

# Create README with summary
resource "local_file" "readme" {
  filename = "${path.module}/output/README.md"
  content  = <<-EOT
    # ${var.project_name}
    
    ## Environment: ${var.environment}
    
    This project was created with Terraform variables and outputs.
    
    ### Files Created
    ${join("\n", [for i in range(var.file_count) : "- ${var.environment}-file-${i + 1}.txt"])}
    - ${var.environment}-config.json
    
    ### Configuration
    - Total Files: ${var.file_count}
    - Content Prefix: ${var.content_prefix}
    - Features: ${join(", ", var.enabled_features)}
    
    ### Tags
    ${join("\n", [for k, v in var.tags : "- ${k}: ${v}"])}
  EOT
}
