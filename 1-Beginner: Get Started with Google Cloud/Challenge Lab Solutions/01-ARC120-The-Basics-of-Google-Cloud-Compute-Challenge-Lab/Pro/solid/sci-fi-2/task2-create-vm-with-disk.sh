#!/bin/bash

# =============================================================================
# The Basics of Google Cloud Compute: Challenge Lab - Task 2
# Create VM with Persistent Disk
# Author: CodeWithGarry
# Lab ID: ARC120
# =============================================================================

echo "=================================================================="
echo "  🚀 TASK 2: CREATE VM WITH PERSISTENT DISK"
echo "=================================================================="
echo ""

# Color codes for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Get user inputs
echo "📋 Please provide the following information from your lab instructions:"
echo ""
echo "💡 Press ENTER to use default values (recommended for quick completion)"
echo ""

# VM name input with default
read -p "💻 Enter the VM INSTANCE NAME [Press ENTER for: my-instance]: " VM_NAME
VM_NAME=${VM_NAME:-my-instance}

# Region input with default
read -p "🌍 Enter the REGION [Press ENTER for: us-east4]: " REGION
REGION=${REGION:-us-east4}

# Zone input with default
read -p "🎯 Enter the ZONE [Press ENTER for: us-east4-a]: " ZONE
ZONE=${ZONE:-us-east4-a}

# Machine type input with default
echo ""
echo "🖥️  Select machine type:"
echo "1) e2-medium (1 vCPU, 4 GB memory) - Default for most labs"
echo "2) e2-small (1 vCPU, 2 GB memory)"
echo "3) e2-standard-2 (2 vCPU, 8 GB memory)"
echo "4) Custom"
read -p "Enter your choice (1-4) [Press ENTER for e2-medium]: " MACHINE_TYPE_CHOICE
MACHINE_TYPE_CHOICE=${MACHINE_TYPE_CHOICE:-1}

case $MACHINE_TYPE_CHOICE in
    1)
        MACHINE_TYPE="e2-medium"
        ;;
    2)
        MACHINE_TYPE="e2-small"
        ;;
    3)
        MACHINE_TYPE="e2-standard-2"
        ;;
    4)
        read -p "Enter custom machine type: " MACHINE_TYPE
        ;;
    *)
        MACHINE_TYPE="e2-medium"
        ;;
esac

# Boot disk size
read -p "💾 Enter BOOT DISK SIZE in GB [Press ENTER for: 10]: " BOOT_DISK_SIZE
BOOT_DISK_SIZE=${BOOT_DISK_SIZE:-10}

# Boot disk type
echo ""
echo "🔷 Select boot disk type:"
echo "1) Balanced persistent disk (Default - Good performance/cost ratio)"
echo "2) Standard persistent disk (Lower cost)"
echo "3) SSD persistent disk (Higher performance)"
read -p "Enter your choice (1-3) [Press ENTER for Balanced]: " BOOT_DISK_TYPE_CHOICE
BOOT_DISK_TYPE_CHOICE=${BOOT_DISK_TYPE_CHOICE:-1}

case $BOOT_DISK_TYPE_CHOICE in
    1)
        BOOT_DISK_TYPE="pd-balanced"
        ;;
    2)
        BOOT_DISK_TYPE="pd-standard"
        ;;
    3)
        BOOT_DISK_TYPE="pd-ssd"
        ;;
    *)
        BOOT_DISK_TYPE="pd-balanced"
        ;;
esac

# Operating system selection
echo ""
echo "🖥️  Select operating system:"
echo "1) Debian 11 (Default - Most compatible)"
echo "2) Ubuntu 20.04 LTS"
echo "3) CentOS 7"
echo "4) Custom"
read -p "Enter your choice (1-4) [Press ENTER for Debian 11]: " OS_CHOICE
OS_CHOICE=${OS_CHOICE:-1}

case $OS_CHOICE in
    1)
        IMAGE_FAMILY="debian-11"
        IMAGE_PROJECT="debian-cloud"
        OS_DESC="Debian 11"
        ;;
    2)
        IMAGE_FAMILY="ubuntu-2004-lts"
        IMAGE_PROJECT="ubuntu-os-cloud"
        OS_DESC="Ubuntu 20.04 LTS"
        ;;
    3)
        IMAGE_FAMILY="centos-7"
        IMAGE_PROJECT="centos-cloud"
        OS_DESC="CentOS 7"
        ;;
    4)
        read -p "Enter image family: " IMAGE_FAMILY
        read -p "Enter image project: " IMAGE_PROJECT
        OS_DESC="Custom ($IMAGE_FAMILY)"
        ;;
    *)
        IMAGE_FAMILY="debian-11"
        IMAGE_PROJECT="debian-cloud"
        OS_DESC="Debian 11"
        ;;
esac

# Additional disk name
read -p "📀 Enter ADDITIONAL DISK NAME [Press ENTER for: mydisk]: " DISK_NAME
DISK_NAME=${DISK_NAME:-mydisk}

# Additional disk size
read -p "📀 Enter ADDITIONAL DISK SIZE in GB [Press ENTER for: 200]: " DISK_SIZE
DISK_SIZE=${DISK_SIZE:-200}

# Additional disk type
echo ""
echo "🔷 Select additional disk type:"
echo "1) Balanced persistent disk (Default - Good performance/cost ratio)"
echo "2) Standard persistent disk (Lower cost)"
echo "3) SSD persistent disk (Higher performance)"
read -p "Enter your choice (1-3) [Press ENTER for Balanced]: " DISK_TYPE_CHOICE
DISK_TYPE_CHOICE=${DISK_TYPE_CHOICE:-1}

case $DISK_TYPE_CHOICE in
    1)
        DISK_TYPE="pd-balanced"
        ;;
    2)
        DISK_TYPE="pd-standard"
        ;;
    3)
        DISK_TYPE="pd-ssd"
        ;;
    *)
        DISK_TYPE="pd-balanced"
        ;;
esac

# Network configuration
echo ""
echo "🌐 Network configuration:"
read -p "Allow HTTP traffic? (Y/n) [Press ENTER for Yes]: " ALLOW_HTTP
ALLOW_HTTP=${ALLOW_HTTP:-Y}

read -p "Allow HTTPS traffic? (y/N) [Press ENTER for No]: " ALLOW_HTTPS
ALLOW_HTTPS=${ALLOW_HTTPS:-N}

# External IP configuration
echo ""
echo "🌍 External IP configuration:"
echo "1) Ephemeral (Default - Temporary IP)"
echo "2) None (No external IP)"
echo "3) Static (Reserved IP - requires existing reservation)"
read -p "Enter your choice (1-3) [Press ENTER for Ephemeral]: " IP_CHOICE
IP_CHOICE=${IP_CHOICE:-1}

case $IP_CHOICE in
    1)
        EXTERNAL_IP_FLAG=""
        IP_DESC="Ephemeral external IP"
        ;;
    2)
        EXTERNAL_IP_FLAG="--no-address"
        IP_DESC="No external IP"
        ;;
    3)
        read -p "Enter static IP name: " STATIC_IP_NAME
        EXTERNAL_IP_FLAG="--address=$STATIC_IP_NAME"
        IP_DESC="Static IP: $STATIC_IP_NAME"
        ;;
    *)
        EXTERNAL_IP_FLAG=""
        IP_DESC="Ephemeral external IP"
        ;;
esac

echo ""
echo "=================================================================="
echo "📝 CONFIGURATION SUMMARY"
echo "=================================================================="
echo "VM Instance Name: $VM_NAME"
echo "Region: $REGION"
echo "Zone: $ZONE"
echo "Machine Type: $MACHINE_TYPE"
echo "Operating System: $OS_DESC"
echo "Boot Disk Size: $BOOT_DISK_SIZE GB ($BOOT_DISK_TYPE)"
echo "Additional Disk Name: $DISK_NAME"
echo "Additional Disk Size: $DISK_SIZE GB ($DISK_TYPE)"
echo "External IP: $IP_DESC"
echo "HTTP Traffic: $(if [[ "$ALLOW_HTTP" =~ ^[Yy]$ || -z "$ALLOW_HTTP" ]]; then echo "Allowed"; else echo "Blocked"; fi)"
echo "HTTPS Traffic: $(if [[ "$ALLOW_HTTPS" =~ ^[Yy]$ ]]; then echo "Allowed"; else echo "Blocked"; fi)"
echo "=================================================================="
echo ""

# Confirmation
read -p "❓ Do you want to proceed with this configuration? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_warning "Operation cancelled by user."
    exit 0
fi

echo ""
print_status "Starting VM and disk creation process..."

# Check if gcloud is installed and authenticated
print_status "Checking gcloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    print_error "You are not authenticated with gcloud."
    print_warning "Please run: gcloud auth login"
    exit 1
fi

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "$PROJECT_ID" ]]; then
    print_error "No project is set."
    print_warning "Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

print_status "Using project: $PROJECT_ID"

# Set up traffic flags
NETWORK_TAGS=""
if [[ "$ALLOW_HTTP" =~ ^[Yy]$ || -z "$ALLOW_HTTP" ]]; then
    NETWORK_TAGS="http-server"
fi
if [[ "$ALLOW_HTTPS" =~ ^[Yy]$ ]]; then
    if [[ -n "$NETWORK_TAGS" ]]; then
        NETWORK_TAGS="$NETWORK_TAGS,https-server"
    else
        NETWORK_TAGS="https-server"
    fi
fi

if [[ -n "$NETWORK_TAGS" ]]; then
    TAGS_FLAG="--tags=$NETWORK_TAGS"
else
    TAGS_FLAG=""
fi

# Step 1: Create the additional persistent disk
print_step "Step 1: Creating additional persistent disk '$DISK_NAME'..."
echo ""

if gcloud compute disks create "$DISK_NAME" \
    --zone="$ZONE" \
    --size="$DISK_SIZE" \
    --type="$DISK_TYPE"; then
    print_status "✅ Disk '$DISK_NAME' created successfully!"
else
    print_error "❌ Failed to create disk '$DISK_NAME'"
    exit 1
fi

echo ""

# Step 2: Create the VM instance
print_step "Step 2: Creating VM instance '$VM_NAME'..."
echo ""

# Build the gcloud command
CREATE_CMD="gcloud compute instances create \"$VM_NAME\""
CREATE_CMD="$CREATE_CMD --zone=\"$ZONE\""
CREATE_CMD="$CREATE_CMD --machine-type=\"$MACHINE_TYPE\""
CREATE_CMD="$CREATE_CMD --image-family=\"$IMAGE_FAMILY\""
CREATE_CMD="$CREATE_CMD --image-project=\"$IMAGE_PROJECT\""
CREATE_CMD="$CREATE_CMD --boot-disk-size=\"$BOOT_DISK_SIZE\""
CREATE_CMD="$CREATE_CMD --boot-disk-type=\"$BOOT_DISK_TYPE\""
CREATE_CMD="$CREATE_CMD --disk=\"name=$DISK_NAME,device-name=$DISK_NAME,mode=rw,boot=no\""

if [[ -n "$TAGS_FLAG" ]]; then
    CREATE_CMD="$CREATE_CMD $TAGS_FLAG"
fi

if [[ -n "$EXTERNAL_IP_FLAG" ]]; then
    CREATE_CMD="$CREATE_CMD $EXTERNAL_IP_FLAG"
fi

# Execute VM creation
if eval $CREATE_CMD; then
    print_status "✅ VM instance '$VM_NAME' created successfully!"
else
    print_error "❌ Failed to create VM instance '$VM_NAME'"
    print_warning "Cleaning up created disk..."
    gcloud compute disks delete "$DISK_NAME" --zone="$ZONE" --quiet
    exit 1
fi

echo ""

# Step 3: Verify the setup
print_step "Step 3: Verifying the setup..."
echo ""

print_status "Checking VM instance status..."
if gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)" | grep -q "RUNNING"; then
    print_status "✅ VM instance is running!"
else
    print_warning "VM instance may still be starting up..."
fi

print_status "Checking attached disks..."
ATTACHED_DISKS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(disks[].deviceName)")
if echo "$ATTACHED_DISKS" | grep -q "$DISK_NAME"; then
    print_status "✅ Additional disk '$DISK_NAME' is attached!"
else
    print_warning "Additional disk attachment verification failed."
fi

# Get external IP if HTTP is enabled
if [[ "$ALLOW_HTTP" =~ ^[Yy]$ ]]; then
    EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
    if [[ -n "$EXTERNAL_IP" ]]; then
        print_status "External IP: $EXTERNAL_IP"
    fi
fi

echo ""
echo "=================================================================="
echo "🎉 TASK 2 COMPLETED SUCCESSFULLY!"
echo "=================================================================="
echo "VM Instance: $VM_NAME"
echo "Zone: $ZONE"
echo "Machine Type: $MACHINE_TYPE"
echo "Additional Disk: $DISK_NAME ($DISK_SIZE GB)"
echo "Status: Running"
if [[ -n "$EXTERNAL_IP" ]]; then
    echo "External IP: $EXTERNAL_IP"
fi
echo ""
echo "📡 To connect to your VM:"
echo "gcloud compute ssh $VM_NAME --zone=$ZONE"
echo ""
echo "🌐 Console URL:"
echo "https://console.cloud.google.com/compute/instances"
echo "=================================================================="

# Create completion marker
echo "TASK2_COMPLETED=$(date)" > /tmp/arc120_task2_completed

echo ""
print_status "🏁 Task 2 script execution completed!"

# Additional information
echo ""
print_status "📋 Next Steps:"
echo "1. SSH into the VM: gcloud compute ssh $VM_NAME --zone=$ZONE"
echo "2. Format and mount the additional disk if needed"
echo "3. Proceed to Task 3 to install NGINX"
echo ""
