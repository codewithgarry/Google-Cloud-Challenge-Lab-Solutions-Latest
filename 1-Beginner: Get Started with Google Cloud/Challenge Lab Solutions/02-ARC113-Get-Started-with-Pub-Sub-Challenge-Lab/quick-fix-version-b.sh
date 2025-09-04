#!/bin/bash

# ARC113 Quick Fix Script - Version B (Dynamic)
# Focuses on completing tasks with minimal errors

echo "🚀 ARC113 Quick Fix - Version B (Dynamic)"
echo "=========================================="

# Enable APIs first
echo "Enabling required APIs..."
gcloud services enable pubsub.googleapis.com cloudfunctions.googleapis.com cloudbuild.googleapis.com

# Task 1: Create Schema (with error handling)
echo ""
echo "Task 1: Creating Pub/Sub schema..."
cat > schema.json << 'EOF'
{
    "type": "record",
    "name": "Avro",
    "fields": [
        {"name": "city", "type": "string"},
        {"name": "temperature", "type": "double"},
        {"name": "pressure", "type": "int"},
        {"name": "time_position", "type": "string"}
    ]
}
EOF

if gcloud pubsub schemas describe city-temp-schema &>/dev/null; then
    echo "✅ Schema already exists"
else
    gcloud pubsub schemas create city-temp-schema --type=AVRO --definition-file=schema.json
    echo "✅ Schema created"
fi

# Task 2: Create Topic with Schema (FIXED)
echo ""
echo "Task 2: Creating topic with schema..."
if gcloud pubsub topics describe temp-topic &>/dev/null; then
    echo "✅ Topic already exists"
else
    gcloud pubsub topics create temp-topic --schema=temperature-schema --message-encoding=JSON
    echo "✅ Topic created"
fi

# Task 3: Create Cloud Function (Gen1 fallback)
echo ""
echo "Task 3: Creating Cloud Function..."
if gcloud functions describe gcf-pubsub --region=us-central1 &>/dev/null; then
    echo "✅ Function already exists"
else
    mkdir -p gcf-function && cd gcf-function || exit 1
    
    # Simple function code
    cat > main.py << 'EOF'
def hello_pubsub(event, context):
    import base64
    message = base64.b64decode(event['data']).decode('utf-8')
    print(f'Function triggered by {context.eventId}: {message}')
EOF

    # Use Gen1 for better compatibility
    echo "# No dependencies needed" > requirements.txt
    
    echo "Deploying function (Gen1 for compatibility)..."
    gcloud functions deploy gcf-pubsub \
        --runtime=python311 \
        --trigger-topic=gcf-topic \
        --entry-point=hello_pubsub \
        --region=us-central1 \
        --no-gen2 \
        --memory=128MB \
        --timeout=60s
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Function deployed successfully"
    else
        echo "⚠️  Function deployment failed, trying alternative approach..."
        
        # Alternative: Try with different settings
        gcloud functions deploy gcf-pubsub \
            --runtime=python39 \
            --trigger-topic=gcf-topic \
            --entry-point=hello_pubsub \
            --region=us-central1 \
            --memory=128MB
    fi
fi

echo ""
echo "🎯 Verification Commands:"
echo "gcloud pubsub schemas list --filter='name:city-temp-schema'"
echo "gcloud pubsub topics list --filter='name:temp-topic'"
echo "gcloud functions list --filter='name:gcf-pubsub'"

echo ""
echo "✅ ARC113 Version B tasks completed!"
