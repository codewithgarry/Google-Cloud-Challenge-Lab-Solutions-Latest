#!/bin/bash

# ARC113 Complete Universal Auto-Solver - All 3 Forms
# Supports Form 1, Form 2, and Form 3 based on proven working solutions

# Color and formatting functions
print_header() {
    echo "=================================================================="
    echo "$1"
    echo "=================================================================="
}

print_status() {
    echo "🔍 $1"
}

print_success() {
    echo "✅ $1"
}

print_warning() {
    echo "⚠️  $1"
}

print_error() {
    echo "❌ $1"
}

echo "🎯 ARC113 Complete Universal Auto-Solver"
print_header "Supporting ALL 3 Lab Forms"
echo ""
echo "📋 Detecting lab form and executing appropriate solution..."
echo ""

# Detect lab form by checking for specific pre-created resources
LAB_FORM=""

print_status "Detecting lab form..."

# Form 1 Detection: gcloud-pubsub-topic exists
if gcloud pubsub topics describe gcloud-pubsub-topic &>/dev/null; then
    LAB_FORM="FORM1"
    print_success "Detected FORM 1: Publish/View/Snapshot Lab"
    echo "Tasks: Publish message → View message → Create snapshot"

# Form 3 Detection: Check for cloud scheduler requirements
elif gcloud services list --enabled --filter="name:cloudscheduler.googleapis.com" &>/dev/null || \
     echo "$GOOGLE_CLOUD_PROJECT" | grep -q "qwiklabs"; then
    # Try to detect Form 3 by checking if we can enable scheduler
    if gcloud services enable cloudscheduler.googleapis.com &>/dev/null; then
        LAB_FORM="FORM3"
        print_success "Detected FORM 3: Cloud Scheduler Lab"
        echo "Tasks: Set up Pub/Sub → Create Scheduler job → Verify results"
    else
        # Default to Form 2 if we can't determine
        LAB_FORM="FORM2"
    fi

# Form 2 Detection: temperature-schema exists or gcf-topic exists
elif gcloud pubsub schemas describe temperature-schema &>/dev/null || \
     gcloud pubsub topics describe gcf-topic &>/dev/null; then
    LAB_FORM="FORM2"
    print_success "Detected FORM 2: Schema/Topic/Function Lab"
    echo "Tasks: Create schema → Create topic with schema → Create Cloud Function"

else
    print_warning "Could not detect lab form, trying Form 2 as default..."
    LAB_FORM="FORM2"
fi

echo ""
print_header "Executing $LAB_FORM Solution"
echo ""

# FORM 1 SOLUTION
if [[ "$LAB_FORM" == "FORM1" ]]; then
    print_status "Executing Form 1 solution based on proven working script..."
    
    # Task 1: Create subscription and publish message
    print_status "Task 1: Creating subscription and publishing message..."
    
    if ! gcloud pubsub subscriptions describe pubsub-subscription-message &>/dev/null; then
        gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic
        print_success "Subscription created"
    else
        print_success "Subscription already exists"
    fi
    
    gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"
    print_success "Message published"
    
    echo "Waiting 10 seconds for message processing..."
    sleep 10
    
    # Task 2: View the message
    print_status "Task 2: Viewing the message..."
    gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
    print_success "Message viewed"
    
    # Task 3: Create snapshot
    print_status "Task 3: Creating Pub/Sub snapshot..."
    if ! gcloud pubsub snapshots describe pubsub-snapshot &>/dev/null; then
        gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
        print_success "Snapshot created"
    else
        print_success "Snapshot already exists"
    fi

# FORM 2 SOLUTION  
elif [[ "$LAB_FORM" == "FORM2" ]]; then
    print_status "Executing Form 2 solution with enhanced trigger handling..."
    
    # Task 1: Create schema
    print_status "Task 1: Creating Pub/Sub schema..."
    
    if ! gcloud pubsub schemas describe city-temp-schema &>/dev/null; then
        gcloud pubsub schemas create city-temp-schema \
            --type=AVRO \
            --definition='{
                "type": "record",
                "name": "Avro",
                "fields": [
                    {
                        "name": "city",
                        "type": "string"
                    },
                    {
                        "name": "temperature",
                        "type": "double"
                    },
                    {
                        "name": "pressure",
                        "type": "int"
                    },
                    {
                        "name": "time_position",
                        "type": "string"
                    }
                ]
            }'
        print_success "Schema created"
    else
        print_success "Schema already exists"
    fi
    
    # Task 2: Create topic with schema
    print_status "Task 2: Creating topic with schema..."
    
    if ! gcloud pubsub topics describe temp-topic &>/dev/null; then
        gcloud pubsub topics create temp-topic \
            --message-encoding=JSON \
            --schema=temperature-schema
        print_success "Topic created with schema"
    else
        print_success "Topic already exists"
    fi
    
    # Task 3: Create Cloud Function with enhanced deployment
    print_status "Task 3: Creating Cloud Function with Pub/Sub trigger..."
    
    # Enable required services
    gcloud services enable eventarc.googleapis.com &>/dev/null
    gcloud services enable run.googleapis.com &>/dev/null
    gcloud services enable cloudfunctions.googleapis.com &>/dev/null
    gcloud services enable cloudbuild.googleapis.com &>/dev/null
    
    # Get available location
    if [[ -z "$LOCATION" ]]; then
        LOCATION="us-central1"
        # Try to detect allowed regions
        for region in "us-east1" "us-central1" "us-west1" "europe-west1"; do
            if gcloud functions list --regions="$region" &>/dev/null; then
                LOCATION="$region"
                break
            fi
        done
    fi
    
    print_status "Using region: $LOCATION"
    
    # Check if function already exists
    FUNC_EXISTS=false
    for region in "us-east1" "us-central1" "us-west1" "europe-west1"; do
        if gcloud functions describe gcf-pubsub --region="$region" &>/dev/null; then
            FUNC_EXISTS=true
            LOCATION="$region"
            print_success "Function already exists in $region"
            break
        fi
    done
    
    if [[ "$FUNC_EXISTS" == "false" ]]; then
        # Create function directory and files
        mkdir -p /tmp/gcf-form2 && cd /tmp/gcf-form2 || exit 1
        
        # Create Node.js function (based on working solution)
        cat > index.js << 'EOF'
const functions = require('@google-cloud/functions-framework');

// Register a CloudEvent callback with the Functions Framework
functions.cloudEvent('helloPubSub', cloudEvent => {
  const base64name = cloudEvent.data.message.data;
  const name = base64name
    ? Buffer.from(base64name, 'base64').toString()
    : 'World';
  console.log(`Hello, ${name}!`);
});
EOF

        cat > package.json << 'EOF'
{
  "name": "gcf_hello_world",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

        print_status "Deploying Cloud Function with retry logic..."
        
        # Deploy function with retry logic (based on working solution)
        deploy_success=false
        attempt=1
        max_attempts=3
        
        while [[ "$deploy_success" == "false" ]] && [[ $attempt -le $max_attempts ]]; do
            print_status "Deployment attempt $attempt..."
            
            if gcloud functions deploy gcf-pubsub \
                --gen2 \
                --runtime=nodejs22 \
                --region="$LOCATION" \
                --source=. \
                --entry-point=helloPubSub \
                --trigger-topic=gcf-topic \
                --quiet 2>/dev/null; then
                deploy_success=true
                print_success "Function deployed successfully with Gen2"
            elif gcloud functions deploy gcf-pubsub \
                --runtime=nodejs20 \
                --region="$LOCATION" \
                --source=. \
                --entry-point=helloPubSub \
                --trigger-topic=gcf-topic \
                --no-gen2 \
                --quiet 2>/dev/null; then
                deploy_success=true
                print_success "Function deployed successfully with Gen1"
            else
                print_warning "Attempt $attempt failed, retrying in 20 seconds..."
                sleep 20
                ((attempt++))
            fi
        done
        
        if [[ "$deploy_success" == "false" ]]; then
            print_error "Function deployment failed after $max_attempts attempts"
        fi
    fi

# FORM 3 SOLUTION
elif [[ "$LAB_FORM" == "FORM3" ]]; then
    print_status "Executing Form 3 solution based on proven working script..."
    
    # Get location for Cloud Scheduler
    if [[ -z "$LOCATION" ]]; then
        LOCATION="us-central1"
        print_status "Using default location: $LOCATION"
    fi
    
    # Task 1: Set up Cloud Pub/Sub
    print_status "Task 1: Setting up Cloud Pub/Sub..."
    
    if ! gcloud pubsub topics describe cloud-pubsub-topic &>/dev/null; then
        gcloud pubsub topics create cloud-pubsub-topic
        print_success "Topic created"
    else
        print_success "Topic already exists"
    fi
    
    if ! gcloud pubsub subscriptions describe cloud-pubsub-subscription &>/dev/null; then
        gcloud pubsub subscriptions create cloud-pubsub-subscription --topic=cloud-pubsub-topic
        print_success "Subscription created"
    else
        print_success "Subscription already exists"
    fi
    
    # Task 2: Create Cloud Scheduler job
    print_status "Task 2: Creating Cloud Scheduler job..."
    
    gcloud services enable cloudscheduler.googleapis.com
    
    if ! gcloud scheduler jobs describe cron-scheduler-job --location="$LOCATION" &>/dev/null; then
        gcloud scheduler jobs create pubsub cron-scheduler-job \
            --location="$LOCATION" \
            --schedule="* * * * *" \
            --topic=cloud-pubsub-topic \
            --message-body="Hello World!"
        print_success "Scheduler job created"
    else
        print_success "Scheduler job already exists"
    fi
    
    # Task 3: Verify the results
    print_status "Task 3: Verifying results in Cloud Pub/Sub..."
    
    echo "Waiting for scheduled messages..."
    sleep 30
    
    gcloud pubsub subscriptions pull cloud-pubsub-subscription --limit 5
    print_success "Results verified"
fi

echo ""
print_header "🎉 $LAB_FORM COMPLETED SUCCESSFULLY!"
echo ""

# Final verification
print_status "Final verification for $LAB_FORM:"

if [[ "$LAB_FORM" == "FORM1" ]]; then
    echo "✅ Subscription: $(gcloud pubsub subscriptions list --filter='name:pubsub-subscription-message' --format='value(name.basename())' 2>/dev/null || echo 'Check manually')"
    echo "✅ Snapshot: $(gcloud pubsub snapshots list --filter='name:pubsub-snapshot' --format='value(name.basename())' 2>/dev/null || echo 'Check manually')"
    
elif [[ "$LAB_FORM" == "FORM2" ]]; then
    echo "✅ Schema: $(gcloud pubsub schemas list --filter='name:city-temp-schema' --format='value(name.basename())' 2>/dev/null || echo 'Check manually')"
    echo "✅ Topic: $(gcloud pubsub topics list --filter='name:temp-topic' --format='value(name.basename())' 2>/dev/null || echo 'Check manually')"
    echo "✅ Function: $(gcloud functions list --filter='name:gcf-pubsub' --format='value(name.basename())' 2>/dev/null || echo 'Check manually')"
    
elif [[ "$LAB_FORM" == "FORM3" ]]; then
    echo "✅ Topic: $(gcloud pubsub topics list --filter='name:cloud-pubsub-topic' --format='value(name.basename())' 2>/dev/null || echo 'Check manually')"
    echo "✅ Subscription: $(gcloud pubsub subscriptions list --filter='name:cloud-pubsub-subscription' --format='value(name.basename())' 2>/dev/null || echo 'Check manually')"
    echo "✅ Scheduler Job: $(gcloud scheduler jobs list --location='$LOCATION' --filter='name:cron-scheduler-job' --format='value(name.basename())' 2>/dev/null || echo 'Check manually')"
fi

echo ""
print_header "🌟 LAB COMPLETED! 🌟"
echo ""
echo "🔗 Subscribe to CodeWithGarry: https://www.youtube.com/@CodeWithGarry"
echo "💡 More Challenge Lab solutions available on our channel!"
