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

# VM name input with default
read -p "💻 Enter the VM INSTANCE NAME [default: my-instance]: " VM_NAME
VM_NAME=${VM_NAME:-my-instance}

# Region input with default
read -p "🌍 Enter the REGION [default: us-east4]: " REGION
REGION=${REGION:-us-east4}

# Zone input with default
read -p "🎯 Enter the ZONE [default: us-east4-a]: " ZONE
ZONE=${ZONE:-us-east4-a}

# Machine type input with default
echo ""
echo "🖥️  Select machine type:"
echo "1) e2-medium (1 vCPU, 4 GB memory) - Recommended"
echo "2) e2-small (1 vCPU, 2 GB memory)"
echo "3) e2-standard-2 (2 vCPU, 8 GB memory)"
echo "4) Custom"
read -p "Enter your choice (1-4) [default: 1]: " MACHINE_TYPE_CHOICE
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
read -p "💾 Enter BOOT DISK SIZE in GB [default: 10]: " BOOT_DISK_SIZE
BOOT_DISK_SIZE=${BOOT_DISK_SIZE:-10}

# Additional disk name
read -p "📀 Enter ADDITIONAL DISK NAME [default: mydisk]: " DISK_NAME
DISK_NAME=${DISK_NAME:-mydisk}

# Additional disk size
read -p "📀 Enter ADDITIONAL DISK SIZE in GB [default: 200]: " DISK_SIZE
DISK_SIZE=${DISK_SIZE:-200}

# HTTP traffic
read -p "🌐 Allow HTTP traffic? (y/N) [default: y]: " ALLOW_HTTP
ALLOW_HTTP=${ALLOW_HTTP:-y}

echo ""
echo "=================================================================="
echo "📝 CONFIGURATION SUMMARY"
echo "=================================================================="
echo "VM Instance Name: $VM_NAME"
echo "Region: $REGION"
echo "Zone: $ZONE"
echo "Machine Type: $MACHINE_TYPE"
echo "Boot Disk Size: $BOOT_DISK_SIZE GB"
echo "Additional Disk Name: $DISK_NAME"
echo "Additional Disk Size: $DISK_SIZE GB"
echo "Allow HTTP Traffic: $ALLOW_HTTP"
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

# Set up HTTP traffic flag
HTTP_FLAG=""
if [[ "$ALLOW_HTTP" =~ ^[Yy]$ ]]; then
    HTTP_FLAG="--tags=http-server"
fi

# Step 1: Create the additional persistent disk
print_step "Step 1: Creating additional persistent disk '$DISK_NAME'..."
echo ""

if gcloud compute disks create "$DISK_NAME" \
    --zone="$ZONE" \
    --size="$DISK_SIZE" \
    --type=pd-balanced; then
    print_status "✅ Disk '$DISK_NAME' created successfully!"
else
    print_error "❌ Failed to create disk '$DISK_NAME'"
    exit 1
fi

echo ""

# Step 2: Create the VM instance
print_step "Step 2: Creating VM instance '$VM_NAME'..."
echo ""

if gcloud compute instances create "$VM_NAME" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --boot-disk-size="$BOOT_DISK_SIZE" \
    --boot-disk-type=pd-balanced \
    --disk="name=$DISK_NAME,device-name=$DISK_NAME,mode=rw,boot=no" \
    $HTTP_FLAG; then
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

echo ""
print_status "🏁 Task 2 script execution completed!"

# Additional information
echo ""
print_status "📋 Next Steps:"
echo "1. SSH into the VM: gcloud compute ssh $VM_NAME --zone=$ZONE"
echo "2. Format and mount the additional disk if needed"
echo "3. Proceed to Task 3 to install NGINX"
echo ""
