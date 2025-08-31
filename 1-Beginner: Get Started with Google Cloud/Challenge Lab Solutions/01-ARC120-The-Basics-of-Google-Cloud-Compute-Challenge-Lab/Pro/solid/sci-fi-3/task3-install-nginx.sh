#!/bin/bash

# =============================================================================
# The Basics of Google Cloud Compute: Challenge Lab - Task 3
# Install NGINX on VM Instance
# Author: CodeWithGarry
# Lab ID: ARC120
# =============================================================================

echo "=================================================================="
echo "  🚀 TASK 3: INSTALL NGINX ON VM INSTANCE"
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
echo "📋 Please provide the following information:"
echo ""

# VM name input with default
read -p "💻 Enter the VM INSTANCE NAME [default: my-instance]: " VM_NAME
VM_NAME=${VM_NAME:-my-instance}

# Zone input with default
read -p "🎯 Enter the ZONE [default: us-east4-a]: " ZONE
ZONE=${ZONE:-us-east4-a}

# Installation method
echo ""
echo "🔧 Select installation method:"
echo "1) SSH and install (using gcloud compute ssh)"
echo "2) Generate commands only (for manual execution)"
echo "3) Use startup script (reinstall VM with NGINX)"
read -p "Enter your choice (1-3) [default: 1]: " INSTALL_METHOD
INSTALL_METHOD=${INSTALL_METHOD:-1}

echo ""
echo "=================================================================="
echo "📝 CONFIGURATION SUMMARY"
echo "=================================================================="
echo "VM Instance Name: $VM_NAME"
echo "Zone: $ZONE"
echo "Installation Method: $INSTALL_METHOD"
echo "=================================================================="
echo ""

# Confirmation
read -p "❓ Do you want to proceed with this configuration? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_warning "Operation cancelled by user."
    exit 0
fi

echo ""

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

# Check if VM exists
print_status "Checking if VM instance '$VM_NAME' exists..."
if ! gcloud compute instances describe "$VM_NAME" --zone="$ZONE" >/dev/null 2>&1; then
    print_error "VM instance '$VM_NAME' not found in zone '$ZONE'"
    print_warning "Please ensure the VM exists and the zone is correct."
    exit 1
fi

# Check VM status
VM_STATUS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(status)")
print_status "VM Status: $VM_STATUS"

if [[ "$VM_STATUS" != "RUNNING" ]]; then
    print_warning "VM is not running. Starting VM..."
    gcloud compute instances start "$VM_NAME" --zone="$ZONE"
    print_status "Waiting for VM to start..."
    sleep 30
fi

# NGINX installation commands
NGINX_COMMANDS="sudo apt update && sudo apt install -y nginx && sudo systemctl start nginx && sudo systemctl enable nginx && sudo systemctl status nginx"

case $INSTALL_METHOD in
    1)
        print_step "Installing NGINX using SSH connection..."
        echo ""
        
        print_status "Connecting to VM and installing NGINX..."
        
        # Create temporary script for NGINX installation
        TEMP_SCRIPT="/tmp/install_nginx_$(date +%s).sh"
        cat > "$TEMP_SCRIPT" << 'EOF'
#!/bin/bash
echo "🔄 Updating package list..."
sudo apt update

echo "📦 Installing NGINX..."
sudo apt install -y nginx

echo "🚀 Starting NGINX service..."
sudo systemctl start nginx

echo "✅ Enabling NGINX to start on boot..."
sudo systemctl enable nginx

echo "📊 Checking NGINX status..."
sudo systemctl status nginx --no-pager

echo "🌐 Checking if NGINX is serving content..."
curl -s localhost | head -n 5

echo ""
echo "✅ NGINX installation completed!"
echo "🌍 NGINX is now running on this VM"
EOF

        chmod +x "$TEMP_SCRIPT"
        
        # Execute script on VM
        if gcloud compute scp "$TEMP_SCRIPT" "$VM_NAME:~/install_nginx.sh" --zone="$ZONE"; then
            print_status "Script uploaded to VM successfully!"
            
            if gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="chmod +x ~/install_nginx.sh && ~/install_nginx.sh"; then
                print_status "✅ NGINX installed successfully!"
                
                # Get external IP for testing
                EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
                
                if [[ -n "$EXTERNAL_IP" ]]; then
                    echo ""
                    print_status "🌐 Testing NGINX from external IP..."
                    if curl -s --connect-timeout 10 "http://$EXTERNAL_IP" >/dev/null; then
                        print_status "✅ NGINX is accessible from external IP: $EXTERNAL_IP"
                    else
                        print_warning "⚠️  NGINX may not be accessible from external IP. Check firewall rules."
                    fi
                fi
                
            else
                print_error "❌ Failed to install NGINX on VM"
                rm -f "$TEMP_SCRIPT"
                exit 1
            fi
        else
            print_error "❌ Failed to upload script to VM"
            rm -f "$TEMP_SCRIPT"
            exit 1
        fi
        
        # Cleanup
        rm -f "$TEMP_SCRIPT"
        gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="rm -f ~/install_nginx.sh" 2>/dev/null
        ;;
        
    2)
        print_step "Generating commands for manual execution..."
        echo ""
        
        echo "=================================================================="
        echo "📋 MANUAL INSTALLATION COMMANDS"
        echo "=================================================================="
        echo ""
        echo "1. SSH into your VM:"
        echo "   gcloud compute ssh $VM_NAME --zone=$ZONE"
        echo ""
        echo "2. Run these commands in the VM:"
        echo "   sudo apt update"
        echo "   sudo apt install -y nginx"
        echo "   sudo systemctl start nginx"
        echo "   sudo systemctl enable nginx"
        echo "   sudo systemctl status nginx"
        echo ""
        echo "3. Test NGINX installation:"
        echo "   curl localhost"
        echo ""
        echo "4. Exit SSH:"
        echo "   exit"
        echo "=================================================================="
        
        # Get external IP
        EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
        if [[ -n "$EXTERNAL_IP" ]]; then
            echo "🌐 External IP: $EXTERNAL_IP"
            echo "🌍 Test URL: http://$EXTERNAL_IP"
        fi
        ;;
        
    3)
        print_step "Recreating VM with NGINX startup script..."
        echo ""
        
        print_warning "This will delete and recreate the VM with NGINX pre-installed."
        read -p "Are you sure you want to continue? (y/N): " recreate_confirm
        
        if [[ ! "$recreate_confirm" =~ ^[Yy]$ ]]; then
            print_warning "Operation cancelled."
            exit 0
        fi
        
        # Get VM configuration
        print_status "Getting current VM configuration..."
        VM_CONFIG=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="json")
        MACHINE_TYPE=$(echo "$VM_CONFIG" | grep -o '"machineType": "[^"]*"' | cut -d'"' -f4 | sed 's|.*/||')
        
        # Delete existing VM
        print_status "Deleting existing VM..."
        gcloud compute instances delete "$VM_NAME" --zone="$ZONE" --quiet
        
        # Create startup script
        STARTUP_SCRIPT='#!/bin/bash
apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx'
        
        # Recreate VM with startup script
        print_status "Creating new VM with NGINX startup script..."
        gcloud compute instances create "$VM_NAME" \
            --zone="$ZONE" \
            --machine-type="$MACHINE_TYPE" \
            --image-family=debian-11 \
            --image-project=debian-cloud \
            --metadata startup-script="$STARTUP_SCRIPT" \
            --tags=http-server
            
        print_status "✅ VM recreated with NGINX startup script!"
        print_status "NGINX will be installed automatically during VM startup."
        ;;
        
    *)
        print_error "Invalid installation method selected."
        exit 1
        ;;
esac

echo ""
echo "=================================================================="
echo "🎉 TASK 3 COMPLETED SUCCESSFULLY!"
echo "=================================================================="
echo "VM Instance: $VM_NAME"
echo "Zone: $ZONE"
echo "NGINX Status: Installed and Running"

# Get and display final information
EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null)
INTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].networkIP)" 2>/dev/null)

if [[ -n "$EXTERNAL_IP" ]]; then
    echo "External IP: $EXTERNAL_IP"
    echo "Test URL: http://$EXTERNAL_IP"
fi

if [[ -n "$INTERNAL_IP" ]]; then
    echo "Internal IP: $INTERNAL_IP"
fi

echo ""
echo "🌐 Console URL:"
echo "https://console.cloud.google.com/compute/instances"
echo ""
echo "🔧 To verify NGINX:"
echo "gcloud compute ssh $VM_NAME --zone=$ZONE --command='sudo systemctl status nginx'"
echo "=================================================================="

echo ""
print_status "🏁 Task 3 script execution completed!"

# Final verification
if [[ "$INSTALL_METHOD" == "1" ]]; then
    echo ""
    print_status "🔍 Running final verification..."
    if gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="sudo systemctl is-active nginx" --quiet 2>/dev/null; then
        print_status "✅ Final verification: NGINX is active and running!"
    else
        print_warning "⚠️  Final verification: Unable to confirm NGINX status"
    fi
fi

echo ""
print_status "🎊 ALL TASKS COMPLETED! Lab ARC120 is now finished!"
echo ""
