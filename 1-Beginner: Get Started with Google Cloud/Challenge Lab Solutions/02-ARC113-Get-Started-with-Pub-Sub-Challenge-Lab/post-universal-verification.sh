#!/bin/bash

# ARC113 Post-Universal-Solver Verification
# Run this after the Universal Auto-Solver to verify trigger configuration

echo "🔍 ARC113 Post-Universal-Solver Verification"
echo "============================================"
echo ""

# Enhanced function detection
FUNC_REGION=""
echo "🔍 Detecting Cloud Function region..."

# Method 1: Check common regions
for region in "us-east1" "us-central1" "us-west1" "europe-west1" "asia-east1"; do
    if gcloud functions describe gcf-pubsub --region="$region" &>/dev/null; then
        FUNC_REGION="$region"
        echo "✅ Found function 'gcf-pubsub' in region: $region"
        break
    fi
done

# Method 2: Alternative detection
if [[ -z "$FUNC_REGION" ]]; then
    echo "Trying alternative detection method..."
    FUNC_REGION=$(gcloud functions list --format="value(name,region)" 2>/dev/null | grep "gcf-pubsub" | cut -d$'\t' -f2 | head -1)
    if [[ -n "$FUNC_REGION" ]]; then
        echo "✅ Found function in region: $FUNC_REGION"
    fi
fi

if [[ -z "$FUNC_REGION" ]]; then
    echo "❌ Function 'gcf-pubsub' not found"
    echo "💡 Run the Universal Auto-Solver first or create the function manually"
    exit 1
fi

echo ""
echo "🔍 Verifying trigger configuration..."

# Get trigger details
TRIGGER_RESOURCE=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(eventTrigger.resource)" 2>/dev/null)
TRIGGER_TYPE=$(gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="value(eventTrigger.eventType)" 2>/dev/null)

echo "Function: gcf-pubsub"
echo "Region: $FUNC_REGION"
echo "Trigger Type: $TRIGGER_TYPE"
echo "Trigger Resource: $TRIGGER_RESOURCE"

if [[ "$TRIGGER_RESOURCE" == *"gcf-topic"* ]] && [[ "$TRIGGER_TYPE" == *"pubsub"* ]]; then
    echo "✅ SUCCESS: Trigger is correctly configured!"
    echo ""
    
    # Test with schema-compliant message
    echo "🧪 Testing trigger with schema-compliant message..."
    
    TOPIC_SCHEMA=$(gcloud pubsub topics describe gcf-topic --format="value(schemaSettings.schema)" 2>/dev/null)
    
    if [[ -n "$TOPIC_SCHEMA" ]]; then
        echo "Topic has schema: $TOPIC_SCHEMA"
        
        cat > /tmp/verification_test.json << 'EOF'
{
  "city": "VerificationTest",
  "temperature": 24.5,
  "pressure": 1014,
  "time_position": "2025-09-04T16:00:00Z"
}
EOF
        
        echo "Publishing schema-compliant test message..."
        if gcloud pubsub topics publish gcf-topic --message="$(cat /tmp/verification_test.json)"; then
            echo "✅ Test message published successfully"
        else
            echo "⚠️  Schema validation failed (normal for some configurations)"
        fi
    else
        echo "No schema detected, publishing simple test..."
        gcloud pubsub topics publish gcf-topic --message="Verification test message"
    fi
    
    echo ""
    echo "⏱️  Waiting 10 seconds for function execution..."
    sleep 10
    
    echo "📋 Recent function logs:"
    gcloud functions logs read gcf-pubsub --region="$FUNC_REGION" --limit=3 2>/dev/null || echo "Logs not available yet"
    
    echo ""
    echo "🎉 Verification completed! Function trigger is properly configured."
    
else
    echo "❌ WARNING: Trigger may not be configured correctly"
    echo "Expected: Resource containing 'gcf-topic' and Type containing 'pubsub'"
    echo "Actual Resource: $TRIGGER_RESOURCE"
    echo "Actual Type: $TRIGGER_TYPE"
    echo ""
    echo "🔧 Quick fix options:"
    echo "1. Run the specific trigger fix script"
    echo "2. Run the ultimate trigger fix script"
    echo "3. Redeploy manually with correct trigger"
fi

echo ""
echo "📊 Complete function status:"
gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="table(name,status,trigger.eventTrigger.eventType,trigger.eventTrigger.resource)" 2>/dev/null || echo "Could not retrieve function details"
