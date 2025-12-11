output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "node_role_arn" {
  value = aws_iam_role.eks_worker_node_role.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.eks_node_instance_profile.name
}