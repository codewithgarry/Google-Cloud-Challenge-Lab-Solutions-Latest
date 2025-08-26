# Google Cloud Speech API: Qwik Start - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Speech API](https://img.shields.io/badge/Speech%20API-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)

**Lab ID**: ARC132 | **Duration**: 10-15 minutes | **Level**: Beginner

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Lab Overview

Use Google Cloud Speech-to-Text API to convert audio files to text with high accuracy.

---

## 🧩 Challenge Tasks

1. **Enable Speech API** - Activate Cloud Speech-to-Text API
2. **Create API Key** - Generate authentication credentials
3. **Upload Audio File** - Store sample audio in Cloud Storage
4. **Transcribe Audio** - Convert speech to text using API
5. **Test Different Formats** - Try various audio formats and languages

---

## 🖥️ Step-by-Step GUI Solution

### 📋 Prerequisites
- Google Cloud Console access
- Active Google Cloud project
- Cloud Storage bucket created

---

### 🚀 Task 1: Enable Speech-to-Text API

1. **Open APIs & Services**
   - Navigate to: **APIs & Services** → **Library**
   - Search for: `Cloud Speech-to-Text API`
   - Click **ENABLE**

2. **Enable Additional APIs**
   - Search and enable: `Cloud Storage API`
   - Search and enable: `Cloud Resource Manager API`

3. **Verify API Status**
   - Go to: **APIs & Services** → **Enabled APIs**
   - Confirm Speech-to-Text API is listed

![Enable Speech API](https://via.placeholder.com/600x300/4285F4/FFFFFF?text=Enable+Speech-to-Text+API)

---

### 🔑 Task 2: Create API Key

1. **Generate API Key**
   - Go to: **APIs & Services** → **Credentials**
   - Click **+ CREATE CREDENTIALS**
   - Select **API key**

2. **Secure API Key**
   - Click **RESTRICT KEY**
   - **Key restrictions**: Select **HTTP referrers**
   - **API restrictions**: Select **Restrict key**
   - Choose **Cloud Speech-to-Text API**
   - Click **SAVE**

3. **Copy API Key**
   - Copy the generated API key
   - Store it securely for later use

![Create API Key](https://via.placeholder.com/600x300/34A853/FFFFFF?text=Create+API+Key)

---

### 📦 Task 3: Create Storage Bucket

1. **Open Cloud Storage**
   - Go to: **Navigation Menu** → **Cloud Storage** → **Buckets**
   - Click **CREATE BUCKET**

2. **Configure Bucket**
   - **Name**: `PROJECT_ID-speech-samples`
   - **Location type**: **Region**
   - **Location**: `us-central1`
   - **Storage class**: **Standard**
   - Click **CREATE**

3. **Set Bucket Permissions**
   - Click on bucket name
   - Go to **PERMISSIONS** tab
   - Click **GRANT ACCESS**
   - **New principals**: `allUsers`
   - **Role**: `Storage Object Viewer`
   - Click **SAVE**

![Create Storage Bucket](https://via.placeholder.com/600x300/FF9800/FFFFFF?text=Create+Storage+Bucket)

---

### 🎵 Task 4: Upload Sample Audio File

1. **Download Sample Audio**
   - Open Cloud Shell (top-right corner)
   - Download sample audio file:
   ```bash
   wget https://cloud.google.com/speech-to-text/docs/samples/brooklyn.flac
   ```

2. **Upload to Cloud Storage**
   - In Cloud Storage console, click on your bucket
   - Click **UPLOAD FILES**
   - Select the downloaded `brooklyn.flac` file
   - Click **UPLOAD**

3. **Make File Public**
   - Click on the uploaded file
   - Go to **PERMISSIONS** tab
   - Click **GRANT ACCESS**
   - **New principals**: `allUsers`
   - **Role**: `Storage Object Viewer`
   - Click **SAVE**

4. **Get Public URL**
   - Copy the public URL for the audio file
   - Format: `gs://PROJECT_ID-speech-samples/brooklyn.flac`

![Upload Audio File](https://via.placeholder.com/600x300/9C27B0/FFFFFF?text=Upload+Audio+File)

---

### 🗣️ Task 5: Test Speech-to-Text API

1. **Open API Explorer**
   - Go to: [Google APIs Explorer - Speech-to-Text](https://developers.google.com/apis-explorer/#p/speech/v1/speech.speech.recognize)
   - Or navigate via **APIs & Services** → **Speech-to-Text API** → **TRY THIS API**

2. **Configure Request**
   - **Request body**:
   ```json
   {
     "config": {
       "encoding": "FLAC",
       "sampleRateHertz": 16000,
       "languageCode": "en-US"
     },
     "audio": {
       "uri": "gs://PROJECT_ID-speech-samples/brooklyn.flac"
     }
   }
   ```

3. **Execute Request**
   - Replace `PROJECT_ID` with your actual project ID
   - Click **EXECUTE**
   - Review the transcription results

![Test Speech API](https://via.placeholder.com/600x300/2196F3/FFFFFF?text=Test+Speech-to-Text+API)

---

### 🧪 Task 6: Advanced Testing via REST API

1. **Open Cloud Shell**
   - Click **Activate Cloud Shell**
   - Wait for shell to initialize

2. **Set Environment Variables**
   ```bash
   export PROJECT_ID=$(gcloud config get-value project)
   export API_KEY="YOUR_API_KEY"
   export BUCKET_NAME="$PROJECT_ID-speech-samples"
   ```

3. **Test API with curl**
   ```bash
   curl -s -X POST \
     "https://speech.googleapis.com/v1/speech:recognize?key=$API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "config": {
         "encoding": "FLAC",
         "sampleRateHertz": 16000,
         "languageCode": "en-US"
       },
       "audio": {
         "uri": "gs://'$BUCKET_NAME'/brooklyn.flac"
       }
     }' | python3 -m json.tool
   ```

4. **Review Results**
   - Check the transcription accuracy
   - Note the confidence scores
   - Verify word-level timestamps

![Advanced Testing](https://via.placeholder.com/600x300/607D8B/FFFFFF?text=Advanced+API+Testing)

---

### 🌐 Task 7: Test Different Languages and Formats

1. **Upload Different Audio Formats**
   - Upload additional sample files:
   ```bash
   # Download more samples
   wget https://cloud.google.com/speech-to-text/docs/samples/audio.raw
   wget https://cloud.google.com/speech-to-text/docs/samples/hello.wav
   
   # Upload to bucket
   gsutil cp audio.raw gs://$BUCKET_NAME/
   gsutil cp hello.wav gs://$BUCKET_NAME/
   ```

2. **Test WAV Format**
   ```bash
   curl -s -X POST \
     "https://speech.googleapis.com/v1/speech:recognize?key=$API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "config": {
         "encoding": "LINEAR16",
         "sampleRateHertz": 16000,
         "languageCode": "en-US"
       },
       "audio": {
         "uri": "gs://'$BUCKET_NAME'/hello.wav"
       }
     }' | python3 -m json.tool
   ```

3. **Test Real-time Recognition**
   - Go to: **APIs & Services** → **Speech-to-Text API** → **TRY THIS API**
   - Test **streamingRecognize** method
   - Configure for real-time audio processing

![Multiple Formats](https://via.placeholder.com/600x300/795548/FFFFFF?text=Test+Multiple+Formats)

---

### 📊 Task 8: Monitor API Usage

1. **View API Metrics**
   - Go to: **APIs & Services** → **Dashboard**
   - Click on **Cloud Speech-to-Text API**
   - Review usage metrics and quotas

2. **Check Request History**
   - Go to: **Logging** → **Logs Explorer**
   - Filter by: `resource.type="api"`
   - Search for Speech API requests

3. **Monitor Costs**
   - Go to: **Billing** → **Cost Table**
   - Filter by **Speech-to-Text API**
   - Review usage costs

![Monitor Usage](https://via.placeholder.com/600x300/4CAF50/FFFFFF?text=Monitor+API+Usage)

---

## ✅ Verification Steps

### 1. API Configuration
- [ ] Speech-to-Text API enabled
- [ ] API key created and secured
- [ ] Cloud Storage bucket created
- [ ] Sample audio files uploaded

### 2. Speech Recognition
- [ ] Basic transcription working
- [ ] Confidence scores displayed
- [ ] Multiple audio formats supported
- [ ] API responses properly formatted

### 3. Advanced Features
- [ ] Language detection working
- [ ] Word-level timestamps available
- [ ] Real-time recognition tested
- [ ] API usage monitoring active

---

## 🎯 Key Learning Points

1. **Speech Recognition** - Convert audio to text with high accuracy
2. **Multiple Formats** - Support for FLAC, WAV, MP3, and more
3. **Language Support** - 120+ languages and variants
4. **Real-time Processing** - Stream audio for live transcription
5. **Custom Models** - Train models for specific domains

---

## 🔧 Troubleshooting Guide

### ❌ Common Issues

| Issue | Solution |
|-------|----------|
| API key not working | Check API restrictions and permissions |
| Audio file not found | Verify bucket permissions and file path |
| Poor transcription quality | Check audio quality and encoding settings |
| Rate limit errors | Implement exponential backoff |
| Language not detected | Specify language code explicitly |

### 🔍 Debug Commands
```bash
# Test API key
curl -s "https://speech.googleapis.com/v1/operations?key=$API_KEY"

# Check file accessibility
gsutil ls -l gs://BUCKET_NAME/audio.flac

# Validate audio encoding
file audio.flac
```

---

## 📚 Additional Resources

- [Speech-to-Text Documentation](https://cloud.google.com/speech-to-text/docs)
- [Audio Encoding Guidelines](https://cloud.google.com/speech-to-text/docs/encoding)
- [Language Support](https://cloud.google.com/speech-to-text/docs/languages)

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line API testing approach
- **[Automation Solution](Automation-Solution.md)** - Scripted deployment with Python

---

## 🎖️ Skills Boost Arcade

Complete this challenge for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Use Speech-to-Text API for voice-enabled applications!

</div>
