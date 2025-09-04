# Automation Solution - {LAB_NAME}

## Overview
This guide provides automated deployment scripts and Infrastructure as Code (IaC) for completing the {LAB_ID} challenge lab.

## Prerequisites
- Google Cloud SDK installed
- Terraform installed (if using Terraform)
- Appropriate IAM permissions
- Git (for cloning repositories)

## Quick Start
```bash
# Clone the repository
git clone https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest.git

# Navigate to this lab's automation folder
cd "Google-Cloud-Challenge-Lab-Solutions-Latest/1-Beginner: Get Started with Google Cloud/Challenge Lab Solutions/{LAB_FOLDER}/Pro"

# Run the automation script
chmod +x deploy.sh
./deploy.sh your-project-id
```

## Automation Scripts

### 1. Complete Deployment Script
```bash
#!/bin/bash
# File: deploy.sh

PROJECT_ID=$1
REGION=us-central1
ZONE=us-central1-a

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: $0 <PROJECT_ID>"
    exit 1
fi

echo "Starting automated deployment for $PROJECT_ID..."

# Set up environment
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Enable required APIs
gcloud services enable [required-apis]

# Deploy resources
# [Automated commands for all tasks]

echo "Deployment completed successfully!"
```

### 2. Terraform Configuration
```hcl
# File: main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Variables
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Google Cloud Zone"
  type        = string
  default     = "us-central1-a"
}

# Resources for Task 1
resource "google_[resource_type]" "task1" {
  # Resource configuration
}

# Resources for Task 2
resource "google_[resource_type]" "task2" {
  # Resource configuration
}

# Resources for Task 3
resource "google_[resource_type]" "task3" {
  # Resource configuration
}

# Outputs
output "task1_result" {
  value = google_[resource_type].task1.[attribute]
}
```

### 3. Cloud Deployment Manager
```yaml
# File: deployment.yaml

imports:
- path: templates/[resource].jinja

resources:
- name: task1-resource
  type: templates/[resource].jinja
  properties:
    # Resource properties

- name: task2-resource
  type: templates/[resource].jinja
  properties:
    # Resource properties

- name: task3-resource
  type: templates/[resource].jinja
  properties:
    # Resource properties
```

## Deployment Options

### Option 1: Bash Script Deployment
```bash
# Make script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh your-project-id
```

### Option 2: Terraform Deployment
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var="project_id=your-project-id"

# Apply deployment
terraform apply -var="project_id=your-project-id" -auto-approve
```

### Option 3: Cloud Deployment Manager
```bash
# Deploy using Deployment Manager
gcloud deployment-manager deployments create {lab-name}-deployment \
    --config deployment.yaml
```

## Cleanup Scripts

### Bash Cleanup
```bash
#!/bin/bash
# File: cleanup.sh

PROJECT_ID=$1

echo "Cleaning up resources for $PROJECT_ID..."

# Delete resources created
gcloud [cleanup commands]

echo "Cleanup completed!"
```

### Terraform Cleanup
```bash
# Destroy all resources
terraform destroy -var="project_id=your-project-id" -auto-approve
```

## Monitoring and Validation
```bash
#!/bin/bash
# File: validate.sh

# Validate Task 1
echo "Validating Task 1..."
gcloud [validation command]

# Validate Task 2
echo "Validating Task 2..."
gcloud [validation command]

# Validate Task 3
echo "Validating Task 3..."
gcloud [validation command]

echo "All validations completed!"
```

## File Structure
```
Pro/
├── deploy.sh                 # Main deployment script
├── cleanup.sh               # Cleanup script
├── validate.sh              # Validation script
├── main.tf                  # Terraform main configuration
├── variables.tf             # Terraform variables
├── outputs.tf               # Terraform outputs
├── deployment.yaml          # Cloud Deployment Manager
└── templates/               # Template files
    └── [resource].jinja
```

## Troubleshooting
- **API Issues**: Ensure all required APIs are enabled
- **Permission Issues**: Check IAM roles and permissions
- **Resource Conflicts**: Ensure unique resource names
- **Quota Issues**: Check project quotas and limits

## Advanced Features
- **Multi-environment support**: Separate configurations for dev/staging/prod
- **State management**: Remote state storage for Terraform
- **CI/CD integration**: GitHub Actions workflows
- **Cost optimization**: Resource tagging and cost monitoring

---
*Solution provided by [CodeWithGarry](https://github.com/codewithgarry)*
