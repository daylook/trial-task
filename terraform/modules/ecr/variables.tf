variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

# Optional: Uncomment if using repository policy
# variable "allowed_principals" {
#   description = "List of AWS principal ARNs allowed to access the repository"
#   type        = list(string)
#   default     = []
# }
