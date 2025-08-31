# ARC120 - Advanced Solution Scripts

This directory contains the automated solution scripts for **The Basics of Google Cloud Compute: Challenge Lab**.

## 📁 Directory Structure

```
Pro/solid/
├── arc120-challenge-lab-runner.sh    # Main runner script
├── sci-fi-1/
│   └── task1-create-storage-bucket.sh # Task 1: Create Storage Bucket
├── sci-fi-2/
│   └── task2-create-vm-with-disk.sh   # Task 2: Create VM with Disk
└── sci-fi-3/
    └── task3-install-nginx.sh         # Task 3: Install NGINX
```

## 🚀 Quick Start

**Primary Entry Point**: Use the `2-minutes-solution.md` file in the parent directory for the fastest solution.

**Direct Access**: Run the main script with:
```bash
curl -sL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab/Pro/solid/arc120-challenge-lab-runner.sh | bash
```

## 🎯 Script Features

### Main Runner Script (`arc120-challenge-lab-runner.sh`)
- Interactive menu system
- Downloads and executes individual task scripts
- Option to run all tasks sequentially
- Download-only option for offline execution

### Individual Task Scripts
- **Task 1** (`sci-fi-1/task1-create-storage-bucket.sh`):
  - Creates Cloud Storage bucket
  - Prompts for bucket name and location
  - Validates bucket creation

- **Task 2** (`sci-fi-2/task2-create-vm-with-disk.sh`):
  - Creates VM instance with persistent disk
  - Configurable machine type and disk size
  - Automatic disk attachment

- **Task 3** (`sci-fi-3/task3-install-nginx.sh`):
  - Installs NGINX on VM instance
  - Multiple installation methods
  - Service verification and testing

## 🔧 Technical Details

### Prerequisites
- Google Cloud Shell or environment with gcloud CLI
- Authenticated Google Cloud account
- Project with necessary APIs enabled

### User Input Handling
- All scripts prompt for lab-specific values
- Default values provided for common settings
- Input validation and error handling
- Confirmation prompts before execution

### Error Handling
- Authentication checks
- Project configuration validation
- Resource existence verification
- Rollback capabilities where applicable

## 🛠️ Development Notes

These scripts are designed to be:
- **Idempotent**: Safe to run multiple times
- **Interactive**: Prompt for user-specific values
- **Validated**: Check prerequisites and configurations
- **Documented**: Clear output and progress indicators

## 📋 Usage Patterns

### For Students
- Use the 2-minutes solution for fastest completion
- Run individual tasks for learning purposes
- Download scripts for offline study

### For Instructors
- Demonstrate automation principles
- Show best practices for shell scripting
- Provide examples of error handling

## 🔗 Related Files

- `../../2-minutes-solution.md` - Main entry point
- `../../Challenge-lab-specific-solution.md.md` - Manual solution steps
- `../../README.md` - Lab overview

---

**Author**: CodeWithGarry  
**Lab ID**: ARC120  
**Lab Type**: Challenge Lab  
**Difficulty**: Introductory
