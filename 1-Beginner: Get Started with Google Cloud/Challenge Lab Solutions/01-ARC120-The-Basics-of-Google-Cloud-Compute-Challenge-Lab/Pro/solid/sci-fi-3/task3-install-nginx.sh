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
echo "💡 Press ENTER to use default values (recommended for quick completion)"
echo ""

# VM name input with default
read -p "💻 Enter the VM INSTANCE NAME [Press ENTER for: my-instance]: " VM_NAME
VM_NAME=${VM_NAME:-my-instance}

# Zone input with default
read -p "🎯 Enter the ZONE [Press ENTER for: us-east4-a]: " ZONE
ZONE=${ZONE:-us-east4-a}

# Installation method
echo ""
echo "🔧 Select installation method:"
echo "1) SSH and install (Default - Direct installation via SSH)"
echo "2) Generate commands only (for manual execution)"
echo "3) Use startup script (reinstall VM with NGINX)"
read -p "Enter your choice (1-3) [Press ENTER for SSH install]: " INSTALL_METHOD
INSTALL_METHOD=${INSTALL_METHOD:-1}

# Additional NGINX configuration options
if [[ "$INSTALL_METHOD" == "1" ]]; then
    echo ""
    echo "🌐 NGINX Configuration Options:"
    read -p "Create custom index page? (y/N) [Press ENTER for No]: " CUSTOM_INDEX
    CUSTOM_INDEX=${CUSTOM_INDEX:-N}
    
    if [[ "$CUSTOM_INDEX" =~ ^[Yy]$ ]]; then
        read -p "Enter custom message for index page [Press ENTER for default]: " CUSTOM_MESSAGE
        CUSTOM_MESSAGE=${CUSTOM_MESSAGE:-"Hello from Google Cloud VM running NGINX!"}
    fi
    
    read -p "Enable NGINX status page? (y/N) [Press ENTER for No]: " ENABLE_STATUS
    ENABLE_STATUS=${ENABLE_STATUS:-N}
    
    read -p "Configure basic firewall rules? (Y/n) [Press ENTER for Yes]: " CONFIGURE_FIREWALL
    CONFIGURE_FIREWALL=${CONFIGURE_FIREWALL:-Y}
fi

echo ""
echo "=================================================================="
echo "📝 CONFIGURATION SUMMARY"
echo "=================================================================="
echo "VM Instance Name: $VM_NAME"
echo "Zone: $ZONE"
echo "Installation Method: $INSTALL_METHOD"
if [[ "$INSTALL_METHOD" == "1" ]]; then
    echo "Custom Index Page: $(if [[ "$CUSTOM_INDEX" =~ ^[Yy]$ ]]; then echo "Yes"; else echo "No"; fi)"
    if [[ "$CUSTOM_INDEX" =~ ^[Yy]$ && -n "$CUSTOM_MESSAGE" ]]; then
        echo "Custom Message: $CUSTOM_MESSAGE"
    fi
    echo "Status Page: $(if [[ "$ENABLE_STATUS" =~ ^[Yy]$ ]]; then echo "Enabled"; else echo "Disabled"; fi)"
    echo "Firewall Config: $(if [[ "$CONFIGURE_FIREWALL" =~ ^[Yy]$ || -z "$CONFIGURE_FIREWALL" ]]; then echo "Yes"; else echo "No"; fi)"
fi
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

case $INSTALL_METHOD in
    1)
        print_step "Installing NGINX using SSH connection..."
        echo ""
        
        print_status "Connecting to VM and installing NGINX..."
        
        # Create temporary script for NGINX installation
        TEMP_SCRIPT="/tmp/install_nginx_$(date +%s).sh"
        cat > "$TEMP_SCRIPT" << EOF
#!/bin/bash
echo "🔄 Updating package list..."
sudo apt update

echo "📦 Installing NGINX..."
sudo apt install -y nginx

echo "🚀 Starting NGINX service..."
sudo systemctl start nginx

echo "✅ Enabling NGINX to start on boot..."
sudo systemctl enable nginx
EOF

        # Add custom index page if requested
        if [[ "$CUSTOM_INDEX" =~ ^[Yy]$ ]]; then
            cat >> "$TEMP_SCRIPT" << EOF

echo "� Creating custom index page..."
sudo tee /var/www/html/index.html > /dev/null << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to NGINX on Google Cloud</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #4285f4; }
        .info { background: #e8f0fe; padding: 15px; border-radius: 4px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 NGINX Successfully Installed!</h1>
        <p><strong>Message:</strong> $CUSTOM_MESSAGE</p>
        <div class="info">
            <strong>Server Information:</strong><br>
            Hostname: \$(hostname)<br>
            Date: \$(date)<br>
            IP Address: \$(hostname -I)
        </div>
        <p>✅ NGINX is running and configured on this Google Cloud VM!</p>
    </div>
</body>
</html>
HTML
EOF
        fi

        # Add status page configuration if requested
        if [[ "$ENABLE_STATUS" =~ ^[Yy]$ ]]; then
            cat >> "$TEMP_SCRIPT" << EOF

echo "�📊 Configuring NGINX status page..."
sudo tee /etc/nginx/sites-available/status > /dev/null << 'CONF'
server {
    listen 80;
    server_name _;
    
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        deny all;
    }
}
CONF

sudo ln -sf /etc/nginx/sites-available/status /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
EOF
        fi

        cat >> "$TEMP_SCRIPT" << EOF

echo "📊 Checking NGINX status..."
sudo systemctl status nginx --no-pager

echo "🌐 Checking if NGINX is serving content..."
curl -s localhost | head -n 5

echo ""
echo "✅ NGINX installation and configuration completed!"
echo "🌍 NGINX is now running on this VM"
EOF

        chmod +x "$TEMP_SCRIPT"
        
        # Execute script on VM
        if gcloud compute scp "$TEMP_SCRIPT" "$VM_NAME:~/install_nginx.sh" --zone="$ZONE"; then
            print_status "Script uploaded to VM successfully!"
            
            if gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="chmod +x ~/install_nginx.sh && ~/install_nginx.sh"; then
                print_status "✅ NGINX installed successfully!"
                
                # Configure firewall if requested
                if [[ "$CONFIGURE_FIREWALL" =~ ^[Yy]$ || -z "$CONFIGURE_FIREWALL" ]]; then
                    print_status "🔧 Configuring firewall rules..."
                    
                    # Check if http-server tag exists on VM
                    VM_TAGS=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(tags.items[])")
                    
                    if [[ "$VM_TAGS" != *"http-server"* ]]; then
                        print_status "Adding http-server tag to VM..."
                        gcloud compute instances add-tags "$VM_NAME" --zone="$ZONE" --tags=http-server
                    fi
                    
                    # Ensure firewall rule exists
                    if ! gcloud compute firewall-rules describe default-allow-http >/dev/null 2>&1; then
                        print_status "Creating HTTP firewall rule..."
                        gcloud compute firewall-rules create default-allow-http \
                            --allow tcp:80 \
                            --source-ranges 0.0.0.0/0 \
                            --target-tags http-server \
                            --description "Allow HTTP traffic on port 80"
                    fi
                fi
                
                # Get external IP for testing
                EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
                
                if [[ -n "$EXTERNAL_IP" ]]; then
                    echo ""
                    print_status "🌐 Testing NGINX from external IP..."
                    sleep 5  # Wait a moment for NGINX to be fully ready
                    if curl -s --connect-timeout 10 "http://$EXTERNAL_IP" >/dev/null; then
                        print_status "✅ NGINX is accessible from external IP: $EXTERNAL_IP"
                        print_status "🌍 Test your NGINX installation: http://$EXTERNAL_IP"
                    else
                        print_warning "⚠️  NGINX may not be accessible from external IP yet. Please wait a moment and try: http://$EXTERNAL_IP"
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

# Create completion marker
echo "TASK3_COMPLETED=$(date)" > /tmp/arc120_task3_completed

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
print_status "🏆 CONGRATULATIONS! You have successfully completed:"
echo "✅ Task 1: Created Cloud Storage bucket"
echo "✅ Task 2: Created VM with persistent disk"  
echo "✅ Task 3: Installed NGINX web server"
echo ""
print_status "🎯 Go back to your lab page and click 'Check my progress' to verify completion!"
echo ""
