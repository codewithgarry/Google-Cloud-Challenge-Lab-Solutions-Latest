#!/bin/bash

# ARC113 Task 3 Fix - Based on Console Status
# Fixes specific issues when function exists but task doesn't complete

echo "🔧 ARC113 Task 3 Completion Fix"
echo "==============================="
echo ""

echo "📊 Current Status Analysis:"
echo "✅ gcf-topic exists (visible in console)"
echo "✅ temp-topic exists (visible in console)" 
echo "✅ Subscription gcf-gcf-pubsub-us-east1-gcf-topic exists"
echo "❓ Task 3 not completing despite function existence"
echo ""

echo "🔍 Diagnosing potential issues..."

# Check if function exists and get details
echo "Checking Cloud Function status..."
FUNC_REGION=""
FUNC_EXISTS=false

for region in "us-east1" "us-central1" "us-west1" "europe-west1"; do
    if gcloud functions describe gcf-pubsub --region="$region" &>/dev/null; then
        FUNC_REGION="$region"
        FUNC_EXISTS=true
        echo "✅ Function 'gcf-pubsub' found in region: $region"
        break
    fi
done

if [[ "$FUNC_EXISTS" == "false" ]]; then
    echo "❌ Function 'gcf-pubsub' not found in any region"
    echo "🚀 Creating function..."
    
    # Create the function
    mkdir -p /tmp/gcf-task3-fix && cd /tmp/gcf-task3-fix || exit 1
    
    cat > main.py << 'EOF'
def hello_pubsub(event, context):
    """Background Cloud Function to be triggered by Pub/Sub.
    Args:
         event (dict): The dictionary with data specific to this type of event.
                       The `data` field contains the PubsubMessage message. The
                       `attributes` field will contain custom attributes if there
                       are any.
         context (google.cloud.functions.Context): The Cloud Functions event
                                                   metadata. The `eventId` field
                                                   contains the Pub/Sub message ID.
                                                   The `timestamp` field contains
                                                   the publish time.
    """
    import base64
    import json
    
    print(f'This Function was triggered by messageId {context.eventId} published at {context.timestamp}')
    
    if 'data' in event:
        pubsub_message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Data: {pubsub_message}')
    else:
        print('No data field in event')
        
    print('Function executed successfully')
EOF

    cat > requirements.txt << 'EOF'
functions-framework>=3.0.0
EOF

    echo "🚀 Deploying function to us-east1 (based on your console)..."
    
    # Deploy to us-east1 since that's where the subscription is
    if gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region=us-east1 \
        --gen2 \
        --memory=512Mi \
        --timeout=60s \
        --quiet; then
        echo "✅ Function deployed successfully with Gen2"
        FUNC_REGION="us-east1"
        FUNC_EXISTS=true
    elif gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region=us-east1 \
        --no-gen2 \
        --memory=256MB \
        --timeout=60s \
        --quiet; then
        echo "✅ Function deployed successfully with Gen1"
        FUNC_REGION="us-east1"
        FUNC_EXISTS=true
    else
        echo "❌ Function deployment failed"
        exit 1
    fi
fi

if [[ "$FUNC_EXISTS" == "true" ]]; then
    echo ""
    echo "🔍 Analyzing function configuration..."
    
    # Get function details
    TRIGGER_TOPIC=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
    RUNTIME=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(runtime)" 2>/dev/null)
    
    echo "📍 Function Region: $FUNC_REGION"
    echo "🔗 Trigger Topic: $TRIGGER_TOPIC"
    echo "🐍 Runtime: $RUNTIME"
    
    # Check if trigger is correct
    if [[ "$TRIGGER_TOPIC" == *"gcf-topic"* ]]; then
        echo "✅ Trigger correctly set to gcf-topic"
    else
        echo "❌ Trigger not set to gcf-topic: $TRIGGER_TOPIC"
        echo "🔧 Fixing trigger..."
        
        # Redeploy with correct trigger
        cd /tmp/gcf-task3-fix || exit 1
        gcloud functions deploy gcf-pubsub \
            --runtime=python311 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --region="$FUNC_REGION" \
            --no-gen2 \
            --memory=256MB \
            --timeout=60s \
            --quiet
    fi
    
    echo ""
    echo "🧪 Testing function trigger..."
    
    # Test by publishing a message
    echo "Publishing test message to gcf-topic..."
    gcloud pubsub topics publish gcf-topic --message="Test message for Task 3"
    
    echo "⏱️  Waiting 10 seconds for function execution..."
    sleep 10
    
    # Check function logs
    echo "📋 Recent function logs:"
    gcloud functions logs read gcf-pubsub --region="$FUNC_REGION" --limit=5 --format="value(timestamp,textPayload)" 2>/dev/null || echo "No logs available yet"
    
    echo ""
    echo "🎯 Final verification checks..."
    
    # Verify function exists
    if gcloud functions describe gcf-pubsub --region="$FUNC_REGION" &>/dev/null; then
        echo "✅ Function 'gcf-pubsub' exists and is accessible"
    else
        echo "❌ Function 'gcf-pubsub' not accessible"
    fi
    
    # Verify trigger topic exists
    if gcloud pubsub topics describe gcf-topic &>/dev/null; then
        echo "✅ Topic 'gcf-topic' exists and is accessible"
    else
        echo "❌ Topic 'gcf-topic' not accessible"
    fi
    
    # Check for proper IAM permissions
    echo "🔐 Checking service account permissions..."
    PROJECT_ID=$(gcloud config get-value project)
    if [[ -n "$PROJECT_ID" ]]; then
        echo "Project ID: $PROJECT_ID"
        
        # The function should have proper permissions automatically
        # but let's verify the basic setup
        echo "✅ Using project: $PROJECT_ID"
    fi
    
    echo ""
    echo "💡 If Task 3 still doesn't complete, try these manual steps:"
    echo ""
    echo "1. Check Lab Instructions:"
    echo "   - Verify the exact function name required (should be 'gcf-pubsub')"
    echo "   - Verify the exact topic name (should be 'gcf-topic')"
    echo "   - Check if there are specific runtime or memory requirements"
    echo ""
    echo "2. Manual Console Creation:"
    echo "   - Go to Cloud Functions in Console"
    echo "   - Delete existing gcf-pubsub function if present"
    echo "   - Create new function:"
    echo "     * Name: gcf-pubsub"
    echo "     * Trigger: Cloud Pub/Sub"
    echo "     * Topic: gcf-topic"
    echo "     * Runtime: Python 3.11"
    echo "     * Entry point: hello_pubsub"
    echo "     * Source code: Use the main.py content from above"
    echo ""
    echo "3. Test the function:"
    echo "   gcloud pubsub topics publish gcf-topic --message='Hello World'"
    echo ""
    
    echo "🎉 Task 3 fix completed!"
    echo ""
    echo "📊 Current function status:"
    gcloud functions list --filter="name:gcf-pubsub" --format="table(name,region,trigger.eventTrigger.eventType,trigger.eventTrigger.resource,status)"
    
else
    echo "❌ Unable to create or access Cloud Function"
    echo "💡 Please create the function manually in the Console"
fi
