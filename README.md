# trial-task
Trial Task

## How to run the trial task

1. First we need to make sure that the infrastructure are well provisioned. Although we can run the terraform code in CI/CD pipelines, but we can use local provisioning. 

2. After having all the required infrastructure provisioned, then we can run the github actions workflows to deploy the app with the help of Helm charts. 

## Terraform Infrastructure as Code - AWS EKS Cluster

This repository contains Terraform configurations for provisioning an AWS EKS (Elastic Kubernetes Service) cluster with VPC, IAM roles, and associated networking resources.

The infrastructure provisions:
- **VPC** with public and private subnets (2 AZs)
- **EKS Cluster** (v1.34) with managed node groups
- **IAM Roles** for cluster and worker nodes
- **Networking** (NAT Gateway, Internet Gateway, Route Tables)
- **Security Groups** for EKS

Requirements
- AWS Account (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- IAM OIDC provider configured 
- IAM Role(used in github actions workflow): `GitHubActionsTerraformRole`

[AWS OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)


### Local Development

```bash
# Initialize
cd terraform/environments/prod
terraform init

# Select Workspace
terraform workspace select production
# Or create
terraform workspace new production

# Format & Validate
terraform fmt -recursive ../../
terraform validate

# Plan & Apply
terraform plan
terraform apply

#Option 3: Terraform Destroy (Local)
cd terraform/environments/prod
terraform workspace select production
terraform plan -destroy  # Preview
terraform destroy        # Execute
```

### Accessing the EKS Cluster

After deployment, configure kubectl:

```bash
# List clusters
aws eks list-clusters --region eu-central-1

# Or with eksctl
eksctl --region eu-central-1 get clusters

# Update kubeconfig
aws eks --region eu-central-1 update-kubeconfig --name eks-cluster

# Verify access
kubectl get nodes
```


