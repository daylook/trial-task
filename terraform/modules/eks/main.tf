# -------------------
# EKS Cluster
# -------------------
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.eks_version

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = concat(var.public_subnets, var.private_subnets)
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    # IAM policies must be in place before EKS cluster creation
    var.iam_module_depends_on,
  ]

}

# -------------------
# EKS Cluster Node Group
# -------------------
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.instance_type]

  # optional
  depends_on = [
    aws_eks_cluster.eks_cluster,
  ]

}

