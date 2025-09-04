#!/bin/bash

# Quick Task 3 Diagnostic and Fix
echo "🔧 Quick Task 3 Fix"
echo "==================="

# Check if function exists in us-east1 (based on your console)
if gcloud functions describe gcf-pubsub --region=us-east1 &>/dev/null; then
    echo "✅ Function exists in us-east1"
    
    # Check trigger
    TRIGGER=$(gcloud functions describe gcf-pubsub --region=us-east1 --format="value(eventTrigger.resource)")
    echo "Current trigger: $TRIGGER"
    
    if [[ "$TRIGGER" == *"gcf-topic"* ]]; then
        echo "✅ Trigger is correct"
        echo "🧪 Testing function with a message..."
        gcloud pubsub topics publish gcf-topic --message="Lab test message"
        echo "✅ Test message published"
    else
        echo "❌ Wrong trigger, fixing..."
        
        # Create temporary directory and files
        mkdir -p /tmp/quick-fix && cd /tmp/quick-fix || exit 1
        
        cat > main.py << 'EOF'
def hello_pubsub(event, context):
    import base64
    print(f'Function triggered by messageId {context.eventId}')
    if 'data' in event:
        message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Data: {message}')
EOF
        
        echo "functions-framework>=3.0.0" > requirements.txt
        
        # Redeploy with correct trigger
        gcloud functions deploy gcf-pubsub \
            --runtime=python311 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --region=us-east1 \
            --no-gen2 \
            --memory=256MB \
            --timeout=60s
    fi
else
    echo "❌ Function not found, creating..."
    
    mkdir -p /tmp/quick-fix && cd /tmp/quick-fix || exit 1
    
    cat > main.py << 'EOF'
def hello_pubsub(event, context):
    import base64
    print(f'Function triggered by messageId {context.eventId}')
    if 'data' in event:
        message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Data: {message}')
EOF
    
    echo "functions-framework>=3.0.0" > requirements.txt
    
    # Deploy to us-east1
    gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region=us-east1 \
        --no-gen2 \
        --memory=256MB \
        --timeout=60s
fi

echo ""
echo "🎯 Verification:"
gcloud functions list --filter="name:gcf-pubsub"
echo ""
echo "🎉 Quick fix completed!"
