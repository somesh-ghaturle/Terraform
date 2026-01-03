output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "files_created" {
  description = "List of created files"
  value       = [for f in local_file.example : f.filename]
}

output "total_files" {
  description = "Total number of files created"
  value       = length(local_file.example) + 2 # +2 for config and readme
}

output "config_file" {
  description = "Configuration file path"
  value       = local_file.config.filename
}

output "readme_file" {
  description = "README file path"
  value       = local_file.readme.filename
}

output "file_details" {
  description = "Details of all created files"
  value = {
    for idx, file in local_file.example :
    "file_${idx + 1}" => {
      path = file.filename
      id   = file.id
    }
  }
}

output "summary" {
  description = "Summary of deployment"
  value = <<-EOT
    ╔════════════════════════════════════════╗
    ║      Deployment Summary                ║
    ╚════════════════════════════════════════╝
    
    Environment: ${var.environment}
    Project: ${var.project_name}
    Files Created: ${length(local_file.example) + 2}
    
    Main Files: ${join(", ", [for f in local_file.example : basename(f.filename)])}
    Config File: ${basename(local_file.config.filename)}
    README: ${basename(local_file.readme.filename)}
    
    Features Enabled: ${join(", ", var.enabled_features)}
  EOT
}
