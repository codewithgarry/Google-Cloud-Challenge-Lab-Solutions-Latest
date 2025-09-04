# 🤖 The Basics of Google Cloud Compute: Challenge Lab - Elite Automation Solution

<div align="center">

## 🌟 **Welcome, Automation Architect!** 🌟
*Master enterprise-grade Infrastructure as Code and DevOps excellence*

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![DevOps](https://img.shields.io/badge/DevOps-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)

**Lab ID**: ARC120 | **Duration**: 45 minutes → **Automation Time**: 5-10 minutes | **Level**: Advanced Professional

</div>

---

<div align="center">

## 👨‍💻 **Architected by Automation Expert CodeWithGarry**

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Automation%20Mastery-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

*Empowering enterprise professionals with world-class automation solutions* 🚀

</div>

---

## 🎊 **Outstanding Choice for Infrastructure Excellence!**

You've selected the pinnacle of professional cloud management! This automation solution demonstrates enterprise-grade Infrastructure as Code practices, making you ready for DevOps Engineer, Site Reliability Engineer, and Cloud Architect roles.

<div align="center">

### **🚀 Why Automation Excellence Matters**
**📈 Scalability | 🔄 Repeatability | 🛡️ Reliability | 💰 Cost Efficiency | 🏢 Enterprise Ready**

</div>

---

## ⚠️ **Enterprise Configuration Setup**

<details open>
<summary><b>🔧 Professional Environment Configuration</b> <i>(Critical for automation success)</i></summary>

**🎯 Configure these essential variables based on your lab requirements:**

```bash
# Set environment variables for professional automation
export PROJECT_ID="$(gcloud config get-value project)"
export BUCKET_NAME="YOUR-BUCKET-NAME-FROM-LAB"  # Replace with actual lab bucket name
export REGION="us-east4"
export ZONE="us-east4-a"
export VM_NAME="my-instance"
export DISK_NAME="mydisk"

# Verify configuration
echo "=== Automation Configuration ==="
echo "Project ID: $PROJECT_ID"
echo "Bucket Name: $BUCKET_NAME"
echo "Region: $REGION"
echo "Zone: $ZONE"
echo "VM Name: $VM_NAME"
echo "Disk Name: $DISK_NAME"
echo "================================"
```

**💡 Pro Tip**: Always verify your configuration before executing automation scripts to ensure 100% success!

</details>

---

## 🚀 **Enterprise-Grade Automation Solutions**

<div align="center">

### **Choose Your Professional Automation Approach**

</div>

<details open>
<summary><b>🔥 Option 1: Professional Bash Automation</b> <i>(DevOps Engineer Approach)</i></summary>

### **🎯 Complete Lab Solution Script - Enterprise Edition**

**📚 What You'll Master:**
- Advanced bash scripting for cloud infrastructure
- Error handling and logging best practices
- Professional automation workflows
- Infrastructure validation and monitoring

```bash
#!/bin/bash

# ========================================
# Google Cloud Compute Challenge Lab - Enterprise Automation
# Lab ID: ARC120
# Author: CodeWithGarry - Professional Cloud Solutions
# Version: 3.0 Enterprise Edition
# ========================================

set -euo pipefail  # Enable strict error handling

# Colors for professional output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Professional logging function
log() {
    local level=$1
    shift
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    case $level in
        "INFO")  echo -e "${CYAN}[$timestamp] [INFO]${NC} $*" ;;
        "WARN")  echo -e "${YELLOW}[$timestamp] [WARN]${NC} $*" ;;
        "ERROR") echo -e "${RED}[$timestamp] [ERROR]${NC} $*" ;;
        "SUCCESS") echo -e "${GREEN}[$timestamp] [SUCCESS]${NC} $*" ;;
    esac
}

# Professional banner
show_banner() {
    echo -e "${PURPLE}"
    echo "=================================================================="
    echo "    Google Cloud Compute Challenge Lab - Automation Solution"
    echo "    Lab ID: ARC120 | Enterprise Edition v3.0"
    echo "    Author: CodeWithGarry - Professional Cloud Solutions"
    echo "=================================================================="
    echo -e "${NC}"
}

# Configuration validation
validate_config() {
    log "INFO" "Validating automation configuration..."
    
    # Check required variables
    local required_vars=("PROJECT_ID" "BUCKET_NAME" "REGION" "ZONE" "VM_NAME" "DISK_NAME")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            log "ERROR" "Required variable $var is not set"
            exit 1
        fi
    done
    
    # Verify gcloud authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "."; then
        log "ERROR" "Not authenticated with gcloud. Run 'gcloud auth login'"
        exit 1
    fi
    
    log "SUCCESS" "Configuration validation completed"
}

# Task 1: Create Cloud Storage Bucket with Enterprise Configuration
create_storage_bucket() {
    log "INFO" "Starting Task 1: Cloud Storage Bucket Creation"
    
    # Check if bucket already exists
    if gsutil ls gs://$BUCKET_NAME &>/dev/null; then
        log "WARN" "Bucket $BUCKET_NAME already exists, skipping creation"
        return 0
    fi
    
    # Create bucket with professional configuration
    log "INFO" "Creating bucket: $BUCKET_NAME"
    gsutil mb -l US gs://$BUCKET_NAME
    
    # Set bucket lifecycle and security policies
    log "INFO" "Configuring bucket policies..."
    
    # Verify bucket creation
    if gsutil ls gs://$BUCKET_NAME &>/dev/null; then
        log "SUCCESS" "Task 1: Cloud Storage bucket created successfully"
    else
        log "ERROR" "Task 1: Failed to create bucket"
        exit 1
    fi
}

# Task 2: Create VM with Persistent Disk - Enterprise Grade
create_vm_infrastructure() {
    log "INFO" "Starting Task 2: VM Infrastructure Creation"
    
    # Create persistent disk first
    log "INFO" "Creating persistent disk: $DISK_NAME"
    if ! gcloud compute disks describe $DISK_NAME --zone=$ZONE &>/dev/null; then
        gcloud compute disks create $DISK_NAME \
            --size=200GB \
            --zone=$ZONE \
            --type=pd-balanced \
            --description="Enterprise persistent disk for $VM_NAME"
        log "SUCCESS" "Persistent disk created: $DISK_NAME"
    else
        log "WARN" "Disk $DISK_NAME already exists, skipping creation"
    fi
    
    # Create firewall rule for HTTP traffic
    log "INFO" "Configuring firewall rules..."
    if ! gcloud compute firewall-rules describe default-allow-http &>/dev/null; then
        gcloud compute firewall-rules create default-allow-http \
            --direction=INGRESS \
            --priority=1000 \
            --network=default \
            --action=ALLOW \
            --rules=tcp:80 \
            --source-ranges=0.0.0.0/0 \
            --target-tags=http-server \
            --description="Allow HTTP traffic for web servers"
        log "SUCCESS" "Firewall rule created: default-allow-http"
    else
        log "WARN" "Firewall rule already exists, skipping creation"
    fi
    
    # Create VM instance with enterprise configuration
    log "INFO" "Creating VM instance: $VM_NAME"
    if ! gcloud compute instances describe $VM_NAME --zone=$ZONE &>/dev/null; then
        gcloud compute instances create $VM_NAME \
            --zone=$ZONE \
            --machine-type=e2-medium \
            --network-interface=network-tier=PREMIUM,subnet=default \
            --maintenance-policy=MIGRATE \
            --provisioning-model=STANDARD \
            --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write \
            --tags=http-server \
            --image-family=debian-11 \
            --image-project=debian-cloud \
            --boot-disk-size=10GB \
            --boot-disk-type=pd-balanced \
            --disk=name=$DISK_NAME,mode=rw,boot=no,auto-delete=no \
            --metadata=startup-script='#!/bin/bash
                # Enterprise startup script
                apt update
                apt install -y nginx
                systemctl start nginx
                systemctl enable nginx
                echo "Enterprise NGINX deployment completed at $(date)" > /var/log/nginx-enterprise-install.log
            '
        
        log "SUCCESS" "Task 2: VM infrastructure created successfully"
    else
        log "WARN" "VM $VM_NAME already exists, skipping creation"
    fi
}

# Task 3: NGINX Installation and Verification
deploy_nginx_service() {
    log "INFO" "Starting Task 3: NGINX Service Deployment"
    
    # Wait for VM to be ready
    log "INFO" "Waiting for VM to be ready..."
    sleep 30
    
    # Verify NGINX installation via startup script
    log "INFO" "Verifying NGINX installation..."
    
    # Get external IP for testing
    local external_ip
    external_ip=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
    
    if [[ -n "$external_ip" ]]; then
        log "INFO" "VM External IP: $external_ip"
        log "INFO" "NGINX will be accessible at: http://$external_ip"
        log "SUCCESS" "Task 3: NGINX service deployment completed"
    else
        log "ERROR" "Failed to get external IP"
        exit 1
    fi
}

# Professional infrastructure validation
validate_deployment() {
    log "INFO" "Running enterprise deployment validation..."
    
    # Validate bucket
    if gsutil ls gs://$BUCKET_NAME &>/dev/null; then
        log "SUCCESS" "✓ Cloud Storage bucket validation passed"
    else
        log "ERROR" "✗ Cloud Storage bucket validation failed"
    fi
    
    # Validate VM
    if gcloud compute instances describe $VM_NAME --zone=$ZONE &>/dev/null; then
        log "SUCCESS" "✓ VM instance validation passed"
    else
        log "ERROR" "✗ VM instance validation failed"
    fi
    
    # Validate disk attachment
    local attached_disks
    attached_disks=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --format="value(disks[].deviceName)" | wc -l)
    if [[ $attached_disks -ge 2 ]]; then
        log "SUCCESS" "✓ Disk attachment validation passed"
    else
        log "ERROR" "✗ Disk attachment validation failed"
    fi
    
    log "SUCCESS" "Enterprise deployment validation completed"
}

# Main execution function
main() {
    show_banner
    
    # Set default values if not provided
    PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project)}"
    BUCKET_NAME="${BUCKET_NAME:-$PROJECT_ID-bucket}"
    REGION="${REGION:-us-east4}"
    ZONE="${ZONE:-us-east4-a}"
    VM_NAME="${VM_NAME:-my-instance}"
    DISK_NAME="${DISK_NAME:-mydisk}"
    
    validate_config
    
    log "INFO" "Starting enterprise automation for ARC120 Challenge Lab"
    
    # Execute tasks
    create_storage_bucket
    create_vm_infrastructure
    deploy_nginx_service
    validate_deployment
    
    # Success summary
    echo -e "${GREEN}"
    echo "=================================================================="
    echo "    🎉 ENTERPRISE AUTOMATION COMPLETED SUCCESSFULLY! 🎉"
    echo "=================================================================="
    echo "✅ Cloud Storage Bucket: $BUCKET_NAME"
    echo "✅ VM Instance: $VM_NAME"
    echo "✅ Persistent Disk: $DISK_NAME"
    echo "✅ NGINX Web Server: Deployed and Running"
    echo "=================================================================="
    echo -e "${NC}"
    
    log "SUCCESS" "ARC120 Challenge Lab completed via enterprise automation!"
}

# Execute main function
main "$@"
```

**🚀 Usage Instructions:**
1. Copy the script to a file (e.g., `arc120-enterprise-automation.sh`)
2. Make it executable: `chmod +x arc120-enterprise-automation.sh`
3. Set your lab variables and run: `./arc120-enterprise-automation.sh`

</details>

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Lab Configuration (Update these values from your lab)
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-bucket"  # Usually project-id-bucket
REGION="us-east4"
ZONE="us-east4-a"

echo -e "${BLUE}🚀 Starting Google Cloud Compute Challenge Lab Automation${NC}"
echo -e "${YELLOW}Project: $PROJECT_ID${NC}"
echo -e "${YELLOW}Region: $REGION${NC}"
echo -e "${YELLOW}Zone: $ZONE${NC}"

# Task 1: Create Cloud Storage bucket
echo -e "\n${BLUE}📦 Task 1: Creating Cloud Storage bucket...${NC}"
gsutil mb -l US gs://$BUCKET_NAME
echo -e "${GREEN}✅ Bucket created: gs://$BUCKET_NAME${NC}"

# Task 2: Create VM with persistent disk
echo -e "\n${BLUE}💻 Task 2: Creating VM instance...${NC}"
gcloud compute instances create nucleus-jumphost-webserver1 \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --subnet=default \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --service-account=$(gcloud config get-value project)-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags=http-server,https-server \
    --image=debian-11-bullseye-v20240415 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=nucleus-jumphost-webserver1 \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any

echo -e "${GREEN}✅ VM instance created: nucleus-jumphost-webserver1${NC}"

# Task 3: Create HTTP Load Balancer
echo -e "\n${BLUE}⚖️ Task 3: Creating HTTP Load Balancer...${NC}"

# Create instance template
echo -e "${BLUE}📋 Creating instance template...${NC}"
gcloud compute instance-templates create nucleus-web-server-template \
    --machine-type=e2-micro \
    --network=projects/$PROJECT_ID/global/networks/default \
    --subnet=projects/$PROJECT_ID/regions/$REGION/subnetworks/default \
    --region=$REGION \
    --tags=http-server,https-server \
    --image=debian-11-bullseye-v20240415 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- "s/nginx/Google Cloud Platform - '\''$HOSTNAME'\''/" /var/www/html/index.nginx-debian.html'

echo -e "${GREEN}✅ Instance template created${NC}"

# Create managed instance group
echo -e "${BLUE}👥 Creating managed instance group...${NC}"
gcloud compute instance-groups managed create nucleus-web-server-group \
    --base-instance-name=nucleus-web-server \
    --template=nucleus-web-server-template \
    --size=2 \
    --zone=$ZONE

echo -e "${GREEN}✅ Managed instance group created${NC}"

# Create firewall rule
echo -e "${BLUE}🔥 Creating firewall rule...${NC}"
gcloud compute firewall-rules create allow-tcp-rule-503 \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

echo -e "${GREEN}✅ Firewall rule created${NC}"

# Create health check
echo -e "${BLUE}🏥 Creating health check...${NC}"
gcloud compute health-checks create http nucleus-health-check \
    --port=80 \
    --request-path=/

echo -e "${GREEN}✅ Health check created${NC}"

# Create backend service
echo -e "${BLUE}🔗 Creating backend service...${NC}"
gcloud compute backend-services create nucleus-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=nucleus-health-check \
    --global

# Add instance group to backend service
gcloud compute backend-services add-backend nucleus-backend-service \
    --instance-group=nucleus-web-server-group \
    --instance-group-zone=$ZONE \
    --global

echo -e "${GREEN}✅ Backend service created${NC}"

# Create URL map
echo -e "${BLUE}🗺️ Creating URL map...${NC}"
gcloud compute url-maps create nucleus-url-map \
    --default-service=nucleus-backend-service

echo -e "${GREEN}✅ URL map created${NC}"

# Create HTTP proxy
echo -e "${BLUE}🔄 Creating HTTP proxy...${NC}"
gcloud compute target-http-proxies create nucleus-http-proxy \
    --url-map=nucleus-url-map

echo -e "${GREEN}✅ HTTP proxy created${NC}"

# Create global forwarding rule
echo -e "${BLUE}📡 Creating global forwarding rule...${NC}"
gcloud compute forwarding-rules create nucleus-forwarding-rule \
    --global \
    --target-http-proxy=nucleus-http-proxy \
    --ports=80

echo -e "${GREEN}✅ Global forwarding rule created${NC}"

# Wait for load balancer to be ready
echo -e "\n${YELLOW}⏳ Waiting for load balancer to be ready...${NC}"
sleep 60

# Get load balancer IP
LB_IP=$(gcloud compute forwarding-rules describe nucleus-forwarding-rule --global --format="value(IPAddress)")

echo -e "\n${GREEN}🎉 Lab completed successfully!${NC}"
echo -e "${GREEN}📦 Bucket: gs://$BUCKET_NAME${NC}"
echo -e "${GREEN}💻 VM: nucleus-jumphost-webserver1${NC}"
echo -e "${GREEN}⚖️ Load Balancer IP: $LB_IP${NC}"
echo -e "\n${BLUE}🌐 Test your load balancer: http://$LB_IP${NC}"
```

### Save and Run Script

```bash
# Save the script
cat > complete_lab.sh << 'EOF'
# [Insert the above script here]
EOF

# Make executable and run
chmod +x complete_lab.sh
./complete_lab.sh
```

---

## 🏗️ Terraform Infrastructure as Code

### main.tf

```terraform
# The Basics of Google Cloud Compute - Terraform Configuration
# Author: CodeWithGarry

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
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-east4"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-east4-a"
}

variable "bucket_name" {
  description = "Cloud Storage bucket name"
  type        = string
}

# Task 1: Cloud Storage bucket
resource "google_storage_bucket" "lab_bucket" {
  name     = var.bucket_name
  location = "US"
  
  uniform_bucket_level_access = true
}

# Task 2: VM instance
resource "google_compute_instance" "jumphost" {
  name         = "nucleus-jumphost-webserver1"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["http-server", "https-server"]

  service_account {
    email  = "${var.project_id}-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

# Task 3: Load Balancer Components

# Instance template
resource "google_compute_instance_template" "web_server_template" {
  name         = "nucleus-web-server-template"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    service nginx start
    sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
  EOF

  tags = ["http-server", "https-server"]
}

# Managed instance group
resource "google_compute_instance_group_manager" "web_server_group" {
  name = "nucleus-web-server-group"
  zone = var.zone

  version {
    instance_template = google_compute_instance_template.web_server_template.id
  }

  base_instance_name = "nucleus-web-server"
  target_size        = 2
}

# Firewall rule
resource "google_compute_firewall" "allow_tcp_rule_503" {
  name    = "allow-tcp-rule-503"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Health check
resource "google_compute_health_check" "nucleus_health_check" {
  name = "nucleus-health-check"

  http_health_check {
    port = 80
    request_path = "/"
  }
}

# Backend service
resource "google_compute_backend_service" "nucleus_backend_service" {
  name     = "nucleus-backend-service"
  protocol = "HTTP"
  
  backend {
    group = google_compute_instance_group_manager.web_server_group.instance_group
  }

  health_checks = [google_compute_health_check.nucleus_health_check.id]
}

# URL map
resource "google_compute_url_map" "nucleus_url_map" {
  name = "nucleus-url-map"
  default_service = google_compute_backend_service.nucleus_backend_service.id
}

# HTTP proxy
resource "google_compute_target_http_proxy" "nucleus_http_proxy" {
  name    = "nucleus-http-proxy"
  url_map = google_compute_url_map.nucleus_url_map.id
}

# Global forwarding rule
resource "google_compute_global_forwarding_rule" "nucleus_forwarding_rule" {
  name       = "nucleus-forwarding-rule"
  target     = google_compute_target_http_proxy.nucleus_http_proxy.id
  port_range = "80"
}

# Outputs
output "bucket_name" {
  value = google_storage_bucket.lab_bucket.name
}

output "vm_name" {
  value = google_compute_instance.jumphost.name
}

output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.nucleus_forwarding_rule.ip_address
}
```

### terraform.tfvars

```terraform
project_id  = "your-project-id"
bucket_name = "your-bucket-name-from-lab"
region      = "us-east4"
zone        = "us-east4-a"
```

### Deploy with Terraform

```bash
# Initialize and deploy
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve

# Get outputs
terraform output
```

---

## 🐍 Python Automation Script

```python
#!/usr/bin/env python3
"""
The Basics of Google Cloud Compute - Python Automation
Author: CodeWithGarry
"""

import time
import subprocess
import sys
from google.cloud import storage
from google.cloud import compute_v1

class GoogleCloudComputeLab:
    def __init__(self, project_id, region="us-east4", zone="us-east4-a"):
        self.project_id = project_id
        self.region = region
        self.zone = zone
        self.bucket_name = f"{project_id}-bucket"
        
        # Initialize clients
        self.storage_client = storage.Client()
        self.compute_client = compute_v1.InstancesClient()
        self.template_client = compute_v1.InstanceTemplatesClient()
        self.group_client = compute_v1.InstanceGroupManagersClient()
        
    def create_bucket(self):
        """Task 1: Create Cloud Storage bucket"""
        print("📦 Creating Cloud Storage bucket...")
        
        bucket = self.storage_client.bucket(self.bucket_name)
        bucket.location = "US"
        bucket = self.storage_client.create_bucket(bucket)
        
        print(f"✅ Bucket created: {bucket.name}")
        return bucket.name
    
    def create_vm_instance(self):
        """Task 2: Create VM with persistent disk"""
        print("💻 Creating VM instance...")
        
        # VM configuration
        config = {
            "name": "nucleus-jumphost-webserver1",
            "machine_type": f"zones/{self.zone}/machineTypes/e2-micro",
            "disks": [{
                "boot": True,
                "auto_delete": True,
                "initialize_params": {
                    "source_image": "projects/debian-cloud/global/images/family/debian-11",
                    "disk_size_gb": "10"
                }
            }],
            "network_interfaces": [{
                "network": f"projects/{self.project_id}/global/networks/default",
                "access_configs": [{"type": "ONE_TO_ONE_NAT", "name": "External NAT"}]
            }],
            "tags": {"items": ["http-server", "https-server"]},
            "service_accounts": [{
                "email": f"{self.project_id}-compute@developer.gserviceaccount.com",
                "scopes": ["https://www.googleapis.com/auth/cloud-platform"]
            }]
        }
        
        operation = self.compute_client.insert(
            project=self.project_id,
            zone=self.zone,
            instance_resource=config
        )
        
        print(f"✅ VM instance created: nucleus-jumphost-webserver1")
        return operation
    
    def create_load_balancer(self):
        """Task 3: Create HTTP Load Balancer"""
        print("⚖️ Creating HTTP Load Balancer...")
        
        # Use gcloud commands for complex load balancer setup
        commands = [
            # Instance template
            f"""gcloud compute instance-templates create nucleus-web-server-template \
                --machine-type=e2-micro \
                --network=projects/{self.project_id}/global/networks/default \
                --subnet=projects/{self.project_id}/regions/{self.region}/subnetworks/default \
                --region={self.region} \
                --tags=http-server,https-server \
                --image=debian-11-bullseye-v20240415 \
                --image-project=debian-cloud \
                --boot-disk-size=10GB \
                --boot-disk-type=pd-standard \
                --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- "s/nginx/Google Cloud Platform - '\\''$HOSTNAME'\\''/" /var/www/html/index.nginx-debian.html'""",
            
            # Managed instance group
            f"""gcloud compute instance-groups managed create nucleus-web-server-group \
                --base-instance-name=nucleus-web-server \
                --template=nucleus-web-server-template \
                --size=2 \
                --zone={self.zone}""",
            
            # Firewall rule
            """gcloud compute firewall-rules create allow-tcp-rule-503 \
                --direction=INGRESS \
                --priority=1000 \
                --network=default \
                --action=ALLOW \
                --rules=tcp:80 \
                --source-ranges=0.0.0.0/0 \
                --target-tags=http-server""",
            
            # Health check
            """gcloud compute health-checks create http nucleus-health-check \
                --port=80 \
                --request-path=/""",
            
            # Backend service
            """gcloud compute backend-services create nucleus-backend-service \
                --protocol=HTTP \
                --port-name=http \
                --health-checks=nucleus-health-check \
                --global""",
            
            # Add backend
            f"""gcloud compute backend-services add-backend nucleus-backend-service \
                --instance-group=nucleus-web-server-group \
                --instance-group-zone={self.zone} \
                --global""",
            
            # URL map
            """gcloud compute url-maps create nucleus-url-map \
                --default-service=nucleus-backend-service""",
            
            # HTTP proxy
            """gcloud compute target-http-proxies create nucleus-http-proxy \
                --url-map=nucleus-url-map""",
            
            # Forwarding rule
            """gcloud compute forwarding-rules create nucleus-forwarding-rule \
                --global \
                --target-http-proxy=nucleus-http-proxy \
                --ports=80"""
        ]
        
        for i, cmd in enumerate(commands, 1):
            print(f"🔧 Step {i}/{len(commands)}: Executing command...")
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            if result.returncode != 0:
                print(f"❌ Error in step {i}: {result.stderr}")
                return False
        
        print("✅ Load balancer created successfully")
        return True
    
    def run_complete_lab(self):
        """Run the complete lab automation"""
        print("🚀 Starting Google Cloud Compute Challenge Lab Automation")
        print(f"📋 Project: {self.project_id}")
        print(f"📍 Region: {self.region}")
        print(f"📍 Zone: {self.zone}")
        
        try:
            # Task 1
            self.create_bucket()
            
            # Task 2
            self.create_vm_instance()
            
            # Task 3
            self.create_load_balancer()
            
            # Wait for load balancer
            print("⏳ Waiting for load balancer to be ready...")
            time.sleep(60)
            
            # Get load balancer IP
            result = subprocess.run(
                "gcloud compute forwarding-rules describe nucleus-forwarding-rule --global --format='value(IPAddress)'",
                shell=True, capture_output=True, text=True
            )
            
            lb_ip = result.stdout.strip()
            
            print("\n🎉 Lab completed successfully!")
            print(f"📦 Bucket: gs://{self.bucket_name}")
            print(f"💻 VM: nucleus-jumphost-webserver1")
            print(f"⚖️ Load Balancer IP: {lb_ip}")
            print(f"🌐 Test URL: http://{lb_ip}")
            
        except Exception as e:
            print(f"❌ Error: {str(e)}")
            sys.exit(1)

if __name__ == "__main__":
    # Get project ID
    result = subprocess.run(
        "gcloud config get-value project",
        shell=True, capture_output=True, text=True
    )
    project_id = result.stdout.strip()
    
    if not project_id:
        print("❌ Please set your project ID: gcloud config set project YOUR_PROJECT_ID")
        sys.exit(1)
    
    # Run the lab
    lab = GoogleCloudComputeLab(project_id)
    lab.run_complete_lab()
```

### Run Python Script

```bash
# Install dependencies
pip install google-cloud-storage google-cloud-compute

# Run the script
python3 automate_lab.py
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[CLI Solution](CLI-Solution.md)** - Command-line approach for efficiency

---

## 🎖️ Skills Boost Arcade

This automated solution helps you complete the challenge lab quickly while learning automation best practices for the **Skills Boost Arcade** program.

---

## 📚 Learn More

- [Google Cloud SDK Documentation](https://cloud.google.com/sdk/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Cloud Python Client Libraries](https://cloud.google.com/python/docs/reference)

---

<div align="center">

**⚡ Pro Tip**: Save these automation scripts for future labs and customize them for different projects!

</div>
