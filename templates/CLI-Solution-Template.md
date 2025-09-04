# CLI Solution - {LAB_NAME}

## Overview
This guide provides command-line instructions for completing the {LAB_ID} challenge lab using gcloud CLI and other command-line tools.

## Prerequisites
- Google Cloud SDK installed and configured
- Appropriate IAM permissions
- Terminal/Command prompt access

## Environment Setup
```bash
# Set project ID
export PROJECT_ID=your-project-id

# Set region and zone
export REGION=us-central1
export ZONE=us-central1-a

# Authenticate
gcloud auth login
gcloud config set project $PROJECT_ID
```

## Command-Line Instructions

### Task 1: [Task Name]
```bash
# Command 1 with explanation
gcloud [service] [action] [parameters]

# Command 2 with explanation  
gcloud [service] [action] [parameters]
```

### Task 2: [Task Name]
```bash
# Detailed CLI commands
gcloud [commands with full parameters]

# Verification command
gcloud [verification command]
```

### Task 3: [Task Name]
```bash
# Complete command sequence
gcloud [service] [action] [parameters]

# Additional configuration
gcloud [configuration commands]
```

## Complete Script
```bash
#!/bin/bash

# Complete automation script
export PROJECT_ID=your-project-id
export REGION=us-central1
export ZONE=us-central1-a

# All commands in sequence
gcloud config set project $PROJECT_ID
# [All commands from tasks above]

echo "Challenge lab completed successfully!"
```

## Verification Commands
```bash
# Verify Task 1
gcloud [verification command]

# Verify Task 2  
gcloud [verification command]

# Verify Task 3
gcloud [verification command]
```

## Troubleshooting
- **Permission Issues**: Ensure proper IAM roles
- **API Issues**: Enable required APIs
- **Resource Issues**: Check quotas and limits

---
*Solution provided by [CodeWithGarry](https://github.com/codewithgarry)*
