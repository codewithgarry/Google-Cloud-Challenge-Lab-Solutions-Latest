#!/bin/bash

# ARC113 Specific Trigger Fix
# Fixes: "Please create a trigger for cloud function gcf-pubsub from gcf-topic topic"

echo "🎯 ARC113 Trigger Fix - Specific Error Resolution"
echo "================================================="
echo ""
echo "Error: 'Please create a trigger for cloud function gcf-pubsub from gcf-topic topic'"
echo "Solution: Reconfigure the function trigger properly"
echo ""

# Find the function region
echo "🔍 Locating gcf-pubsub function..."
FUNC_REGION=""
for region in "us-east1" "us-central1" "us-west1" "europe-west1" "asia-east1"; do
    if gcloud functions describe gcf-pubsub --region="$region" &>/dev/null; then
        FUNC_REGION="$region"
        echo "✅ Found function 'gcf-pubsub' in region: $region"
        break
    fi
done

if [[ -z "$FUNC_REGION" ]]; then
    echo "❌ Function 'gcf-pubsub' not found in any region"
    echo "🚀 Creating function with proper trigger..."
    
    # Create function with proper trigger
    mkdir -p /tmp/trigger-fix && cd /tmp/trigger-fix || exit 1
    
    cat > main.py << 'EOF'
def hello_pubsub(event, context):
    """Background Cloud Function to be triggered by Pub/Sub.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    import base64
    import json
    
    print(f'This Function was triggered by messageId {context.eventId} published at {context.timestamp}')
    
    if 'data' in event:
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Data: {pubsub_message}')
    else:
        print('No data in event')
EOF

    cat > requirements.txt << 'EOF'
functions-framework==3.*
EOF

    # Deploy to us-east1 (most common for labs)
    echo "🚀 Deploying function with gcf-topic trigger to us-east1..."
    if gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region=us-east1 \
        --no-gen2 \
        --memory=256MB \
        --timeout=60s; then
        echo "✅ Function created successfully!"
        FUNC_REGION="us-east1"
    else
        echo "❌ Function deployment failed"
        exit 1
    fi
else
    echo ""
    echo "🔧 Function exists, fixing trigger configuration..."
    
    # Get current trigger info
    CURRENT_TRIGGER=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
    echo "Current trigger: $CURRENT_TRIGGER"
    
    # Always redeploy to ensure proper trigger configuration
    echo "🔄 Redeploying function with correct gcf-topic trigger..."
    
    # Create proper function code
    mkdir -p /tmp/trigger-fix && cd /tmp/trigger-fix || exit 1
    
    cat > main.py << 'EOF'
def hello_pubsub(event, context):
    """Background Cloud Function to be triggered by Pub/Sub.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    import base64
    import json
    
    print(f'This Function was triggered by messageId {context.eventId} published at {context.timestamp}')
    
    if 'data' in event:
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Data: {pubsub_message}')
    else:
        print('No data in event')
EOF

    cat > requirements.txt << 'EOF'
functions-framework==3.*
EOF

    # Redeploy with explicit trigger configuration
    if gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region="$FUNC_REGION" \
        --no-gen2 \
        --memory=256MB \
        --timeout=60s \
        --update-build-env-vars=''  \
        --clear-env-vars; then
        echo "✅ Function trigger fixed successfully!"
    else
        echo "⚠️  Redeploy failed, trying alternative approach..."
        
        # Try with Gen2
        if gcloud functions deploy gcf-pubsub \
            --runtime=python311 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --region="$FUNC_REGION" \
            --gen2 \
            --memory=512Mi \
            --timeout=60s; then
            echo "✅ Function trigger fixed with Gen2!"
        else
            echo "❌ All deployment attempts failed"
            exit 1
        fi
    fi
fi

echo ""
echo "🔍 Verifying trigger configuration..."

# Verify the trigger is properly set
FINAL_TRIGGER=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
TRIGGER_TYPE=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(eventTrigger.eventType)" 2>/dev/null)

echo "Function Region: $FUNC_REGION"
echo "Trigger Type: $TRIGGER_TYPE"
echo "Trigger Resource: $FINAL_TRIGGER"

if [[ "$FINAL_TRIGGER" == *"gcf-topic"* ]] && [[ "$TRIGGER_TYPE" == *"pubsub"* ]]; then
    echo "✅ SUCCESS: Trigger is correctly configured!"
    echo "   - Function: gcf-pubsub"
    echo "   - Trigger Type: Cloud Pub/Sub"
    echo "   - Topic: gcf-topic"
else
    echo "❌ WARNING: Trigger may still not be configured correctly"
    echo "Expected: Topic containing 'gcf-topic'"
    echo "Actual: $FINAL_TRIGGER"
fi

echo ""
echo "🧪 Testing the trigger..."

# Test the function
echo "Publishing test message to gcf-topic..."
if gcloud pubsub topics publish gcf-topic --message="Trigger test message"; then
    echo "✅ Test message published successfully"
    
    echo "⏱️  Waiting 15 seconds for function execution..."
    sleep 15
    
    echo "📋 Checking function logs..."
    gcloud functions logs read gcf-pubsub --region="$FUNC_REGION" --limit=3 --format="value(timestamp,textPayload)" 2>/dev/null | head -10
else
    echo "⚠️  Could not publish test message (topic might not exist yet)"
fi

echo ""
echo "🎯 Final Status Check:"
echo "======================"

# Final verification
if gcloud functions describe gcf-pubsub --region="$FUNC_REGION" &>/dev/null; then
    echo "✅ Function 'gcf-pubsub' exists and is accessible"
    
    # Show function details in table format
    echo ""
    echo "Function Details:"
    gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="table(name,status,trigger.eventTrigger.eventType,trigger.eventTrigger.resource)"
    
else
    echo "❌ Function verification failed"
fi

echo ""
echo "🎉 Trigger fix completed!"
echo ""
echo "💡 If the lab still doesn't recognize the trigger:"
echo "   1. Wait 2-3 minutes for validation to refresh"
echo "   2. Try refreshing the lab page"
echo "   3. Check that gcf-topic exists: gcloud pubsub topics describe gcf-topic"
echo "   4. Verify function logs show message processing"
echo ""
echo "🔗 Manual verification commands:"
echo "   gcloud functions describe gcf-pubsub --region=$FUNC_REGION"
echo "   gcloud pubsub topics publish gcf-topic --message='Test'"
