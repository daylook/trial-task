variable "cluster_ready" {
  description = "Dependency variable to ensure cluster is ready before installing Helm releases"
  type        = any
  default     = []
}
