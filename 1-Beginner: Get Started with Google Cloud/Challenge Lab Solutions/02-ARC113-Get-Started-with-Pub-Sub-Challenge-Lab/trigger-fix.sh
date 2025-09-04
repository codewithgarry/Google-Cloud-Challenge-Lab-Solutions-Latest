#!/bin/bash

# ARC113 Cloud Function Trigger Fix
# Specifically addresses "Please create a trigger for cloud function from gcf-topic topic"

echo "🎯 ARC113 Cloud Function Trigger Fix"
echo "===================================="
echo ""

echo "🔍 Checking current state..."

# Check if function exists
if gcloud functions list --filter="name:gcf-pubsub" --format="value(name)" | grep -q "gcf-pubsub"; then
    echo "✅ Function 'gcf-pubsub' exists"
    
    # Get function details
    FUNCTION_REGION=$(gcloud functions list --filter="name:gcf-pubsub" --format="value(region)" | head -1)
    echo "📍 Function is in region: $FUNCTION_REGION"
    
    # Check current trigger
    echo "🔍 Checking current trigger..."
    CURRENT_TRIGGER=$(gcloud functions describe gcf-pubsub --region="$FUNCTION_REGION" --format="value(eventTrigger.eventType)" 2>/dev/null)
    
    if [[ "$CURRENT_TRIGGER" == *"pubsub"* ]]; then
        echo "✅ Pub/Sub trigger exists"
        
        # Check if it's the right topic
        TRIGGER_TOPIC=$(gcloud functions describe gcf-pubsub --region="$FUNCTION_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
        echo "📡 Current trigger topic: $TRIGGER_TOPIC"
        
        if [[ "$TRIGGER_TOPIC" == *"gcf-topic"* ]]; then
            echo "✅ Trigger is correctly set to gcf-topic"
            echo "🎉 Function trigger is properly configured!"
        else
            echo "⚠️  Trigger is not set to gcf-topic, fixing..."
            # Need to redeploy with correct trigger
            echo "🔧 Redeploying function with correct trigger..."
            
            # Get current directory and create function files
            mkdir -p /tmp/gcf-trigger-fix && cd /tmp/gcf-trigger-fix || exit 1
            
            cat > main.py << 'EOF'
def hello_pubsub(event, context):
    """Cloud Function triggered by gcf-topic."""
    import base64
    
    if 'data' in event:
        message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Received message from gcf-topic: {message}')
    else:
        print('No data in event from gcf-topic')
    
    print(f'Event ID: {context.eventId}')
    print(f'Timestamp: {context.timestamp}')
    print(f'Function triggered by messageId {context.eventId} published at {context.timestamp}')
EOF

            echo "functions-framework==3.*" > requirements.txt
            
            # Redeploy with explicit trigger
            gcloud functions deploy gcf-pubsub \
                --runtime=python311 \
                --trigger-topic=gcf-topic \
                --entry-point=hello_pubsub \
                --region="$FUNCTION_REGION" \
                --no-gen2 \
                --memory=256MB \
                --timeout=60s \
                --quiet
        fi
    else
        echo "❌ No Pub/Sub trigger found, fixing..."
        echo "🔧 Redeploying function with Pub/Sub trigger..."
        
        # Create function with proper trigger
        mkdir -p /tmp/gcf-trigger-fix && cd /tmp/gcf-trigger-fix || exit 1
        
        cat > main.py << 'EOF'
def hello_pubsub(event, context):
    """Cloud Function triggered by gcf-topic."""
    import base64
    
    if 'data' in event:
        message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Received message from gcf-topic: {message}')
    else:
        print('No data in event from gcf-topic')
    
    print(f'Event ID: {context.eventId}')
    print(f'Timestamp: {context.timestamp}')
    print(f'Function triggered by messageId {context.eventId} published at {context.timestamp}')
EOF

        echo "functions-framework==3.*" > requirements.txt
        
        # Deploy with explicit trigger
        gcloud functions deploy gcf-pubsub \
            --runtime=python311 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --region="$FUNCTION_REGION" \
            --no-gen2 \
            --memory=256MB \
            --timeout=60s \
            --quiet
    fi
    
else
    echo "❌ Function 'gcf-pubsub' not found, creating it..."
    
    # Check for available regions
    echo "🔍 Finding available region..."
    
    DEPLOY_REGION=""
    for region in "us-central1" "us-east1" "us-west1" "europe-west1"; do
        if gcloud functions list --regions="$region" &>/dev/null; then
            DEPLOY_REGION="$region"
            echo "✅ Using region: $region"
            break
        fi
    done
    
    if [[ -z "$DEPLOY_REGION" ]]; then
        DEPLOY_REGION="us-central1"  # Fallback
        echo "⚠️  Using fallback region: $DEPLOY_REGION"
    fi
    
    # Create function with trigger
    mkdir -p /tmp/gcf-trigger-fix && cd /tmp/gcf-trigger-fix || exit 1
    
    cat > main.py << 'EOF'
def hello_pubsub(event, context):
    """Cloud Function triggered by gcf-topic."""
    import base64
    
    if 'data' in event:
        message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Received message from gcf-topic: {message}')
    else:
        print('No data in event from gcf-topic')
    
    print(f'Event ID: {context.eventId}')
    print(f'Timestamp: {context.timestamp}')
    print(f'Function triggered by messageId {context.eventId} published at {context.timestamp}')
EOF

    echo "functions-framework==3.*" > requirements.txt
    
    # Enable APIs
    echo "🔧 Enabling required APIs..."
    gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com
    
    echo "🚀 Creating function with gcf-topic trigger..."
    
    # Try multiple deployment approaches
    if gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region="$DEPLOY_REGION" \
        --no-gen2 \
        --memory=256MB \
        --timeout=60s \
        --quiet; then
        echo "✅ Function created successfully!"
    elif gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --no-gen2 \
        --memory=256MB \
        --timeout=60s \
        --quiet; then
        echo "✅ Function created successfully (default region)!"
    elif gcloud functions deploy gcf-pubsub \
        --runtime=python39 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region="$DEPLOY_REGION" \
        --no-gen2 \
        --memory=256MB \
        --timeout=60s \
        --quiet; then
        echo "✅ Function created successfully (Python 3.9)!"
    else
        echo "❌ Function deployment failed"
        echo ""
        echo "💡 Manual creation required:"
        echo "1. Go to Cloud Functions in Console"
        echo "2. Create Function"
        echo "3. Set trigger to: Cloud Pub/Sub"
        echo "4. Set topic to: gcf-topic"
        echo "5. Set function name to: gcf-pubsub"
        echo "6. Set entry point to: hello_pubsub"
        echo "7. Use the Python code from main.py above"
        exit 1
    fi
fi

echo ""
echo "🎯 Final Verification:"
echo "=============================="

# Verify function exists
if FUNC_INFO=$(gcloud functions list --filter="name:gcf-pubsub" --format="table(name,region,trigger.eventTrigger.eventType,trigger.eventTrigger.resource)" 2>/dev/null); then
    echo "$FUNC_INFO"
else
    echo "❌ Function verification failed"
fi

echo ""
echo "🔍 Checking trigger specifically:"
FUNCTION_REGION=$(gcloud functions list --filter="name:gcf-pubsub" --format="value(region)" | head -1)
if [[ -n "$FUNCTION_REGION" ]]; then
    TRIGGER_INFO=$(gcloud functions describe gcf-pubsub --region="$FUNCTION_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
    echo "Trigger topic: $TRIGGER_INFO"
    
    if [[ "$TRIGGER_INFO" == *"gcf-topic"* ]]; then
        echo "✅ SUCCESS: Function trigger is correctly set to gcf-topic!"
    else
        echo "⚠️  WARNING: Trigger might not be set to gcf-topic"
    fi
fi

echo ""
echo "🎉 Cloud Function trigger fix completed!"
echo ""
echo "🚀 Test your function:"
echo "gcloud pubsub topics publish gcf-topic --message='Test message'"
