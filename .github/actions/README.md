# Reusable GitHub Actions

This directory contains reusable composite actions for CI/CD workflows.

## Available Actions

### 1. configure-aws-credentials

Configures AWS credentials using OIDC authentication.

**Location:** `.github/actions/configure-aws-credentials`

**Inputs:**
- `role-arn` (required): AWS IAM Role ARN to assume
- `aws-region` (required): AWS region
- `session-name` (optional): Role session name (default: GitHubActionsSession)

**Usage:**
```yaml
- name: Configure AWS credentials
  uses: ./.github/actions/configure-aws-credentials
  with:
    role-arn: ${{ env.AWS_IAM_ROLE_ARN }}
    aws-region: us-east-1
    session-name: MySession
```

---

### 2. go-build-test

Builds, tests, and lints Go applications with coverage reporting.

**Location:** `.github/actions/go-build-test`

**Inputs:**
- `go-version` (required): Go version to use
- `working-directory` (required): Working directory for the Go project
- `upload-coverage` (optional): Upload coverage to Codecov (default: true)
- `artifact-name` (optional): Name for the binary artifact (default: app-binary)
- `binary-output` (optional): Output path for the compiled binary (default: app)

**Outputs:**
- `binary-path`: Path to the compiled binary

**Usage:**
```yaml
- name: Build and test Go application
  uses: ./.github/actions/go-build-test
  with:
    go-version: '1.23'
    working-directory: web-app
    upload-coverage: 'true'
    artifact-name: web-app-binary
    binary-output: app
```

**Features:**
- Sets up Go with caching
- Downloads dependencies
- Runs golangci-lint
- Executes tests with race detection
- Generates coverage reports
- Uploads coverage to Codecov
- Builds optimized binary (CGO_ENABLED=0)
- Uploads binary as artifact

---

### 3. docker-build-push-ecr

Builds Docker images and pushes them to Amazon ECR with multiple tags.

**Location:** `.github/actions/docker-build-push-ecr`

**Inputs:**
- `ecr-repository` (required): ECR repository name
- `working-directory` (required): Working directory containing Dockerfile
- `image-tag` (required): Primary image tag (e.g., git SHA)
- `additional-tags` (optional): Comma-separated additional tags (default: latest)
- `artifact-name` (optional): Name of the binary artifact to download (empty = skip)

**Outputs:**
- `image-tag`: Primary image tag used
- `image-uri`: Full image URI with tag
- `ecr-registry`: ECR registry URL

**Usage:**
```yaml
- name: Build and push Docker image
  id: docker-push
  uses: ./.github/actions/docker-build-push-ecr
  with:
    ecr-repository: web-app
    working-directory: web-app
    image-tag: ${{ github.sha }}
    additional-tags: main,latest
    artifact-name: web-app-binary
```

**Features:**
- Downloads binary artifact (if specified)
- Logs into Amazon ECR
- Sets up Docker Buildx
- Builds image with multiple tags
- Pushes all tags to ECR
- Returns image details as outputs

---

### 4. eks-helm-deploy

Deploys applications to EKS clusters using Helm.

**Location:** `.github/actions/eks-helm-deploy`

**Inputs:**
- `cluster-name` (required): EKS cluster name
- `aws-region` (required): AWS region
- `release-name` (required): Helm release name
- `chart-path` (required): Path to Helm chart
- `namespace` (required): Kubernetes namespace
- `values-file` (optional): Path to Helm values file (empty = skip)
- `image-repository` (required): Docker image repository
- `image-tag` (required): Docker image tag
- `kubectl-version` (optional): kubectl version (default: v1.28.0)
- `helm-version` (optional): Helm version (default: v3.14.0)
- `timeout` (optional): Helm deployment timeout (default: 5m)
- `verify-deployment` (optional): Verify deployment rollout (default: true)
- `deployment-name` (optional): Name of deployment to verify (default: release-name)

**Usage:**
```yaml
- name: Deploy to EKS with Helm
  uses: ./.github/actions/eks-helm-deploy
  with:
    cluster-name: eks-cluster
    aws-region: us-east-1
    release-name: web-app
    chart-path: ./helm/web-app
    namespace: production
    values-file: ./helm/web-app/values-production.yaml
    image-repository: 123456789.dkr.ecr.us-east-1.amazonaws.com/web-app
    image-tag: abc123
    timeout: 5m
    verify-deployment: 'true'
    deployment-name: web-app-deployment
```

**Features:**
- Installs kubectl and Helm
- Updates kubeconfig for EKS
- Verifies cluster connection
- Creates namespace if not exists
- Deploys application with Helm
- Verifies deployment rollout status
- Atomic deployments (rollback on failure)

---

## Benefits of Reusable Actions

1. **Code Reusability**: Use the same actions across multiple workflows
2. **Maintainability**: Update logic in one place, changes apply everywhere
3. **Consistency**: Ensure all workflows follow the same patterns
4. **Reduced Complexity**: Workflows become shorter and more readable
5. **Easier Testing**: Test actions independently
6. **Version Control**: Actions can be versioned and referenced by tag/commit

## Example: Complete Workflow

```yaml
name: Deploy Application
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build and test
        uses: ./.github/actions/go-build-test
        with:
          go-version: '1.23'
          working-directory: app

  docker:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS
        uses: ./.github/actions/configure-aws-credentials
        with:
          role-arn: ${{ secrets.AWS_ROLE }}
          aws-region: us-east-1

      - name: Push to ECR
        uses: ./.github/actions/docker-build-push-ecr
        with:
          ecr-repository: my-app
          working-directory: app
          image-tag: ${{ github.sha }}

  deploy:
    needs: docker
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS
        uses: ./.github/actions/configure-aws-credentials
        with:
          role-arn: ${{ secrets.AWS_ROLE }}
          aws-region: us-east-1

      - name: Deploy to EKS
        uses: ./.github/actions/eks-helm-deploy
        with:
          cluster-name: my-cluster
          aws-region: us-east-1
          release-name: my-app
          chart-path: ./helm/my-app
          namespace: production
          image-repository: 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app
          image-tag: ${{ github.sha }}
```

## Creating New Reusable Actions

To create a new reusable action:

1. Create a new directory under `.github/actions/`
2. Create an `action.yml` file with the action definition
3. Define inputs, outputs, and steps
4. Use `composite` type for shell-based actions
5. Document the action in this README

For more information, see [GitHub's documentation on composite actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action).
