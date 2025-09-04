#!/bin/bash

# ARC113 Org Policy Workaround Script
# Specifically addresses organization policy constraint issues

echo "🔧 ARC113 Organization Policy Workaround"
echo "========================================"
echo ""

# Check which regions are allowed
echo "🔍 Checking allowed regions..."

# Function to check if a region is allowed
check_region() {
    local region=$1
    echo "Testing $region..."
    
    # Try to list functions in the region (this will fail if region is blocked)
    if gcloud functions list --regions=$region &>/dev/null; then
        echo "✅ $region is allowed"
        return 0
    else
        echo "❌ $region is blocked"
        return 1
    fi
}

# Test common regions
ALLOWED_REGIONS=()

for region in "us-central1" "us-east1" "us-west1" "europe-west1" "europe-west2" "asia-east1"; do
    if check_region "$region"; then
        ALLOWED_REGIONS+=("$region")
    fi
done

echo ""
echo "📍 Allowed regions: ${ALLOWED_REGIONS[*]}"
echo ""

if [ ${#ALLOWED_REGIONS[@]} -eq 0 ]; then
    echo "⚠️  No regions seem to be allowed for Cloud Functions"
    echo "💡 Alternative approaches:"
    echo ""
    echo "Option 1: Create function manually in Console"
    echo "1. Go to Cloud Functions in the Console"
    echo "2. Create Function"
    echo "3. Use these settings:"
    echo "   - Name: gcf-pubsub"
    echo "   - Trigger: Cloud Pub/Sub"
    echo "   - Topic: gcf-topic"
    echo "   - Runtime: Python 3.9 or 3.11"
    echo "   - Entry point: hello_pubsub"
    echo ""
    echo "Option 2: Check if 2nd gen is allowed"
    echo "Try this command:"
    echo 'gcloud functions deploy gcf-pubsub --gen2 --runtime=python311 --trigger-topic=gcf-topic --entry-point=hello_pubsub'
    echo ""
    exit 1
fi

echo "🚀 Deploying function to first allowed region: ${ALLOWED_REGIONS[0]}"
echo ""

# Prepare function code
mkdir -p /tmp/gcf-orgpolicy && cd /tmp/gcf-orgpolicy || exit 1

cat > main.py << 'EOF'
def hello_pubsub(event, context):
    """Cloud Function triggered by Pub/Sub."""
    import base64
    
    if 'data' in event:
        message = base64.b64decode(event['data']).decode('utf-8')
        print(f'Received message: {message}')
    else:
        print('No data in event')
    
    print(f'Event ID: {context.eventId}')
    print(f'Timestamp: {context.timestamp}')
EOF

echo "functions-framework==3.*" > requirements.txt

# Deploy to first allowed region
DEPLOY_REGION=${ALLOWED_REGIONS[0]}

echo "Deploying to $DEPLOY_REGION..."

if gcloud functions deploy gcf-pubsub \
    --runtime=python311 \
    --trigger-topic=gcf-topic \
    --entry-point=hello_pubsub \
    --region="$DEPLOY_REGION" \
    --no-gen2 \
    --memory=256MB \
    --timeout=60s; then
    echo ""
    echo "✅ Function deployed successfully in $DEPLOY_REGION!"
else
    echo ""
    echo "⚠️  Gen1 deployment failed, trying Gen2..."
    
    if gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region="$DEPLOY_REGION" \
        --gen2 \
        --memory=256Mi \
        --timeout=60s; then
        echo "✅ Function deployed successfully with Gen2 in $DEPLOY_REGION!"
    else
        echo "❌ Both Gen1 and Gen2 failed"
        echo ""
        echo "💡 Manual creation required:"
        echo "1. Open Cloud Console"
        echo "2. Navigate to Cloud Functions"
        echo "3. Create function with:"
        echo "   - Name: gcf-pubsub"
        echo "   - Trigger: Pub/Sub topic 'gcf-topic'"
        echo "   - Runtime: Python 3.11"
        echo "   - Entry point: hello_pubsub"
        echo "   - Source code: Copy from main.py above"
    fi
fi

echo ""
echo "🎯 Verification:"
echo "gcloud functions list --filter='name:gcf-pubsub'"
echo ""
echo "🎉 Organization policy workaround completed!"
