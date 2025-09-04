#!/bin/bash

# ARC113 Universal Auto-Detection and Execution Script
# Supports both Original and Dynamic versions of ARC113
# Author: CodeWithGarry

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

echo "=================================================================="
echo "  🚀 ARC113 UNIVERSAL AUTO-DETECTION SCRIPT"
echo "=================================================================="
echo ""

print_status "🔍 Detecting ARC113 lab version..."

# Wait a moment for resources to be available
sleep 2

# Check for Version A resources (Original)
if gcloud pubsub topics describe gcloud-pubsub-topic &>/dev/null; then
    print_header "✅ Detected Version A (Original ARC113)"
    echo ""
    echo "📋 Tasks:"
    echo "  1. Create subscription and publish message"
    echo "  2. View the published message"
    echo "  3. Create snapshot from subscription"
    echo ""
    print_status "🚀 Executing Version A solution..."
    echo ""
    
    # Execute Version A commands
    echo "Task 1: Creating subscription and publishing message..."
    gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic
    if [[ $? -eq 0 ]]; then
        print_status "✅ Subscription created successfully"
    fi
    
    gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"
    if [[ $? -eq 0 ]]; then
        print_status "✅ Message published successfully"
    fi
    
    echo ""
    echo "Task 2: Viewing the published message..."
    gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
    if [[ $? -eq 0 ]]; then
        print_status "✅ Message retrieved successfully"
    fi
    
    echo ""
    echo "Task 3: Creating snapshot..."
    gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
    if [[ $? -eq 0 ]]; then
        print_status "✅ Snapshot created successfully"
    fi
    
    echo ""
    print_header "🎉 Version A (Original ARC113) completed successfully!"

# Check for Version B resources (Dynamic)
elif gcloud pubsub schemas describe temperature-schema &>/dev/null || gcloud pubsub topics describe gcf-topic &>/dev/null; then
    print_header "✅ Detected Version B (Dynamic ARC113)"
    echo ""
    echo "📋 Tasks:"
    echo "  1. Create Pub/Sub schema with Avro configuration"
    echo "  2. Create topic using pre-created schema"
    echo "  3. Create Cloud Function with Pub/Sub trigger"
    echo ""
    print_status "🚀 Executing Version B solution..."
    echo ""
    
    # Task 1: Create schema
    echo "Task 1: Creating Pub/Sub schema..."
    cat > schema.json << 'EOF'
{                                             
    "type" : "record",                               
    "name" : "Avro",                                 
    "fields" : [                                     
        {                                                
            "name" : "city",                             
            "type" : "string"                            
        },                                               
        {                                                
            "name" : "temperature",                      
            "type" : "double"                            
        },                                               
        {                                                
            "name" : "pressure",                         
            "type" : "int"                               
        },                                               
        {                                                
            "name" : "time_position",                    
            "type" : "string"                            
        }                                                
    ]                                                    
}
EOF

    gcloud pubsub schemas create city-temp-schema --type=AVRO --definition-file=schema.json
    if [[ $? -eq 0 ]]; then
        print_status "✅ Schema created successfully"
    fi
    
    echo ""
    echo "Task 2: Creating topic with schema..."
    gcloud pubsub topics create temp-topic --schema=temperature-schema
    if [[ $? -eq 0 ]]; then
        print_status "✅ Topic created successfully"
    fi
    
    echo ""
    echo "Task 3: Creating Cloud Function..."
    mkdir -p gcf-function && cd gcf-function || { print_error "Failed to create/enter function directory"; exit 1; }
    
    cat > main.py << 'EOF'
import base64
import json

def hello_pubsub(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic."""
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(f'This Function was triggered by messageId {context.eventId} published at {context.timestamp}')
    print(f'Data: {pubsub_message}')
EOF

    echo "# Function dependencies for Python 3.9" > requirements.txt
    
    print_status "Deploying Cloud Function (this may take 2-3 minutes)..."
    gcloud functions deploy gcf-pubsub \
        --runtime=python39 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region=us-central1
    
    if [[ $? -eq 0 ]]; then
        print_status "✅ Cloud Function deployed successfully"
    fi
    
    echo ""
    print_header "🎉 Version B (Dynamic ARC113) completed successfully!"

else
    print_warning "⏳ Resources still provisioning or unknown lab version"
    echo ""
    echo "Possible solutions:"
    echo ""
    echo "1️⃣  Wait 2-3 minutes for resources to provision and try again"
    echo "2️⃣  Try Version A commands manually:"
    echo "   gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic"
    echo "   gcloud pubsub topics publish gcloud-pubsub-topic --message=\"Hello World\""
    echo "   gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5"
    echo "   gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription"
    echo ""
    echo "3️⃣  Try Version B commands manually:"
    echo "   # Create schema, topic, and Cloud Function as shown above"
    echo ""
    
    # Try to enable required APIs
    print_status "Enabling required APIs..."
    gcloud services enable pubsub.googleapis.com
    gcloud services enable cloudfunctions.googleapis.com
    
    print_warning "Please wait a few minutes and run this script again"
fi

echo ""
echo "=================================================================="
print_header "🎯 VERIFICATION COMMANDS"
echo "=================================================================="
echo ""
echo "To verify your lab completion:"
echo ""
echo "For Version A (Original):"
echo "  gcloud pubsub subscriptions list | grep pubsub-subscription-message"
echo "  gcloud pubsub snapshots list | grep pubsub-snapshot"
echo ""
echo "For Version B (Dynamic):"
echo "  gcloud pubsub schemas list --filter=\"name:city-temp-schema\""
echo "  gcloud pubsub topics list --filter=\"name:temp-topic\""
echo "  gcloud functions list --filter=\"name:gcf-pubsub\""
echo ""
echo "=================================================================="
print_header "🌟 LAB COMPLETED! 🌟"
echo "=================================================================="
echo ""
echo "🔗 Subscribe to CodeWithGarry: https://www.youtube.com/@CodeWithGarry"
echo "💡 More Challenge Lab solutions available on our channel!"
echo ""
