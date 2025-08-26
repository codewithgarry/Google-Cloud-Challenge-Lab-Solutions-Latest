# Google Cloud Speech API: Qwik Start - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Speech API](https://img.shields.io/badge/Speech%20API-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)
![CLI](https://img.shields.io/badge/CLI-000000?style=for-the-badge&logo=gnu-bash&logoColor=white)

**Lab ID**: ARC132 | **Duration**: 10-15 minutes | **Level**: Beginner

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🚀 Complete CLI Solution

Use Speech-to-Text API to transcribe audio files using command-line tools.

---

## ⚡ Quick Start Commands

```bash
# Complete Speech API setup and testing
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME="$PROJECT_ID-speech-samples"

# Enable APIs
gcloud services enable speech.googleapis.com
gcloud services enable storage.googleapis.com

# Create bucket
gsutil mb -l us-central1 gs://$BUCKET_NAME

# Download and upload sample audio
wget -q https://cloud.google.com/speech-to-text/docs/samples/brooklyn.flac
gsutil cp brooklyn.flac gs://$BUCKET_NAME/

# Create request JSON
cat > request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "languageCode": "en-US"
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/brooklyn.flac"
  }
}
EOF

# Transcribe audio
curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @request.json | jq '.results[].alternatives[].transcript'
```

---

## 📋 Step-by-Step CLI Solution

### 🔧 Task 1: Environment Setup

```bash
# Set environment variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"
export BUCKET_NAME="$PROJECT_ID-speech-samples"

echo "🚀 Setting up Speech API for project: $PROJECT_ID"

# Enable required APIs
echo "🔧 Enabling APIs..."
gcloud services enable speech.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Verify APIs are enabled
gcloud services list --enabled --filter="name:(speech.googleapis.com OR storage.googleapis.com)" --format="table(name,title)"

echo "✅ APIs enabled successfully"
```

### 🪣 Task 2: Create Storage Resources

```bash
# Create Cloud Storage bucket
echo "📦 Creating storage bucket..."
gsutil mb -l $REGION gs://$BUCKET_NAME

# Set bucket to be publicly readable (for demo purposes)
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

echo "✅ Storage bucket created: gs://$BUCKET_NAME"

# Verify bucket creation
gsutil ls -b gs://$BUCKET_NAME
```

### 🎵 Task 3: Download and Upload Sample Audio

```bash
# Download sample audio files
echo "📥 Downloading sample audio files..."

# Download FLAC sample
wget -q https://cloud.google.com/speech-to-text/docs/samples/brooklyn.flac
echo "✅ Downloaded brooklyn.flac"

# Download additional samples for testing
wget -q https://cloud.google.com/speech-to-text/docs/samples/hello.wav -O hello.wav
echo "✅ Downloaded hello.wav"

# Upload audio files to bucket
echo "📤 Uploading audio files to bucket..."
gsutil cp brooklyn.flac gs://$BUCKET_NAME/
gsutil cp hello.wav gs://$BUCKET_NAME/

# Make files publicly accessible
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/brooklyn.flac
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/hello.wav

echo "✅ Audio files uploaded and made public"

# Verify uploads
gsutil ls -l gs://$BUCKET_NAME/
```

### 🗣️ Task 4: Test Speech Recognition

```bash
# Create request JSON for FLAC file
echo "🎙️ Creating speech recognition request..."

cat > flac_request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "enableWordTimeOffsets": true
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/brooklyn.flac"
  }
}
EOF

# Test speech recognition with FLAC
echo "🔍 Testing speech recognition with FLAC audio..."
curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @flac_request.json > flac_response.json

# Display results
if [ -s flac_response.json ]; then
    echo "✅ FLAC transcription results:"
    jq -r '.results[].alternatives[].transcript' flac_response.json
    echo ""
    echo "📊 Confidence score:"
    jq -r '.results[].alternatives[].confidence' flac_response.json
else
    echo "❌ No response received for FLAC file"
fi
```

### 🎧 Task 5: Test Different Audio Formats

```bash
# Create request JSON for WAV file
echo "🎵 Testing WAV format..."

cat > wav_request.json << EOF
{
  "config": {
    "encoding": "LINEAR16",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "enableWordTimeOffsets": true,
    "enableWordConfidence": true
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/hello.wav"
  }
}
EOF

# Test speech recognition with WAV
curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @wav_request.json > wav_response.json

# Display WAV results
if [ -s wav_response.json ]; then
    echo "✅ WAV transcription results:"
    jq -r '.results[].alternatives[].transcript' wav_response.json
    echo ""
    echo "📊 Word-level details:"
    jq -r '.results[].alternatives[].words[]? | "\(.word): \(.confidence // "N/A")"' wav_response.json
else
    echo "❌ No response received for WAV file"
fi
```

### 🌐 Task 6: Test Multiple Languages

```bash
# Test with different language settings
echo "🌍 Testing multiple language recognition..."

# Create request for language detection
cat > multilang_request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "alternativeLanguageCodes": ["es-ES", "fr-FR", "de-DE"],
    "languageCode": "en-US",
    "enableWordTimeOffsets": true
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/brooklyn.flac"
  }
}
EOF

# Test multilingual recognition
curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @multilang_request.json > multilang_response.json

# Display language detection results
if [ -s multilang_response.json ]; then
    echo "✅ Language detection results:"
    jq -r '.results[].alternatives[].transcript' multilang_response.json
    echo ""
    echo "🔍 Detected language:"
    jq -r '.results[].languageCode // "Not detected"' multilang_response.json
else
    echo "❌ No response received for multilingual test"
fi
```

### 📈 Task 7: Advanced Features Testing

```bash
# Test with enhanced features
echo "🚀 Testing advanced speech features..."

cat > advanced_request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "enableWordTimeOffsets": true,
    "enableWordConfidence": true,
    "enableAutomaticPunctuation": true,
    "enableSpokenPunctuation": true,
    "enableSpokenEmojis": true,
    "maxAlternatives": 3,
    "profanityFilter": false,
    "speechContexts": [
      {
        "phrases": ["Brooklyn", "New York", "borough"]
      }
    ]
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/brooklyn.flac"
  }
}
EOF

# Test advanced features
curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @advanced_request.json > advanced_response.json

# Display advanced results
if [ -s advanced_response.json ]; then
    echo "✅ Advanced transcription with punctuation:"
    jq -r '.results[].alternatives[].transcript' advanced_response.json
    echo ""
    echo "📊 Alternative transcriptions:"
    jq -r '.results[].alternatives[]? | "Alternative: \(.transcript) (Confidence: \(.confidence // "N/A"))"' advanced_response.json
    echo ""
    echo "⏱️ Word timing information:"
    jq -r '.results[].alternatives[0].words[]? | "\(.word): \(.startTime // "0")s - \(.endTime // "0")s"' advanced_response.json | head -5
else
    echo "❌ No response received for advanced features test"
fi
```

### 🔄 Task 8: Batch Processing

```bash
# Test batch processing with multiple files
echo "📦 Testing batch processing..."

# Create batch request for multiple files
cat > batch_request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "languageCode": "en-US"
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/brooklyn.flac"
  }
}
EOF

# Function to process audio file
process_audio_file() {
    local file_uri=$1
    local output_file=$2
    
    # Create temporary request
    cat > temp_request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "languageCode": "en-US"
  },
  "audio": {
    "uri": "$file_uri"
  }
}
EOF

    # Process file
    curl -s -X POST \
      -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
      -H "Content-Type: application/json" \
      "https://speech.googleapis.com/v1/speech:recognize" \
      -d @temp_request.json > "$output_file"
    
    rm temp_request.json
}

# Process audio files
echo "Processing brooklyn.flac..."
process_audio_file "gs://$BUCKET_NAME/brooklyn.flac" "batch_brooklyn.json"

echo "Processing hello.wav (as FLAC config for demo)..."
# Note: This will likely fail due to format mismatch, which is expected for demonstration
process_audio_file "gs://$BUCKET_NAME/hello.wav" "batch_hello.json"

# Display batch results
echo "✅ Batch processing results:"
if [ -s batch_brooklyn.json ]; then
    echo "Brooklyn.flac result:"
    jq -r '.results[].alternatives[].transcript' batch_brooklyn.json
fi

echo "✅ Batch processing completed"
```

---

## 📊 Monitoring and Analysis

### 📈 Usage Analytics

```bash
# Monitor API usage
echo "📊 Monitoring Speech API usage..."

# Check API quotas
gcloud compute project-info describe --format="yaml(quotas)" | grep -i speech

# View recent API calls
gcloud logging read 'resource.type="api"' \
    --filter='protoPayload.serviceName="speech.googleapis.com"' \
    --limit=10 \
    --format="table(timestamp,protoPayload.methodName,protoPayload.status.code)"

# Get usage statistics
echo "📈 Recent API usage:"
gcloud logging read 'resource.type="api"' \
    --filter='protoPayload.serviceName="speech.googleapis.com"' \
    --limit=5 \
    --format="value(timestamp,protoPayload.methodName)"
```

### 🔍 Response Analysis

```bash
# Analyze all responses
echo "🔍 Analyzing speech recognition results..."

# Create summary of all results
echo "📝 Transcription Summary:"
echo "========================"

for response_file in *_response.json; do
    if [ -s "$response_file" ]; then
        echo "File: $response_file"
        echo "Transcript: $(jq -r '.results[].alternatives[].transcript // "No transcript"' "$response_file")"
        echo "Confidence: $(jq -r '.results[].alternatives[].confidence // "No confidence"' "$response_file")"
        echo "---"
    fi
done

# Calculate average confidence scores
echo "📊 Average confidence calculation:"
CONFIDENCE_SCORES=$(find . -name "*_response.json" -exec jq -r '.results[].alternatives[].confidence // empty' {} \; 2>/dev/null)
if [ -n "$CONFIDENCE_SCORES" ]; then
    echo "$CONFIDENCE_SCORES" | awk '{sum+=$1; count++} END {if(count>0) print "Average confidence:", sum/count; else print "No confidence scores found"}'
else
    echo "No confidence scores available"
fi
```

---

## ✅ Verification Commands

```bash
# Complete verification suite
echo "✅ Running Speech API verification..."

# 1. Verify APIs are enabled
echo "Checking API status..."
SPEECH_API_STATUS=$(gcloud services list --enabled --filter="name:speech.googleapis.com" --format="value(name)")
if [ -n "$SPEECH_API_STATUS" ]; then
    echo "✅ Speech API is enabled"
else
    echo "❌ Speech API not enabled"
fi

# 2. Verify bucket exists
echo "Checking storage bucket..."
if gsutil ls -b gs://$BUCKET_NAME &>/dev/null; then
    echo "✅ Storage bucket exists: gs://$BUCKET_NAME"
else
    echo "❌ Storage bucket not found"
fi

# 3. Verify audio files exist
echo "Checking audio files..."
AUDIO_FILES=$(gsutil ls gs://$BUCKET_NAME/*.flac gs://$BUCKET_NAME/*.wav 2>/dev/null | wc -l)
if [ "$AUDIO_FILES" -gt 0 ]; then
    echo "✅ Audio files uploaded: $AUDIO_FILES files found"
else
    echo "❌ No audio files found in bucket"
fi

# 4. Verify API responses
echo "Checking API responses..."
RESPONSE_FILES=$(ls *_response.json 2>/dev/null | wc -l)
if [ "$RESPONSE_FILES" -gt 0 ]; then
    echo "✅ API responses received: $RESPONSE_FILES response files"
else
    echo "❌ No API response files found"
fi

# 5. Test API accessibility
echo "Testing API accessibility..."
API_TEST=$(curl -s -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
    "https://speech.googleapis.com/v1/operations" | jq -r '.operations // empty' 2>/dev/null)
if [ "$?" -eq 0 ]; then
    echo "✅ Speech API is accessible"
else
    echo "❌ Speech API access issue"
fi

echo "🎉 Verification completed!"
```

---

## 🔧 Troubleshooting Commands

```bash
# Speech API troubleshooting toolkit
echo "🔧 Speech API troubleshooting..."

# Check authentication
echo "Checking authentication..."
gcloud auth list --format="table(account,status)"

# Verify project configuration
echo "Project configuration:"
gcloud config list --format="table(core.project,core.account)"

# Test API key (if using API key instead of OAuth)
# export API_KEY="your-api-key"
# curl -s "https://speech.googleapis.com/v1/operations?key=$API_KEY"

# Check audio file formats
echo "Checking audio file properties..."
if command -v ffprobe &> /dev/null; then
    for audio_file in *.flac *.wav; do
        if [ -f "$audio_file" ]; then
            echo "File: $audio_file"
            ffprobe -v quiet -show_format -show_streams "$audio_file" | grep -E "(codec_name|sample_rate|channels)"
            echo "---"
        fi
    done
else
    echo "ffprobe not available for audio analysis"
fi

# Validate JSON requests
echo "Validating JSON request files..."
for json_file in *_request.json; do
    if [ -f "$json_file" ]; then
        echo "Validating $json_file..."
        if jq empty "$json_file" 2>/dev/null; then
            echo "✅ $json_file is valid JSON"
        else
            echo "❌ $json_file has JSON syntax errors"
        fi
    fi
done

# Clean up temporary files
echo "Cleaning up temporary files..."
rm -f temp_request.json *.json *.flac *.wav
echo "✅ Cleanup completed"
```

---

## 📚 Reference Commands

```bash
# Useful Speech API CLI commands

# Basic transcription
curl -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @request.json

# Long-running operation
curl -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:longrunningrecognize" \
  -d @long_request.json

# Check operation status
curl -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  "https://speech.googleapis.com/v1/operations/OPERATION_NAME"

# List supported languages
curl -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  "https://speech.googleapis.com/v1/speech:recognize" | jq '.languageCodes'
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Console-based approach
- **[Automation Solution](Automation-Solution.md)** - Python script automation

---

## 🎖️ Skills Boost Arcade

Complete this CLI challenge for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Use Speech-to-Text API for building voice-enabled applications with CLI automation!

</div>
