variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the EKS node group IAM role"
  type        = string
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "instance_type" {
  description = "Instance type for worker nodes"
  type        = string
}

variable "iam_module_depends_on" {
  description = "Dependency to ensure IAM policies are applied before EKS cluster"
  type        = list(any)
}

variable "env" {
  description = "prject environment"
  type        = string
}

variable "eks_version" {
  description = "EKS version"
  type        = string
}

# variable "node_group_name" {
#   description = "EKS node group name"
#   type        = string
# }

# variable "security_group_ids" {
#   description = "List of security group IDs for EKS cluster"
#   type        = list(string)
# }

# variable "iam_module_depends_on" {
#   description = "Dependency to ensure IAM policies are applied before EKS cluster"
#   type        = list(any)
# }