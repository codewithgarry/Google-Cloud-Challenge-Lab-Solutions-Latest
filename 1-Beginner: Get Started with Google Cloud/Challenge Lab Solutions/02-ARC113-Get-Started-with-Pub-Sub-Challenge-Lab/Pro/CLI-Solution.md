# Pro Solutions: CLI Approach

## 💻 Command Line Interface Solutions

Complete CLI-based solutions for ARC113 Challenge Lab with advanced command-line techniques.

### 🎯 CLI Features

- **Single-command execution**
- **Pipeline operations**
- **Advanced shell scripting**
- **Environment integration**
- **Scriptable workflows**

### 🔧 CLI Commands Reference

#### Quick Execution Commands

##### One-Liner Solution
```bash
export TOPIC_NAME="myTopic" && export SUBSCRIPTION_NAME="mySubscription" && export MESSAGE="Hello World" && gcloud pubsub topics create $TOPIC_NAME && gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME && gcloud pubsub topics publish $TOPIC_NAME --message="$MESSAGE" && gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1 && gcloud pubsub snapshots create snapshot-1 --subscription=$SUBSCRIPTION_NAME
```

##### Pipeline Execution
```bash
# Set variables and execute in pipeline
{
  export TOPIC_NAME="myTopic"
  export SUBSCRIPTION_NAME="mySubscription"  
  export MESSAGE="Hello World"
} && {
  gcloud pubsub topics create $TOPIC_NAME
  gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME
  gcloud pubsub topics publish $TOPIC_NAME --message="$MESSAGE"
  gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1
  gcloud pubsub snapshots create snapshot-1 --subscription=$SUBSCRIPTION_NAME
}
```

#### Advanced CLI Techniques

##### Function-Based Approach
```bash
# Define functions for reusability
create_topic() { gcloud pubsub topics create "$1"; }
create_subscription() { gcloud pubsub subscriptions create "$1" --topic="$2"; }
publish_message() { gcloud pubsub topics publish "$1" --message="$2"; }
pull_message() { gcloud pubsub subscriptions pull "$1" --auto-ack --limit=1; }
create_snapshot() { gcloud pubsub snapshots create "$1" --subscription="$2"; }

# Execute functions
create_topic "myTopic"
create_subscription "mySubscription" "myTopic"
publish_message "myTopic" "Hello World"
pull_message "mySubscription"
create_snapshot "snapshot-1" "mySubscription"
```

##### Error Handling Pipeline
```bash
# Advanced error handling with CLI
gcloud pubsub topics create "$TOPIC_NAME" || echo "Topic exists, continuing..."
gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" --topic="$TOPIC_NAME" || echo "Subscription exists, continuing..."
gcloud pubsub topics publish "$TOPIC_NAME" --message="$MESSAGE" && echo "Message published successfully"
gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --auto-ack --limit=1 || echo "No messages or already consumed"
gcloud pubsub snapshots create snapshot-1 --subscription="$SUBSCRIPTION_NAME" || echo "Snapshot exists, continuing..."
```

### 📊 CLI Workflow Patterns

#### Pattern 1: Sequential Execution
```bash
#!/bin/bash
set -e

# Variables
TOPIC_NAME="myTopic"
SUBSCRIPTION_NAME="mySubscription"
MESSAGE="Hello World"

# Sequential execution with error checking
echo "Creating topic..."
gcloud pubsub topics create "$TOPIC_NAME"

echo "Creating subscription..."
gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" --topic="$TOPIC_NAME"

echo "Publishing message..."
gcloud pubsub topics publish "$TOPIC_NAME" --message="$MESSAGE"

echo "Pulling message..."
gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --auto-ack --limit=1

echo "Creating snapshot..."
gcloud pubsub snapshots create snapshot-1 --subscription="$SUBSCRIPTION_NAME"

echo "Lab completed successfully!"
```

#### Pattern 2: Parallel Processing
```bash
#!/bin/bash

# Background jobs for parallel processing
{
  gcloud pubsub topics create "$TOPIC_NAME"
  echo "Topic creation completed"
} &

{
  sleep 2  # Wait for topic creation
  gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" --topic="$TOPIC_NAME"
  echo "Subscription creation completed"
} &

wait  # Wait for all background jobs

# Continue with message operations
gcloud pubsub topics publish "$TOPIC_NAME" --message="$MESSAGE"
gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --auto-ack --limit=1
gcloud pubsub snapshots create snapshot-1 --subscription="$SUBSCRIPTION_NAME"
```

#### Pattern 3: Conditional Execution
```bash
#!/bin/bash

# Check if resources exist before creating
if ! gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
    echo "Creating topic..."
    gcloud pubsub topics create "$TOPIC_NAME"
else
    echo "Topic already exists"
fi

if ! gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
    echo "Creating subscription..."
    gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" --topic="$TOPIC_NAME"
else
    echo "Subscription already exists"
fi

# Always publish message
gcloud pubsub topics publish "$TOPIC_NAME" --message="$MESSAGE"

# Pull message with retry logic
for i in {1..3}; do
    if gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --auto-ack --limit=1; then
        break
    fi
    sleep 1
done

# Create snapshot if it doesn't exist
if ! gcloud pubsub snapshots describe snapshot-1 &>/dev/null; then
    gcloud pubsub snapshots create snapshot-1 --subscription="$SUBSCRIPTION_NAME"
fi
```

### 🎮 Interactive CLI Solutions

#### Interactive Parameter Collection
```bash
#!/bin/bash

# Interactive parameter collection
echo "=== ARC113 CLI Solution ==="
echo ""

read -p "Enter Topic Name: " TOPIC_NAME
read -p "Enter Subscription Name: " SUBSCRIPTION_NAME
read -p "Enter Message: " MESSAGE

# Confirm parameters
echo ""
echo "Configuration:"
echo "Topic: $TOPIC_NAME"
echo "Subscription: $SUBSCRIPTION_NAME"
echo "Message: $MESSAGE"
echo ""

read -p "Proceed? (y/n): " confirm
if [[ $confirm == [yY] ]]; then
    # Execute commands...
    echo "Executing lab solution..."
else
    echo "Operation cancelled"
    exit 1
fi
```

#### Menu-Driven CLI
```bash
#!/bin/bash

show_menu() {
    echo "=== ARC113 CLI Menu ==="
    echo "1. Quick execution (default values)"
    echo "2. Custom parameters"
    echo "3. Verify existing resources"
    echo "4. Cleanup resources"
    echo "5. Exit"
    echo ""
}

while true; do
    show_menu
    read -p "Choose option: " choice
    
    case $choice in
        1) quick_execution ;;
        2) custom_execution ;;
        3) verify_resources ;;
        4) cleanup_resources ;;
        5) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
```

### 🔍 CLI Debugging & Monitoring

#### Verbose Mode
```bash
# Enable verbose output
set -x

# Execute commands with detailed logging
gcloud pubsub topics create "$TOPIC_NAME" --verbosity=debug
gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" --topic="$TOPIC_NAME" --verbosity=debug

# Disable verbose output
set +x
```

#### Resource Monitoring
```bash
# Monitor resource creation
watch -n 2 'gcloud pubsub topics list; echo "---"; gcloud pubsub subscriptions list'

# Check resource details
gcloud pubsub topics describe "$TOPIC_NAME" --format="yaml"
gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="yaml"
```

### ⚡ Performance Optimization

#### Concurrent Operations
```bash
# Use gcloud's built-in concurrency
gcloud config set core/max_concurrent_dispatches 10

# Parallel execution with job control
(gcloud pubsub topics create topic1 &)
(gcloud pubsub topics create topic2 &)
wait
```

#### Batch Operations
```bash
# Create multiple resources efficiently
gcloud pubsub topics create topic1 topic2 topic3

# Use filters for bulk operations
gcloud pubsub subscriptions list --filter="topic:projects/$PROJECT_ID/topics/$TOPIC_NAME"
```

### 📚 CLI Best Practices

1. **Error Handling:** Always include proper error handling
2. **Logging:** Use verbose modes for debugging
3. **Idempotency:** Make scripts safe to run multiple times
4. **Resource Cleanup:** Include cleanup functions
5. **Documentation:** Comment complex command chains

### 🛠️ Custom CLI Tools

#### Create Wrapper Functions
```bash
# ~/.bashrc additions
alias arc113-quick='curl -L https://raw.githubusercontent.com/codewithgarry/solutions/main/arc113-quick.sh | bash'
alias arc113-verify='gcloud pubsub topics list && gcloud pubsub subscriptions list && gcloud pubsub snapshots list'
```

#### CLI Extensions
```bash
# Custom gcloud command extensions
gcloud components install beta alpha

# Use beta features
gcloud beta pubsub topics create "$TOPIC_NAME" --schema=my-schema
```

---

**Pro Tip:** Master these CLI patterns to become highly efficient with Google Cloud operations!
