# we use the s3 backend for storing the Terraform state file:
# - Remote State Storage to be shared across different team members or CI/CD pipelines.
# - Maintain a history of state files for recovery, with the help of AWS S3 versioning.

terraform {
  # backend "s3" {
  #   bucket         = "s3-bucket-name"
  #   key            = "eks-cluster/terraform.tfstate"  # Path to store the state in the bucket
  #   region         = "eu-central-1"
  #   dynamodb_table = "terraform-state-lock"           # Optional for state locking
  #   encrypt        = true                             # Optional
  # }

  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.27"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources for EKS cluster (used by Kubernetes and Helm providers)
# These data sources must wait for the EKS cluster to be created
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name

  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name

  depends_on = [module.eks]
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Helm provider configuration
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.aws_region]
    }
  }
}

# VPC Module
module "vpc" {
  source   = "../../modules/vpc"
  env      = var.environment
  vpc_cidr = var.vpc_cidr
  project  = var.project
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
}

# EKS Module
module "eks" {
  source                = "../../modules/eks"
  env                   = var.environment
  eks_version           = var.eks_version
  cluster_name          = var.cluster_name
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnet_ids
  public_subnets        = module.vpc.public_subnet_ids
  cluster_role_arn      = module.iam.cluster_role_arn
  node_role_arn         = module.iam.node_role_arn
  desired_size          = var.desired_size
  max_size              = var.max_size
  min_size              = var.min_size
  instance_type         = var.instance_type
  iam_module_depends_on = [module.iam]
}

# ECR Module
module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "web-app"
  environment     = var.environment
}

# ALB Module
module "alb" {
  source                = "../../modules/alb"
  cluster_name          = var.cluster_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnet_ids
  eks_security_group_id = module.vpc.eks_security_group_ids[0]
}

# Helm Releases Module (NGINX Ingress & Metrics Server)
module "helm_releases" {
  source        = "../../modules/helm-releases"
  cluster_ready = [module.eks.cluster_name, module.eks.node_group_name]

  depends_on = [module.eks]
}

# ToDo: CloudWatch and CloudTrail could be added for monitoring and observability.

