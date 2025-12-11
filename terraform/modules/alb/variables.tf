variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "EKS security group ID to allow traffic from ALB"
  type        = string
}

# Optional: Uncomment when implementing HTTPS
# variable "certificate_arn" {
#   description = "ARN of ACM certificate for HTTPS"
#   type        = string
#   default     = ""
# }
