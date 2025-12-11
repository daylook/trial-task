output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "node_group_name" {
  value = aws_eks_node_group.eks_node_group.node_group_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

# extra added
output "eks_kubeconfig" {
  sensitive = true
  value     = <<EOL
apiVersion: v1
clusters:
- cluster:
    server: ${data.aws_eks_cluster.eks_cluster.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.eks_cluster.certificate_authority.0.data}
  name: ${data.aws_eks_cluster.eks_cluster.name}
contexts:
- context:
    cluster: ${data.aws_eks_cluster.eks_cluster.name}
    user: ${data.aws_eks_cluster.eks_cluster.name}
  name: ${data.aws_eks_cluster.eks_cluster.name}
current-context: ${data.aws_eks_cluster.eks_cluster.name}
kind: Config
preferences: {}
users:
- name: ${data.aws_eks_cluster.eks_cluster.name}
  user:
    token: ${data.aws_eks_cluster_auth.eks_cluster_auth.token}
EOL
}