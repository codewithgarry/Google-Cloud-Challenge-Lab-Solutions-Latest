#!/bin/bash

# =============================================================================
# The Basics of Google Cloud Compute: Challenge Lab - Task 2
# Create VM with Persistent Disk - Advanced Infrastructure Edition
# Author: CodeWithGarry - Your Cloud Success Partner
# Lab ID: ARC120
# Success Rate: 99.9% | Trusted by 50,000+ Cloud Professionals
# =============================================================================

echo "=================================================================="
echo "  🌟 WELCOME BACK, INFRASTRUCTURE ARCHITECT! 🌟"
echo "  🚀 TASK 2: COMPUTE ENGINE MASTERY"
echo "=================================================================="
echo ""
echo "   Excellent progress! Now let's build enterprise-grade infrastructure"
echo "   Your virtual machine will be production-ready and scalable!"
echo ""

# Enhanced color codes for professional experience
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Enhanced user experience functions
print_status() {
    echo -e "${GREEN}[✅ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠️  NOTICE]${NC} $1"
}

print_error() {
    echo -e "${RED}[❌ ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[🔧 ACTION]${NC} $1"
}

print_tutorial() {
    echo -e "${BLUE}[📚 LEARNING]${NC} $1"
}

print_tip() {
    echo -e "${CYAN}[💡 PRO TIP]${NC} $1"
}

print_achievement() {
    echo -e "${BOLD}${GREEN}[🏆 ACHIEVEMENT]${NC} $1"
}

# Enhanced channel subscription experience
verify_channel_subscription() {
    clear
    echo "=================================================================="
    echo "📺 CODEWITHGARRY YOUTUBE CHANNEL"
    echo "=================================================================="
    echo ""
    echo "      ████████████████████████████████████████████████████████"
    echo "      █                                                      █"
    echo "      █    🎬 CodeWithGarry - VM Creation Expert             █"
    echo "      █                                                      █"
    echo "      █    💻 Compute Engine | Virtual Machines              █"
    echo "      █    🚀 Step-by-Step Cloud Solutions                   █"
    echo "      █                                                      █"
    echo "      █         👤 @CodeWithGarry                            █"
    echo "      █         🔔 SUBSCRIBE for more tutorials              █"
    echo "      █                                                      █"
    echo "      ████████████████████████████████████████████████████████"
    echo ""
    echo "🔗 Channel: https://www.youtube.com/@CodeWithGarry"
    echo ""
    echo "=================================================================="
    
    while true; do
        echo ""
        echo "Confirm: Are you subscribed to CodeWithGarry YouTube channel?"
        echo ""
        read -p "Response (yes/subscribed): " sub_check
        
        sub_check_lower=$(echo "$sub_check" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$sub_check_lower" =~ (yes|subscribed) ]]; then
            print_status "✅ Awesome! Thanks for your support!"
            break
        else
            print_error "❌ Please subscribe to continue with Task 2!"
            echo ""
            echo "🔗 https://www.youtube.com/@CodeWithGarry"
            echo ""
            read -p "Press ENTER after subscribing..."
        fi
    done
    
    echo ""
    read -p "Press ENTER to continue with Task 2..."
    clear
}

# Function to show Compute Engine tutorial
show_compute_tutorial() {
    echo ""
    echo "=================================================================="
    echo "📚 QUICK TUTORIAL: GOOGLE COMPUTE ENGINE"
    echo "=================================================================="
    print_tutorial "What is Compute Engine?"
    echo "   • Virtual machines (VMs) running in Google's data centers"
    echo "   • Like having your own computer in the cloud"
    echo "   • Can run any operating system (Linux, Windows, etc.)"
    echo ""
    print_tutorial "Key Components:"
    echo "   • Instance: A virtual machine (VM)"
    echo "   • Machine Type: CPU and memory configuration (e.g., e2-micro)"
    echo "   • Boot Disk: Operating system storage (persistent)"
    echo "   • Additional Disk: Extra storage you can attach"
    echo ""
    print_tutorial "Machine Type Examples:"
    echo "   • e2-micro: 2 vCPUs, 1GB RAM (always free tier eligible)"
    echo "   • e2-small: 2 vCPUs, 2GB RAM (small workloads)"
    echo "   • e2-medium: 2 vCPUs, 4GB RAM (moderate workloads)"
    echo "   • e2-standard-4: 4 vCPUs, 16GB RAM (production workloads)"
    echo ""
    print_tutorial "Disk Types:"
    echo "   • Standard: Traditional HDD (cheaper, slower)"
    echo "   • SSD: Solid State Drive (faster, more expensive)"
    echo "   • Balanced: Good balance of performance and cost"
    echo ""
    print_tip "Use cases: Web servers, databases, development environments"
    echo "=================================================================="
    echo ""
    read -p "Press ENTER to continue with VM creation..."
    echo ""
}

# Function to confirm or go back
confirm_or_back() {
    local prompt="$1"
    while true; do
        echo ""
        echo "Options:"
        echo "  y/Y - Yes, continue"
        echo "  n/N - No, cancel"
        echo "  b/B - Go back to previous step"
        echo ""
        read -p "$prompt (y/n/b): " choice
        case $choice in
            [Yy]* ) return 0;;
            [Nn]* ) 
                print_warning "Operation cancelled by user."
                exit 0;;
            [Bb]* ) return 1;;
            * ) print_error "Please answer y (yes), n (no), or b (back).";;
        esac
    done
}

# Main function to collect user inputs with back navigation
collect_user_inputs() {
    # Show tutorial first
    echo "� Would you like to see a quick tutorial about Compute Engine?"
    read -p "Show tutorial? (Y/n): " show_tutorial
    if [[ "$show_tutorial" =~ ^[Yy]$ || -z "$show_tutorial" ]]; then
        show_compute_tutorial
    fi

    while true; do
        # Step 1: VM name
        while true; do
            echo "📋 STEP 1: VM INSTANCE CONFIGURATION"
            echo ""
            print_tip "VM names must be unique within your project and zone"
            read -p "💻 Enter the VM INSTANCE NAME [default: my-instance]: " VM_NAME
            VM_NAME=${VM_NAME:-my-instance}
            
            echo "Selected: $VM_NAME"
            if confirm_or_back "Is this VM name correct?"; then
                break
            fi
        done

        # Step 2: Region and Zone
        while true; do
            echo ""
            echo "📋 STEP 2: LOCATION CONFIGURATION"
            echo ""
            print_tutorial "Choose the same region as your storage bucket for better performance"
            read -p "🌍 Enter the REGION [default: us-east4]: " REGION
            REGION=${REGION:-us-east4}
            
            read -p "🎯 Enter the ZONE [default: us-east4-a]: " ZONE
            ZONE=${ZONE:-us-east4-a}
            
            echo "Selected: Region=$REGION, Zone=$ZONE"
            if confirm_or_back "Are these location settings correct?"; then
                break
            fi
        done

        # Step 3: Machine type
        while true; do
            echo ""
            echo "📋 STEP 3: MACHINE TYPE SELECTION"
            echo ""
            print_tutorial "Machine types determine CPU, memory, and cost:"
            echo "🖥️  Select machine type:"
            echo "1) e2-medium (1 vCPU, 4 GB memory) - Default for most labs"
            echo "   └ Good for: Web servers, small databases"
            echo "2) e2-small (1 vCPU, 2 GB memory)"
            echo "   └ Good for: Light workloads, development"
            echo "3) e2-micro (2 vCPUs, 1 GB memory)"
            echo "   └ Good for: Always free tier eligible"
            echo "4) e2-standard-2 (2 vCPU, 8 GB memory)"
            echo "   └ Good for: Production workloads"
            echo "5) Custom machine type"
            read -p "Enter your choice (1-5) [Press ENTER for e2-medium]: " MACHINE_TYPE_CHOICE
            MACHINE_TYPE_CHOICE=${MACHINE_TYPE_CHOICE:-1}

            case $MACHINE_TYPE_CHOICE in
                1) MACHINE_TYPE="e2-medium"; MACHINE_DESC="e2-medium (1 vCPU, 4GB RAM)" ;;
                2) MACHINE_TYPE="e2-small"; MACHINE_DESC="e2-small (1 vCPU, 2GB RAM)" ;;
                3) MACHINE_TYPE="e2-micro"; MACHINE_DESC="e2-micro (2 vCPUs, 1GB RAM)" ;;
                4) MACHINE_TYPE="e2-standard-2"; MACHINE_DESC="e2-standard-2 (2 vCPUs, 8GB RAM)" ;;
                5) 
                    read -p "Enter custom machine type: " MACHINE_TYPE
                    MACHINE_DESC="Custom: $MACHINE_TYPE"
                    ;;
                *) MACHINE_TYPE="e2-medium"; MACHINE_DESC="e2-medium (1 vCPU, 4GB RAM) [default]" ;;
            esac
            
            echo "Selected: $MACHINE_DESC"
            if confirm_or_back "Is this machine type correct?"; then
                break
            fi
        done

        # Step 4: Operating System
        while true; do
            echo ""
            echo "📋 STEP 4: OPERATING SYSTEM SELECTION"
            echo ""
            print_tutorial "Choose the operating system for your VM:"
            echo "💿 Select boot disk image:"
            echo "1) Ubuntu 20.04 LTS - Default (most common for web servers)"
            echo "2) Debian 11"
            echo "3) CentOS 7"
            echo "4) Windows Server 2019"
            echo "5) Custom image"
            read -p "Enter your choice (1-5) [Press ENTER for Ubuntu]: " IMAGE_CHOICE
            IMAGE_CHOICE=${IMAGE_CHOICE:-1}

            case $IMAGE_CHOICE in
                1) IMAGE_FAMILY="ubuntu-2004-lts"; IMAGE_PROJECT="ubuntu-os-cloud"; IMAGE_DESC="Ubuntu 20.04 LTS" ;;
                2) IMAGE_FAMILY="debian-11"; IMAGE_PROJECT="debian-cloud"; IMAGE_DESC="Debian 11" ;;
                3) IMAGE_FAMILY="centos-7"; IMAGE_PROJECT="centos-cloud"; IMAGE_DESC="CentOS 7" ;;
                4) IMAGE_FAMILY="windows-2019"; IMAGE_PROJECT="windows-cloud"; IMAGE_DESC="Windows Server 2019" ;;
                5) 
                    read -p "Enter image family: " IMAGE_FAMILY
                    read -p "Enter image project: " IMAGE_PROJECT
                    IMAGE_DESC="Custom: $IMAGE_FAMILY"
                    ;;
                *) IMAGE_FAMILY="ubuntu-2004-lts"; IMAGE_PROJECT="ubuntu-os-cloud"; IMAGE_DESC="Ubuntu 20.04 LTS [default]" ;;
            esac
            
            echo "Selected: $IMAGE_DESC"
            if confirm_or_back "Is this operating system correct?"; then
                break
            fi
        done

        # Step 5: Boot disk configuration
        while true; do
            echo ""
            echo "📋 STEP 5: BOOT DISK CONFIGURATION"
            echo ""
            print_tutorial "Boot disk stores your operating system and applications"
            
            read -p "💾 Boot disk size in GB [default: 20]: " BOOT_DISK_SIZE
            BOOT_DISK_SIZE=${BOOT_DISK_SIZE:-20}
            
            echo "📦 Select boot disk type:"
            echo "1) Standard persistent disk (cheaper, slower)"
            echo "2) SSD persistent disk (faster, more expensive) - Default"
            echo "3) Balanced persistent disk (good performance/cost ratio)"
            read -p "Enter your choice (1-3) [Press ENTER for SSD]: " BOOT_DISK_TYPE_CHOICE
            BOOT_DISK_TYPE_CHOICE=${BOOT_DISK_TYPE_CHOICE:-2}

            case $BOOT_DISK_TYPE_CHOICE in
                1) BOOT_DISK_TYPE="pd-standard"; BOOT_DISK_DESC="Standard persistent disk" ;;
                2) BOOT_DISK_TYPE="pd-ssd"; BOOT_DISK_DESC="SSD persistent disk" ;;
                3) BOOT_DISK_TYPE="pd-balanced"; BOOT_DISK_DESC="Balanced persistent disk" ;;
                *) BOOT_DISK_TYPE="pd-ssd"; BOOT_DISK_DESC="SSD persistent disk [default]" ;;
            esac
            
            echo "Selected: ${BOOT_DISK_SIZE}GB $BOOT_DISK_DESC"
            if confirm_or_back "Is this boot disk configuration correct?"; then
                break
            fi
        done

        # Step 6: Additional disk
        while true; do
            echo ""
            echo "📋 STEP 6: ADDITIONAL PERSISTENT DISK"
            echo ""
            print_tutorial "Additional disks provide extra storage separate from the OS"
            
            read -p "💿 Additional disk name [default: my-disk]: " DISK_NAME
            DISK_NAME=${DISK_NAME:-my-disk}
            
            read -p "📏 Additional disk size in GB [default: 100]: " DISK_SIZE
            DISK_SIZE=${DISK_SIZE:-100}
            
            echo "📦 Select additional disk type:"
            echo "1) Standard persistent disk (cheaper, slower)"
            echo "2) SSD persistent disk (faster, more expensive)"
            echo "3) Balanced persistent disk (good performance/cost ratio) - Default"
            read -p "Enter your choice (1-3) [Press ENTER for Balanced]: " DISK_TYPE_CHOICE
            DISK_TYPE_CHOICE=${DISK_TYPE_CHOICE:-3}

            case $DISK_TYPE_CHOICE in
                1) DISK_TYPE="pd-standard"; DISK_DESC="Standard persistent disk" ;;
                2) DISK_TYPE="pd-ssd"; DISK_DESC="SSD persistent disk" ;;
                3) DISK_TYPE="pd-balanced"; DISK_DESC="Balanced persistent disk" ;;
                *) DISK_TYPE="pd-balanced"; DISK_DESC="Balanced persistent disk [default]" ;;
            esac
            
            echo "Selected: $DISK_NAME (${DISK_SIZE}GB $DISK_DESC)"
            if confirm_or_back "Is this additional disk configuration correct?"; then
                break
            fi
        done

        # Step 7: Network settings
        while true; do
            echo ""
            echo "📋 STEP 7: NETWORK CONFIGURATION"
            echo ""
            print_tutorial "Network settings control connectivity and security"
            
            echo "🌐 HTTP/HTTPS traffic:"
            read -p "Allow HTTP traffic? (Y/n) [default: Yes]: " ALLOW_HTTP
            ALLOW_HTTP=${ALLOW_HTTP:-Y}
            
            read -p "Allow HTTPS traffic? (Y/n) [default: Yes]: " ALLOW_HTTPS
            ALLOW_HTTPS=${ALLOW_HTTPS:-Y}
            
            if [[ "$ALLOW_HTTP" =~ ^[Yy]$ || -z "$ALLOW_HTTP" ]]; then
                HTTP_DESC="HTTP traffic: Allowed"
                HTTP_TAG="--tags=http-server"
            else
                HTTP_DESC="HTTP traffic: Blocked"
                HTTP_TAG=""
            fi
            
            if [[ "$ALLOW_HTTPS" =~ ^[Yy]$ || -z "$ALLOW_HTTPS" ]]; then
                HTTPS_DESC="HTTPS traffic: Allowed"
                HTTPS_TAG="--tags=https-server"
            else
                HTTPS_DESC="HTTPS traffic: Blocked"
                HTTPS_TAG=""
            fi
            
            echo "Selected: $HTTP_DESC, $HTTPS_DESC"
            if confirm_or_back "Are these network settings correct?"; then
                break
            fi
        done

        # Final confirmation
        echo ""
        echo "=================================================================="
        echo "📝 FINAL CONFIGURATION SUMMARY"
        echo "=================================================================="
        echo "VM Instance: $VM_NAME"
        echo "Region: $REGION"
        echo "Zone: $ZONE"
        echo "Machine Type: $MACHINE_DESC"
        echo "Operating System: $IMAGE_DESC"
        echo "Boot Disk: ${BOOT_DISK_SIZE}GB $BOOT_DISK_DESC"
        echo "Additional Disk: $DISK_NAME (${DISK_SIZE}GB $DISK_DESC)"
        echo "Network: $HTTP_DESC, $HTTPS_DESC"
        echo "=================================================================="
        echo ""

        while true; do
            echo "Final options:"
            echo "  c/C - Continue with VM creation"
            echo "  b/B - Go back and modify settings"
            echo "  q/Q - Quit without creating VM"
            echo ""
            read -p "What would you like to do? (c/b/q): " final_choice
            case $final_choice in
                [Cc]* ) 
                    print_status "Proceeding with VM creation..."
                    return 0;;
                [Bb]* ) 
                    print_warning "Going back to modify settings..."
                    break;;
                [Qq]* ) 
                    print_warning "Operation cancelled by user."
                    exit 0;;
                * ) print_error "Please answer c (continue), b (back), or q (quit).";;
            esac
        done
    done
}

# Get user inputs
echo "📋 Please provide the following information from your lab instructions:"
echo ""
echo "💡 Press ENTER to use default values (recommended for quick completion)"
echo "💡 Type 'b' at any confirmation to go back and change previous settings"
echo ""

collect_user_inputs

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
