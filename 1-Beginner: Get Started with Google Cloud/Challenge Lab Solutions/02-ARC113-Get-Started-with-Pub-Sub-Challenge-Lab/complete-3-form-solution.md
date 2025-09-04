# ARC113: Complete 3-Form Solution Guide

## 🎯 **Universal Auto-Detection and Execution**

This guide covers **ALL THREE FORMS** of ARC113 Challenge Lab with automatic detection and execution.

---

## 🚀 **Instant Universal Solution**

### **Complete Auto-Solver (All 3 Forms)**
```bash
curl -sSL https://raw.githubusercontent.com/GirishCodeAlchemy/gcp-challenge-labs/main/arc113-complete-solution.sh | bash
```

**What it does:**
- ✅ Automatically detects which of the 3 lab forms you have
- ✅ Executes the correct solution for your specific form
- ✅ Handles all error scenarios and retries
- ✅ Complete in ~2-3 minutes

---

## 📋 **Form Detection Logic**

The auto-solver detects your lab form by checking:

### **Form 1 (Original)**: Publish/View/Snapshot
- **Detection**: Checks if `gcloud-pubsub-topic` exists
- **Tasks**: Create subscription → Publish message → View message → Create snapshot

### **Form 2 (Advanced)**: Schema/Topic/Function  
- **Detection**: Checks if `temperature-schema` or `gcf-topic` exists
- **Tasks**: Create Avro schema → Create topic with schema → Deploy Cloud Function

### **Form 3 (Scheduler)**: Cloud Scheduler Integration
- **Detection**: Checks Cloud Scheduler API availability
- **Tasks**: Set up Pub/Sub → Create scheduled job → Verify automated messages

---

## 📝 **Manual Commands by Form**

### **Form 1: Original (Publish/View/Snapshot)**
```bash
# Task 1: Create subscription and publish message
gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic
gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"

# Task 2: View the message  
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5

# Task 3: Create snapshot
gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
```

### **Form 2: Advanced (Schema/Topic/Function)**
```bash
# Task 1: Create schema
gcloud pubsub schemas create city-temp-schema \
    --type=AVRO \
    --definition='{
        "type": "record",
        "name": "Avro", 
        "fields": [
            {"name": "city", "type": "string"},
            {"name": "temperature", "type": "double"},
            {"name": "pressure", "type": "int"},
            {"name": "time_position", "type": "string"}
        ]
    }'

# Task 2: Create topic with schema
gcloud pubsub topics create temp-topic \
    --message-encoding=JSON \
    --schema=temperature-schema

# Task 3: Create Cloud Function
mkdir gcf-form2 && cd gcf-form2

cat > index.js << 'EOF'
const functions = require('@google-cloud/functions-framework');

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
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

# Deploy function (with retry logic)
gcloud functions deploy gcf-pubsub \
    --gen2 \
    --runtime=nodejs22 \
    --region=us-central1 \
    --source=. \
    --entry-point=helloPubSub \
    --trigger-topic=gcf-topic
```

### **Form 3: Scheduler (Cloud Scheduler Integration)**
```bash
# Task 1: Set up Cloud Pub/Sub
gcloud pubsub topics create cloud-pubsub-topic
gcloud pubsub subscriptions create cloud-pubsub-subscription --topic=cloud-pubsub-topic

# Task 2: Create Cloud Scheduler job
gcloud services enable cloudscheduler.googleapis.com
gcloud scheduler jobs create pubsub cron-scheduler-job \
    --location=us-central1 \
    --schedule="* * * * *" \
    --topic=cloud-pubsub-topic \
    --message-body="Hello World!"

# Task 3: Verify results
sleep 30
gcloud pubsub subscriptions pull cloud-pubsub-subscription --limit 5
```

---

## 🔧 **Troubleshooting Solutions**

### **Cloud Function Deployment Issues (Form 2)**
```bash
# Ultimate trigger fix
curl -sSL https://raw.githubusercontent.com/GirishCodeAlchemy/gcp-challenge-labs/main/ultimate-trigger-fix.sh | bash
```

### **Organization Policy Issues**
```bash
# Region fallback fix
curl -sSL https://raw.githubusercontent.com/GirishCodeAlchemy/gcp-challenge-labs/main/trigger-fix.sh | bash
```

### **Manual Trigger Fix**
```bash
# If function deployment fails, try Gen1
gcloud functions deploy gcf-pubsub \
    --runtime=nodejs20 \
    --region=us-central1 \
    --source=. \
    --entry-point=helloPubSub \
    --trigger-topic=gcf-topic \
    --no-gen2
```

---

## ✅ **Verification Commands**

### **Check Form 1 Completion**
```bash
gcloud pubsub subscriptions list --filter='name:pubsub-subscription-message'
gcloud pubsub snapshots list --filter='name:pubsub-snapshot'
```

### **Check Form 2 Completion**
```bash
gcloud pubsub schemas list --filter='name:city-temp-schema'
gcloud pubsub topics list --filter='name:temp-topic'
gcloud functions list --filter='name:gcf-pubsub'
```

### **Check Form 3 Completion**
```bash
gcloud pubsub topics list --filter='name:cloud-pubsub-topic'
gcloud pubsub subscriptions list --filter='name:cloud-pubsub-subscription'
gcloud scheduler jobs list --location=us-central1 --filter='name:cron-scheduler-job'
```

---

## 🎓 **Key Differences Between Forms**

| Aspect | Form 1 | Form 2 | Form 3 |
|--------|--------|--------|--------|
| **Pre-existing Resources** | `gcloud-pubsub-topic` | `gcf-topic` | None |
| **Main Focus** | Message handling | Schema validation | Automation |
| **Complexity** | Basic | Advanced | Integration |
| **Services Used** | Pub/Sub only | Pub/Sub + Functions | Pub/Sub + Scheduler |
| **Deployment** | None | Cloud Function | Scheduler Job |

---

## 💡 **Pro Tips**

1. **Always use the auto-solver** - it handles all edge cases and retries
2. **Form 2 is most complex** - function deployment can fail due to organization policies
3. **Form 3 requires patience** - scheduled messages take time to appear
4. **Region matters** - some labs restrict deployment regions to specific zones

---

## 🌟 **Success Indicators**

### **Form 1**: ✅ Subscription created ✅ Message published ✅ Snapshot created
### **Form 2**: ✅ Schema created ✅ Topic with schema ✅ Function deployed
### **Form 3**: ✅ Resources created ✅ Scheduler job active ✅ Messages flowing

---

⭐ **Subscribe to [CodeWithGarry](https://www.youtube.com/@CodeWithGarry) for more GCP Challenge Lab solutions!**

🔗 **More Challenge Labs**: Check our repository for 26+ complete solutions!
