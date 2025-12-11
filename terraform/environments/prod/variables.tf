variable "aws_region" {
  description = "AWS region"
  default     = "eu-central-1"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "project" {
  description = "Project name"
  default     = "trial"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "eks-cluster"
  type        = string
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  default     = 2
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  default     = 3
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  default     = 1
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  default     = "t2.medium"
  type        = string
}

variable "environment" {
  description = "Environment"
  default     = "production"
  type        = string
}

variable "eks_version" {
  description = "EKS version"
  default     = "1.34"
  type        = string
}
