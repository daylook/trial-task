variable "cluster_role_name" {
  description = "Name for the EKS cluster IAM role"
  type        = string
  default     = "eksClusterRole"
}

variable "worker_node_role_name" {
  description = "Name for the EKS worker node IAM role"
  type        = string
  default     = "eksWorkerNodeRole"
}

variable "instance_profile_name" {
  description = "Name for the IAM instance profile"
  type        = string
  default     = "eks-node-instance-profile"
}