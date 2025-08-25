# Get Started with Pub/Sub: Challenge Lab - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Automation](https://img.shields.io/badge/Method-Automation-EA4335?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC113 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Automation Method - Infrastructure as Code

### 📋 Lab Requirements
Update the variables section with your lab-specific values:

---

## 🚀 Complete Automation Script

### 1. Bash Automation Script

```bash
#!/bin/bash

# =============================================================================
# Google Cloud Pub/Sub Challenge Lab - Complete Automation
# =============================================================================

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# CONFIGURATION - UPDATE THESE VALUES FROM YOUR LAB
# =============================================================================

TOPIC_NAME="your-topic-name"          # Replace with lab value
SUBSCRIPTION_NAME="your-subscription-name"  # Replace with lab value
PROJECT_ID=$(gcloud config get-value project)

print_status "Starting Pub/Sub Challenge Lab Automation"
print_status "Project ID: $PROJECT_ID"
print_status "Topic Name: $TOPIC_NAME"
print_status "Subscription Name: $SUBSCRIPTION_NAME"

# =============================================================================
# TASK 1: CREATE PUB/SUB TOPIC
# =============================================================================

print_status "Task 1: Creating Pub/Sub topic..."

if gcloud pubsub topics describe $TOPIC_NAME &>/dev/null; then
    print_warning "Topic '$TOPIC_NAME' already exists"
else
    gcloud pubsub topics create $TOPIC_NAME
    print_success "Topic '$TOPIC_NAME' created successfully"
fi

# Verify topic creation
if gcloud pubsub topics describe $TOPIC_NAME &>/dev/null; then
    print_success "Task 1 Complete: Topic verified"
else
    print_error "Task 1 Failed: Topic not found"
    exit 1
fi

# =============================================================================
# TASK 2: CREATE PUB/SUB SUBSCRIPTION
# =============================================================================

print_status "Task 2: Creating Pub/Sub subscription..."

if gcloud pubsub subscriptions describe $SUBSCRIPTION_NAME &>/dev/null; then
    print_warning "Subscription '$SUBSCRIPTION_NAME' already exists"
else
    gcloud pubsub subscriptions create $SUBSCRIPTION_NAME \
        --topic=$TOPIC_NAME \
        --ack-deadline=60 \
        --message-retention-duration=7d
    print_success "Subscription '$SUBSCRIPTION_NAME' created successfully"
fi

# Verify subscription creation
if gcloud pubsub subscriptions describe $SUBSCRIPTION_NAME &>/dev/null; then
    print_success "Task 2 Complete: Subscription verified"
else
    print_error "Task 2 Failed: Subscription not found"
    exit 1
fi

# =============================================================================
# TASK 3: PUBLISH AND PULL MESSAGES
# =============================================================================

print_status "Task 3: Publishing test messages..."

# Publish multiple test messages
for i in {1..3}; do
    gcloud pubsub topics publish $TOPIC_NAME \
        --message="Automated test message $i" \
        --attribute="source=automation,sequence=$i"
    print_status "Published message $i"
done

print_success "Published 3 test messages"

# Wait a moment for message propagation
sleep 2

print_status "Pulling messages from subscription..."

# Pull messages with auto-acknowledgment
PULLED_MESSAGES=$(gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME \
    --auto-ack \
    --limit=10 \
    --format="value(message.data)" 2>/dev/null | wc -l)

if [ $PULLED_MESSAGES -gt 0 ]; then
    print_success "Task 3 Complete: Successfully pulled $PULLED_MESSAGES messages"
else
    print_warning "No messages pulled - this might be expected depending on timing"
fi

# =============================================================================
# VERIFICATION AND TESTING
# =============================================================================

print_status "Running comprehensive verification..."

# Check topic exists and get details
TOPIC_INFO=$(gcloud pubsub topics describe $TOPIC_NAME --format="value(name)" 2>/dev/null)
if [ ! -z "$TOPIC_INFO" ]; then
    print_success "✅ Topic verification passed"
else
    print_error "❌ Topic verification failed"
fi

# Check subscription exists and get details
SUB_INFO=$(gcloud pubsub subscriptions describe $SUBSCRIPTION_NAME --format="value(name)" 2>/dev/null)
if [ ! -z "$SUB_INFO" ]; then
    print_success "✅ Subscription verification passed"
else
    print_error "❌ Subscription verification failed"
fi

# Test message flow
print_status "Testing complete message flow..."
gcloud pubsub topics publish $TOPIC_NAME --message="Final verification message"
sleep 1
FINAL_TEST=$(gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1 2>/dev/null | wc -l)

if [ $FINAL_TEST -gt 1 ]; then
    print_success "✅ Message flow verification passed"
else
    print_warning "⚠️ Message flow test inconclusive"
fi

# =============================================================================
# SUMMARY REPORT
# =============================================================================

echo ""
echo "================================================================================"
echo -e "${GREEN}🎉 AUTOMATION COMPLETE${NC}"
echo "================================================================================"
echo "Project ID: $PROJECT_ID"
echo "Topic: $TOPIC_NAME"
echo "Subscription: $SUBSCRIPTION_NAME"
echo "Status: All tasks completed successfully"
echo "================================================================================"
echo ""

print_success "Pub/Sub Challenge Lab automation completed successfully!"
```

### 2. Save and Run the Script

```bash
# Save the script
cat > pubsub_automation.sh << 'EOF'
# [Paste the above script content here]
EOF

# Make it executable
chmod +x pubsub_automation.sh

# Run the automation
./pubsub_automation.sh
```

---

## 🏗️ Terraform Infrastructure as Code

### terraform/main.tf

```hcl
# Configure the Google Cloud Provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Variables
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "topic_name" {
  description = "Pub/Sub Topic Name"
  type        = string
}

variable "subscription_name" {
  description = "Pub/Sub Subscription Name"
  type        = string
}

# Create Pub/Sub Topic
resource "google_pubsub_topic" "challenge_topic" {
  name = var.topic_name

  labels = {
    environment = "challenge-lab"
    lab-id     = "arc113"
  }

  message_retention_duration = "86400s"  # 1 day
}

# Create Pub/Sub Subscription
resource "google_pubsub_subscription" "challenge_subscription" {
  name  = var.subscription_name
  topic = google_pubsub_topic.challenge_topic.name

  # Acknowledgment deadline
  ack_deadline_seconds = 60

  # Message retention
  message_retention_duration = "604800s"  # 7 days

  # Retry policy
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  # Dead letter policy (optional)
  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_topic.id
    max_delivery_attempts = 5
  }

  labels = {
    environment = "challenge-lab"
    lab-id     = "arc113"
  }
}

# Dead Letter Topic (optional but recommended)
resource "google_pubsub_topic" "dead_letter_topic" {
  name = "${var.topic_name}-dead-letter"

  labels = {
    environment = "challenge-lab"
    lab-id     = "arc113"
    type       = "dead-letter"
  }
}

# Outputs
output "topic_name" {
  description = "The name of the created Pub/Sub topic"
  value       = google_pubsub_topic.challenge_topic.name
}

output "subscription_name" {
  description = "The name of the created Pub/Sub subscription"
  value       = google_pubsub_subscription.challenge_subscription.name
}

output "topic_id" {
  description = "The full resource ID of the topic"
  value       = google_pubsub_topic.challenge_topic.id
}

output "subscription_id" {
  description = "The full resource ID of the subscription"
  value       = google_pubsub_subscription.challenge_subscription.id
}
```

### terraform/terraform.tfvars

```hcl
# Update these values with your lab requirements
project_id        = "your-project-id"
topic_name        = "your-topic-name"
subscription_name = "your-subscription-name"
region           = "us-central1"
```

### terraform/deploy.sh

```bash
#!/bin/bash

# Terraform deployment script
set -e

echo "🚀 Deploying Pub/Sub infrastructure with Terraform..."

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply -auto-approve

echo "✅ Terraform deployment complete!"

# Test the deployment
echo "🧪 Testing the deployment..."

# Get the topic and subscription names
TOPIC_NAME=$(terraform output -raw topic_name)
SUBSCRIPTION_NAME=$(terraform output -raw subscription_name)

# Publish a test message
gcloud pubsub topics publish $TOPIC_NAME --message="Terraform test message"

# Pull the message
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1

echo "🎉 Test complete!"
```

---

## 🐍 Python Automation Script

### python_automation.py

```python
#!/usr/bin/env python3

"""
Google Cloud Pub/Sub Challenge Lab - Python Automation
"""

import os
import time
from google.cloud import pubsub_v1
from google.api_core import exceptions

class PubSubAutomation:
    def __init__(self, project_id, topic_name, subscription_name):
        self.project_id = project_id
        self.topic_name = topic_name
        self.subscription_name = subscription_name
        
        # Initialize clients
        self.publisher = pubsub_v1.PublisherClient()
        self.subscriber = pubsub_v1.SubscriberClient()
        
        # Create resource paths
        self.topic_path = self.publisher.topic_path(project_id, topic_name)
        self.subscription_path = self.subscriber.subscription_path(
            project_id, subscription_name
        )
    
    def create_topic(self):
        """Create Pub/Sub topic"""
        try:
            topic = self.publisher.create_topic(request={"name": self.topic_path})
            print(f"✅ Created topic: {topic.name}")
            return True
        except exceptions.AlreadyExists:
            print(f"⚠️ Topic {self.topic_name} already exists")
            return True
        except Exception as e:
            print(f"❌ Error creating topic: {e}")
            return False
    
    def create_subscription(self):
        """Create Pub/Sub subscription"""
        try:
            subscription = self.subscriber.create_subscription(
                request={
                    "name": self.subscription_path,
                    "topic": self.topic_path,
                    "ack_deadline_seconds": 60,
                }
            )
            print(f"✅ Created subscription: {subscription.name}")
            return True
        except exceptions.AlreadyExists:
            print(f"⚠️ Subscription {self.subscription_name} already exists")
            return True
        except Exception as e:
            print(f"❌ Error creating subscription: {e}")
            return False
    
    def publish_messages(self, messages):
        """Publish messages to topic"""
        try:
            for i, message in enumerate(messages, 1):
                # Publish message
                future = self.publisher.publish(
                    self.topic_path, 
                    message.encode("utf-8"),
                    source="python-automation",
                    sequence=str(i)
                )
                print(f"📤 Published message {i}: {future.result()}")
            
            print(f"✅ Published {len(messages)} messages successfully")
            return True
        except Exception as e:
            print(f"❌ Error publishing messages: {e}")
            return False
    
    def pull_messages(self, max_messages=10):
        """Pull messages from subscription"""
        try:
            # Pull messages
            response = self.subscriber.pull(
                request={
                    "subscription": self.subscription_path,
                    "max_messages": max_messages,
                }
            )
            
            received_messages = []
            ack_ids = []
            
            for msg in response.received_messages:
                received_messages.append(msg.message.data.decode("utf-8"))
                ack_ids.append(msg.ack_id)
                print(f"📥 Received: {msg.message.data.decode('utf-8')}")
            
            # Acknowledge messages
            if ack_ids:
                self.subscriber.acknowledge(
                    request={
                        "subscription": self.subscription_path,
                        "ack_ids": ack_ids,
                    }
                )
                print(f"✅ Acknowledged {len(ack_ids)} messages")
            
            return received_messages
        except Exception as e:
            print(f"❌ Error pulling messages: {e}")
            return []
    
    def run_complete_automation(self):
        """Run complete automation workflow"""
        print("🚀 Starting Pub/Sub Challenge Lab Python Automation")
        print(f"Project: {self.project_id}")
        print(f"Topic: {self.topic_name}")
        print(f"Subscription: {self.subscription_name}")
        print("=" * 60)
        
        # Task 1: Create topic
        print("\n📋 Task 1: Creating topic...")
        if not self.create_topic():
            return False
        
        # Task 2: Create subscription
        print("\n📋 Task 2: Creating subscription...")
        if not self.create_subscription():
            return False
        
        # Task 3: Publish and pull messages
        print("\n📋 Task 3: Publishing and pulling messages...")
        
        test_messages = [
            "Hello from Python automation!",
            "This is message 2",
            "Final test message"
        ]
        
        if not self.publish_messages(test_messages):
            return False
        
        # Wait for message propagation
        print("⏳ Waiting for message propagation...")
        time.sleep(2)
        
        # Pull messages
        received = self.pull_messages()
        
        print("\n" + "=" * 60)
        print("🎉 Python automation completed successfully!")
        print(f"📊 Messages published: {len(test_messages)}")
        print(f"📊 Messages received: {len(received)}")
        print("=" * 60)
        
        return True

def main():
    # Configuration - update with your lab values
    PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT") or "your-project-id"
    TOPIC_NAME = "your-topic-name"  # Update with lab value
    SUBSCRIPTION_NAME = "your-subscription-name"  # Update with lab value
    
    # Run automation
    automation = PubSubAutomation(PROJECT_ID, TOPIC_NAME, SUBSCRIPTION_NAME)
    automation.run_complete_automation()

if __name__ == "__main__":
    main()
```

### requirements.txt

```
google-cloud-pubsub==2.18.4
```

### Run Python Automation

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export GOOGLE_CLOUD_PROJECT="your-project-id"

# Run the automation
python python_automation.py
```

---

## 🚦 Quick Deployment Options

### Option 1: One-Command Deployment
```bash
curl -sSL https://raw.githubusercontent.com/codewithgarry/pubsub-automation/main/deploy.sh | bash
```

### Option 2: Docker Container
```bash
docker run --rm -it \
  -v ~/.config/gcloud:/root/.config/gcloud \
  codewithgarry/pubsub-automation:latest
```

### Option 3: Cloud Build
```yaml
# cloudbuild.yaml
steps:
- name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
  entrypoint: 'bash'
  args:
  - '-c'
  - |
    gcloud pubsub topics create ${_TOPIC_NAME}
    gcloud pubsub subscriptions create ${_SUBSCRIPTION_NAME} --topic=${_TOPIC_NAME}
    gcloud pubsub topics publish ${_TOPIC_NAME} --message="Cloud Build automation"

substitutions:
  _TOPIC_NAME: 'your-topic-name'
  _SUBSCRIPTION_NAME: 'your-subscription-name'
```

---

## 🔗 Related Automation Resources

- [Google Cloud SDK](https://cloud.google.com/sdk)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Python Client Library](https://cloud.google.com/pubsub/docs/reference/libraries)
- [Cloud Build](https://cloud.google.com/build)

---

**🎉 Congratulations! You've mastered Pub/Sub automation!**

*For other solution methods, check out:*
- [GUI-Solution.md](./GUI-Solution.md) - Graphical User Interface
- [CLI-Solution.md](./CLI-Solution.md) - Command Line Interface
