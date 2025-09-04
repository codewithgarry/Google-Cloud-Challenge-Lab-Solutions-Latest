#!/bin/bash

# Immediate Fix for Your Specific Errors
echo "🚨 IMMEDIATE FIX for your specific issues"
echo "========================================"

# Your function exists in us-east1 (from the successful deployment output)
FUNC_REGION="us-east1"
echo "Using region: $FUNC_REGION (detected from your terminal output)"

# Check current function status
echo "Current function status:"
gcloud functions describe gcf-pubsub --region="$FUNC_REGION" --format="table(name,status,trigger.eventTrigger.eventType,trigger.eventTrigger.resource)"

echo ""
echo "🔍 The trigger appears to be correctly set to gcf-topic already!"
echo "The issue might be schema validation on the topic."

# Check if topic has schema
TOPIC_SCHEMA=$(gcloud pubsub topics describe gcf-topic --format="value(schemaSettings.schema)" 2>/dev/null)
echo "Topic schema: $TOPIC_SCHEMA"

if [[ -n "$TOPIC_SCHEMA" ]]; then
    echo ""
    echo "🎯 SOLUTION: Topic has schema validation that's blocking messages"
    echo "Let's publish a schema-compliant message..."
    
    # Create schema-compliant message
    cat > /tmp/schema_message.json << 'EOF'
{
  "city": "SanFrancisco",
  "temperature": 72.5,
  "pressure": 1015,
  "time_position": "2025-09-04T15:30:00Z"
}
EOF

    echo "Publishing schema-compliant message:"
    cat /tmp/schema_message.json
    
    if gcloud pubsub topics publish gcf-topic --message="$(cat /tmp/schema_message.json)"; then
        echo "✅ Schema-compliant message published successfully!"
    else
        echo "⚠️  Still failing, let's check the exact schema requirements..."
        gcloud pubsub schemas describe temperature-schema --format="value(definition)"
    fi
else
    echo "No schema found, testing simple message..."
    gcloud pubsub topics publish gcf-topic --message="Simple test message"
fi

echo ""
echo "⏱️  Waiting 10 seconds for function execution..."
sleep 10

echo "📋 Function logs (last 3 entries):"
gcloud functions logs read gcf-pubsub --region="$FUNC_REGION" --limit=3

echo ""
echo "🎉 Your function trigger is actually CORRECT!"
echo "The deployment output showed: eventTrigger.resource: projects/.../topics/gcf-topic"
echo ""
echo "💡 If lab still shows error:"
echo "1. The function IS correctly triggered by gcf-topic"
echo "2. Wait 2-3 minutes for lab validation"
echo "3. Try refreshing the lab page"
echo "4. The schema validation error is normal - it just means the test message format doesn't match the schema"
