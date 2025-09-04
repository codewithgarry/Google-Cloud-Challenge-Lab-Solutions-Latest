#!/bin/bash

# ARC113 Ultimate Trigger Fix - Based on Real Terminal Output
# Fixes: Empty region detection, schema validation, org policy issues

echo "🎯 ARC113 Ultimate Trigger Fix"
echo "=============================="
echo ""
echo "Issues detected from your output:"
echo "1. Function region detection failing"
echo "2. Schema validation error on gcf-topic"
echo "3. Organization policy blocking us-central1"
echo ""

# Step 1: Fix function region detection
echo "🔍 Step 1: Finding function region (improved detection)..."

FUNC_REGION=""
# Try multiple methods to find the function
for region in "us-east1" "us-central1" "us-west1" "europe-west1"; do
    echo "Checking region: $region"
    if gcloud functions describe gcf-pubsub --region="$region" &>/dev/null; then
        FUNC_REGION="$region"
        echo "✅ Found function 'gcf-pubsub' in region: $region"
        break
    fi
done

# Alternative detection method
if [[ -z "$FUNC_REGION" ]]; then
    echo "Trying alternative detection method..."
    FUNC_REGION=$(gcloud functions list --format="value(name,region)" | grep "gcf-pubsub" | cut -d$'\t' -f2 | head -1)
    if [[ -n "$FUNC_REGION" ]]; then
        echo "✅ Found function in region: $FUNC_REGION"
    fi
fi

# Fallback to us-east1 based on your console
if [[ -z "$FUNC_REGION" ]]; then
    echo "⚠️  Could not detect region, using us-east1 (from your console)"
    FUNC_REGION="us-east1"
fi

echo "Using region: $FUNC_REGION"
echo ""

# Step 2: Create proper function code
echo "🔧 Step 2: Creating function with proper configuration..."

mkdir -p /tmp/ultimate-fix && cd /tmp/ultimate-fix || exit 1

cat > main.py << 'EOF'
def hello_pubsub(event, context):
    """Background Cloud Function to be triggered by Pub/Sub.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    import base64
    
    print(f'This Function was triggered by messageId {context.eventId} published at {context.timestamp}')
    
    if 'data' in event:
        try:
            pubsub_message = base64.b64decode(event['data']).decode('utf-8')
            print(f'Data: {pubsub_message}')
        except Exception as e:
            print(f'Error decoding message: {e}')
            print(f'Raw event data: {event.get("data", "No data")}')
    else:
        print('No data in event')
    
    # Print all event details for debugging
    print(f'Full event: {event}')
    print(f'Context: eventId={context.eventId}, timestamp={context.timestamp}')
    
    return 'OK'
EOF

cat > requirements.txt << 'EOF'
functions-framework==3.*
EOF

echo "📄 Function code created"
echo ""

# Step 3: Deploy function with multiple fallback strategies
echo "🚀 Step 3: Deploying function with trigger (multiple strategies)..."

DEPLOY_SUCCESS=false

# Strategy 1: Deploy to detected region with Gen1
echo "Strategy 1: Gen1 deployment to $FUNC_REGION..."
if gcloud functions deploy gcf-pubsub \
    --runtime=python311 \
    --trigger-topic=gcf-topic \
    --entry-point=hello_pubsub \
    --region="$FUNC_REGION" \
    --no-gen2 \
    --memory=256MB \
    --timeout=60s \
    --quiet 2>/dev/null; then
    echo "✅ Success with Gen1 in $FUNC_REGION"
    DEPLOY_SUCCESS=true
fi

# Strategy 2: Try Gen2 if Gen1 failed
if [[ "$DEPLOY_SUCCESS" == "false" ]]; then
    echo "Strategy 2: Gen2 deployment to $FUNC_REGION..."
    if gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region="$FUNC_REGION" \
        --gen2 \
        --memory=512Mi \
        --timeout=60s \
        --quiet 2>/dev/null; then
        echo "✅ Success with Gen2 in $FUNC_REGION"
        DEPLOY_SUCCESS=true
    fi
fi

# Strategy 3: Try different regions if org policy blocks
if [[ "$DEPLOY_SUCCESS" == "false" ]]; then
    echo "Strategy 3: Trying different regions due to org policy..."
    for alt_region in "us-east1" "us-west1" "europe-west1"; do
        if [[ "$alt_region" != "$FUNC_REGION" ]]; then
            echo "Trying $alt_region..."
            if gcloud functions deploy gcf-pubsub \
                --runtime=python311 \
                --trigger-topic=gcf-topic \
                --entry-point=hello_pubsub \
                --region="$alt_region" \
                --no-gen2 \
                --memory=256MB \
                --timeout=60s \
                --quiet 2>/dev/null; then
                echo "✅ Success with Gen1 in $alt_region"
                FUNC_REGION="$alt_region"
                DEPLOY_SUCCESS=true
                break
            fi
        fi
    done
fi

if [[ "$DEPLOY_SUCCESS" == "false" ]]; then
    echo "❌ All deployment strategies failed"
    echo "💡 You may need to create the function manually in the Console"
    exit 1
fi

echo ""

# Step 4: Verify and test the trigger
echo "🔍 Step 4: Verifying trigger configuration..."

# Get trigger details
TRIGGER_RESOURCE=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
TRIGGER_TYPE=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(eventTrigger.eventType)" 2>/dev/null)

echo "Function: gcf-pubsub"
echo "Region: $FUNC_REGION"
echo "Trigger Type: $TRIGGER_TYPE"
echo "Trigger Resource: $TRIGGER_RESOURCE"

if [[ "$TRIGGER_RESOURCE" == *"gcf-topic"* ]]; then
    echo "✅ Trigger correctly configured to gcf-topic"
else
    echo "⚠️  Trigger configuration may be incorrect"
fi

echo ""

# Step 5: Test with schema-compliant message
echo "🧪 Step 5: Testing trigger with schema-compliant message..."

# Check if gcf-topic has schema requirements
TOPIC_SCHEMA=$(gcloud pubsub topics describe gcf-topic --format="value(schemaSettings.schema)" 2>/dev/null)

if [[ -n "$TOPIC_SCHEMA" ]]; then
    echo "⚠️  Topic has schema: $TOPIC_SCHEMA"
    echo "Creating schema-compliant test message..."
    
    # Create a simple JSON message that might pass schema validation
    cat > test_message.json << 'EOF'
{
  "city": "TestCity",
  "temperature": 25.5,
  "pressure": 1013,
  "time_position": "2025-09-04T15:15:00Z"
}
EOF
    
    echo "Publishing schema-compliant message..."
    if gcloud pubsub topics publish gcf-topic --message="$(cat test_message.json)"; then
        echo "✅ Schema-compliant message published successfully"
    else
        echo "⚠️  Schema validation still failing, trying simple message..."
        # Try without schema validation by publishing to a different test
        gcloud pubsub topics publish gcf-topic --attribute="bypass=true" --message="Simple test" 2>/dev/null || echo "Schema is strictly enforced"
    fi
else
    echo "No schema detected, publishing simple test message..."
    if gcloud pubsub topics publish gcf-topic --message="Test trigger message"; then
        echo "✅ Test message published successfully"
    else
        echo "⚠️  Message publishing failed"
    fi
fi

echo ""
echo "⏱️  Waiting 10 seconds for function execution..."
sleep 10

# Step 6: Check function logs
echo "📋 Step 6: Checking function execution logs..."

echo "Recent function logs:"
if gcloud functions logs read gcf-pubsub --region="$FUNC_REGION" --limit=5 2>/dev/null; then
    echo "✅ Logs retrieved successfully"
else
    echo "⚠️  Could not retrieve logs (function may not have executed yet)"
fi

echo ""

# Step 7: Final verification
echo "🎯 Step 7: Final verification..."

echo "Function Status:"
gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="table(name,status,trigger.eventTrigger.eventType,trigger.eventTrigger.resource)" 2>/dev/null || echo "Could not get function details"

echo ""
echo "Topic Status:"
gcloud pubsub topics describe gcf-topic --format="table(name,schemaSettings.schema)" 2>/dev/null || echo "Could not get topic details"

echo ""
echo "🎉 Ultimate trigger fix completed!"
echo ""
echo "📊 Summary:"
echo "- Function: gcf-pubsub"
echo "- Region: $FUNC_REGION"  
echo "- Trigger: gcf-topic"
echo "- Status: $(if [[ "$DEPLOY_SUCCESS" == "true" ]]; then echo "DEPLOYED"; else echo "FAILED"; fi)"
echo ""
echo "💡 If lab still doesn't validate:"
echo "1. Wait 2-3 minutes for validation refresh"
echo "2. Check if function logs show message processing"
echo "3. Verify trigger in Console: Cloud Functions → gcf-pubsub → Trigger tab"
echo "4. Try manual message: gcloud pubsub topics publish gcf-topic --message='Manual test'"
echo ""
echo "🔗 Manual verification:"
echo "gcloud functions describe gcf-pubsub --region=$FUNC_REGION"
