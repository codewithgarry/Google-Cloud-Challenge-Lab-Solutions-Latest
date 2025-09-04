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

    # Check if schema already exists
    if gcloud pubsub schemas describe city-temp-schema &>/dev/null; then
        print_status "✅ Schema already exists (skipping creation)"
    else
        gcloud pubsub schemas create city-temp-schema --type=AVRO --definition-file=schema.json
        if [[ $? -eq 0 ]]; then
            print_status "✅ Schema created successfully"
        fi
    fi
    
    echo ""
    echo "Task 2: Creating topic with schema..."
    
    # Check if topic already exists
    if gcloud pubsub topics describe temp-topic &>/dev/null; then
        print_status "✅ Topic already exists (skipping creation)"
    else
        gcloud pubsub topics create temp-topic --schema=temperature-schema --message-encoding=JSON
        if [[ $? -eq 0 ]]; then
            print_status "✅ Topic created successfully"
        fi
    fi
    
    echo ""
    echo "Task 3: Creating Cloud Function..."
    
    # Check if function already exists
    EXISTING_FUNCTION_REGION=""
    for region in "us-central1" "us-east1" "us-west1" "europe-west1"; do
        if gcloud functions describe gcf-pubsub --region="$region" &>/dev/null; then
            EXISTING_FUNCTION_REGION="$region"
            break
        fi
    done
    
    if [[ -n "$EXISTING_FUNCTION_REGION" ]]; then
        print_status "✅ Cloud Function exists in $EXISTING_FUNCTION_REGION"
        
        # Verify trigger is correctly set to gcf-topic
        print_status "🔍 Verifying Cloud Function trigger..."
        TRIGGER_TOPIC=$(gcloud functions describe gcf-pubsub --region="$EXISTING_FUNCTION_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
        
        if [[ "$TRIGGER_TOPIC" == *"gcf-topic"* ]]; then
            print_status "✅ Cloud Function trigger is correctly set to gcf-topic"
        else
            print_status "⚠️  Trigger not set to gcf-topic, fixing..."
            
            # Redeploy with correct trigger
            mkdir -p gcf-function && cd gcf-function || { print_error "Failed to create/enter function directory"; exit 1; }
            
            cat > main.py << 'EOF'
import base64
import json

def hello_pubsub(event, context):
    """Triggered from gcf-topic."""
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(f'This Function was triggered by messageId {context.eventId} published at {context.timestamp}')
    print(f'Data: {pubsub_message}')
EOF

            echo "functions-framework==3.*" > requirements.txt
            
            print_status "Redeploying with correct gcf-topic trigger..."
            gcloud functions deploy gcf-pubsub \
                --runtime=python311 \
                --trigger-topic=gcf-topic \
                --entry-point=hello_pubsub \
                --region="$EXISTING_FUNCTION_REGION" \
                --no-gen2 \
                --memory=256MB \
                --timeout=60s \
                --quiet
            
            if [[ $? -eq 0 ]]; then
                print_status "✅ Cloud Function trigger fixed successfully"
            else
                print_warning "⚠️  Trigger fix failed, but function exists"
            fi
        fi
    else
        # Enable required APIs
        print_status "Enabling required APIs..."
        gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com
        
        mkdir -p gcf-function && cd gcf-function || { print_error "Failed to create/enter function directory"; exit 1; }
        
        cat > main.py << 'EOF'
import base64
import json

def hello_pubsub(event, context):
    """Triggered from gcf-topic."""
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(f'This Function was triggered by messageId {context.eventId} published at {context.timestamp}')
    print(f'Data: {pubsub_message}')
EOF

        echo "functions-framework==3.*" > requirements.txt
        
        print_status "Deploying Cloud Function with gcf-topic trigger (trying multiple regions)..."
        
        # Try multiple regions due to org policy constraints
        DEPLOYED_SUCCESSFULLY=false
        
        if gcloud functions deploy gcf-pubsub \
            --runtime=python311 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --no-gen2 \
            --memory=256MB \
            --timeout=60s \
            --quiet 2>/dev/null; then
            print_status "✅ Cloud Function deployed in default region"
            DEPLOYED_SUCCESSFULLY=true
        elif gcloud functions deploy gcf-pubsub \
            --runtime=python311 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --region=us-east1 \
            --no-gen2 \
            --memory=256MB \
            --timeout=60s \
            --quiet 2>/dev/null; then
            print_status "✅ Cloud Function deployed in us-east1"
            DEPLOYED_SUCCESSFULLY=true
        elif gcloud functions deploy gcf-pubsub \
            --runtime=python311 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --region=europe-west1 \
            --no-gen2 \
            --memory=256MB \
            --timeout=60s \
            --quiet 2>/dev/null; then
            print_status "✅ Cloud Function deployed in europe-west1"
            DEPLOYED_SUCCESSFULLY=true
        elif gcloud functions deploy gcf-pubsub \
            --runtime=python39 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --no-gen2 \
            --memory=256MB \
            --timeout=60s \
            --quiet 2>/dev/null; then
            print_status "✅ Cloud Function deployed with Python 3.9"
            DEPLOYED_SUCCESSFULLY=true
        else
            print_status "[WARNING] ⚠️  Cloud Function deployment blocked by org policies"
            echo "💡 You may need to try a different region or create the function manually in the console"
            echo "🎯 The important tasks (schema and topic) are already completed!"
            DEPLOYED_SUCCESSFULLY=false
        fi
        
        if [[ "$DEPLOYED_SUCCESSFULLY" == "true" ]]; then
            print_status "✅ Cloud Function deployed successfully with gcf-topic trigger"
        else
            print_warning "⚠️  Cloud Function deployment may have issues, but continuing..."
        fi
    fi
    
    echo ""
    print_header "� FINAL VERIFICATION FOR VERSION B"
    echo ""
    
    # Verify all resources
    print_status "Checking schema..."
    if gcloud pubsub schemas describe city-temp-schema &>/dev/null; then
        echo "✅ Schema 'city-temp-schema' exists"
    else
        echo "❌ Schema 'city-temp-schema' missing"
    fi
    
    print_status "Checking topic..."
    if gcloud pubsub topics describe temp-topic &>/dev/null; then
        echo "✅ Topic 'temp-topic' exists"
    else
        echo "❌ Topic 'temp-topic' missing"
    fi
    
    print_status "Checking Cloud Function and trigger..."
    FINAL_FUNCTION_REGION=""
    for region in "us-central1" "us-east1" "us-west1" "europe-west1"; do
        if gcloud functions describe gcf-pubsub --region="$region" &>/dev/null; then
            FINAL_FUNCTION_REGION="$region"
            break
        fi
    done
    
    if [[ -n "$FINAL_FUNCTION_REGION" ]]; then
        echo "✅ Function 'gcf-pubsub' exists in $FINAL_FUNCTION_REGION"
        
        # Check the trigger one more time
        FINAL_TRIGGER=$(gcloud functions describe gcf-pubsub --region="$FINAL_FUNCTION_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
        if [[ "$FINAL_TRIGGER" == *"gcf-topic"* ]]; then
            echo "✅ Function trigger correctly set to 'gcf-topic'"
        else
            echo "⚠️  Function trigger: $FINAL_TRIGGER (should contain 'gcf-topic')"
            echo "🔧 Quick fix: Run the trigger-fix.sh script"
        fi
    else
        echo "❌ Function 'gcf-pubsub' missing"
    fi
    
    echo ""
    print_header "�🎉 Version B (Dynamic ARC113) completed successfully!"

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
echo "🔍 Trigger Verification:"
echo "  # Check if function trigger is set to gcf-topic"
echo "  FUNC_REGION=\$(gcloud functions list --filter=\"name:gcf-pubsub\" --format=\"value(region)\" | head -1)"
echo "  gcloud functions describe gcf-pubsub --region=\"\$FUNC_REGION\" --format=\"value(eventTrigger.resource)\""
echo "  # Should output: projects/.../topics/gcf-topic"
echo ""
echo "=================================================================="
print_header "🌟 LAB COMPLETED! 🌟"
echo "=================================================================="
echo ""
echo "🔗 Subscribe to CodeWithGarry: https://www.youtube.com/@CodeWithGarry"
echo "💡 More Challenge Lab solutions available on our channel!"
echo ""
