variable "environment" {
  description = "Environment name (dev, staging, or prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-demo"
}

variable "file_count" {
  description = "Number of files to create"
  type        = number
  default     = 3

  validation {
    condition     = var.file_count > 0 && var.file_count <= 10
    error_message = "File count must be between 1 and 10."
  }
}

variable "content_prefix" {
  description = "Prefix for file content"
  type        = string
  default     = "Hello"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Team      = "Engineering"
    ManagedBy = "Terraform"
  }
}

variable "enabled_features" {
  description = "List of enabled features"
  type        = list(string)
  default     = ["logging", "monitoring"]
}
