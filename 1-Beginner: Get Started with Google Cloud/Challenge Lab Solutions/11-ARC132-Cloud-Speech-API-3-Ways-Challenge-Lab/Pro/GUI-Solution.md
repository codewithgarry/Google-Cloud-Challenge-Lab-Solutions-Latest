# Speech to Text API: 3 Ways - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Speech API](https://img.shields.io/badge/Speech%20API-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)

**Lab ID**: ARC131 | **Duration**: 15-20 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Lab Overview

Explore three different ways to use the Google Cloud Speech-to-Text API: REST API, gcloud CLI, and Python client library.

---

## 🧩 Challenge Tasks

1. **Method 1: REST API** - Use curl and REST endpoints
2. **Method 2: gcloud CLI** - Use gcloud command-line tools
3. **Method 3: Python Library** - Use Google Cloud Python SDK
4. **Compare Results** - Analyze differences between methods
5. **Advanced Features** - Test streaming and batch processing

---

## 🖥️ Step-by-Step GUI Solution

### 📋 Prerequisites
- Google Cloud Console access
- Cloud Shell activated
- Speech-to-Text API enabled

---

### 🚀 Task 1: Setup Environment

1. **Enable APIs**
   - Go to: **APIs & Services** → **Library**
   - Search and enable: `Cloud Speech-to-Text API`
   - Search and enable: `Cloud Storage API`

2. **Open Cloud Shell**
   - Click **Activate Cloud Shell** (top-right)
   - Wait for shell to initialize

3. **Set Environment Variables**
   ```bash
   export PROJECT_ID=$(gcloud config get-value project)
   export BUCKET_NAME="$PROJECT_ID-speech-lab"
   export REGION="us-central1"
   ```

![Setup Environment](https://via.placeholder.com/600x300/4285F4/FFFFFF?text=Setup+Environment)

---

### 📦 Task 2: Prepare Audio Files

1. **Create Storage Bucket**
   ```bash
   gsutil mb -l $REGION gs://$BUCKET_NAME
   ```

2. **Download Sample Audio**
   ```bash
   # Download various sample files
   wget https://cloud.google.com/speech-to-text/docs/samples/brooklyn.flac
   wget https://cloud.google.com/speech-to-text/docs/samples/hello.wav
   wget https://cloud.google.com/speech-to-text/docs/samples/audio.raw -O audio.raw
   ```

3. **Upload to Bucket**
   ```bash
   gsutil cp *.flac *.wav *.raw gs://$BUCKET_NAME/
   gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/*
   ```

![Prepare Audio](https://via.placeholder.com/600x300/34A853/FFFFFF?text=Prepare+Audio+Files)

---

### 🌐 Method 1: REST API Approach

1. **Create Authentication Token**
   ```bash
   export ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
   echo "Access token obtained"
   ```

2. **Create Request JSON for FLAC**
   ```bash
   cat > flac-request.json << EOF
   {
     "config": {
       "encoding": "FLAC",
       "sampleRateHertz": 16000,
       "languageCode": "en-US",
       "enableWordTimeOffsets": true,
       "enableWordConfidence": true
     },
     "audio": {
       "uri": "gs://$BUCKET_NAME/brooklyn.flac"
     }
   }
   EOF
   ```

3. **Execute REST API Call**
   ```bash
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://speech.googleapis.com/v1/speech:recognize" \
     -d @flac-request.json > rest-response.json
   ```

4. **View Results**
   ```bash
   echo "=== REST API Results ==="
   jq '.results[].alternatives[].transcript' rest-response.json
   jq '.results[].alternatives[].confidence' rest-response.json
   ```

![REST API Method](https://via.placeholder.com/600x300/FF9800/FFFFFF?text=REST+API+Method)

---

### ⚡ Method 2: gcloud CLI Approach

1. **Create Local Audio File Request**
   ```bash
   # First, let's prepare a local request file
   cat > gcloud-request.json << EOF
   {
     "config": {
       "encoding": "LINEAR16",
       "sampleRateHertz": 16000,
       "languageCode": "en-US",
       "enableWordTimeOffsets": true
     },
     "audio": {
       "uri": "gs://$BUCKET_NAME/hello.wav"
     }
   }
   EOF
   ```

2. **Use gcloud ml speech Command**
   ```bash
   gcloud ml speech recognize gs://$BUCKET_NAME/brooklyn.flac \
     --language-code='en-US' \
     --format=json > gcloud-response.json
   ```

3. **Alternative gcloud Method**
   ```bash
   # Using gcloud with local file
   gcloud ml speech recognize-long-running gs://$BUCKET_NAME/brooklyn.flac \
     --language-code='en-US' \
     --async
   ```

4. **View gcloud Results**
   ```bash
   echo "=== gcloud CLI Results ==="
   jq '.results[].alternatives[].transcript' gcloud-response.json
   ```

![gcloud CLI Method](https://via.placeholder.com/600x300/9C27B0/FFFFFF?text=gcloud+CLI+Method)

---

### 🐍 Method 3: Python Client Library

1. **Install Python Dependencies**
   ```bash
   pip3 install google-cloud-speech google-cloud-storage
   ```

2. **Create Python Script**
   ```bash
   cat > speech_client.py << 'EOF'
   #!/usr/bin/env python3
   
   import json
   from google.cloud import speech
   from google.cloud import storage
   
   def transcribe_audio_python(project_id, bucket_name):
       """Transcribe audio using Python client library"""
       
       # Initialize the Speech client
       client = speech.SpeechClient()
       
       # Configure the audio file and recognition settings
       audio = speech.RecognitionAudio(
           uri=f"gs://{bucket_name}/brooklyn.flac"
       )
       
       config = speech.RecognitionConfig(
           encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
           sample_rate_hertz=16000,
           language_code="en-US",
           enable_word_time_offsets=True,
           enable_word_confidence=True,
           enable_automatic_punctuation=True,
           max_alternatives=3
       )
       
       # Perform the transcription
       print("Transcribing audio with Python client...")
       response = client.recognize(config=config, audio=audio)
       
       # Process results
       results = []
       for result in response.results:
           for alternative in result.alternatives:
               result_data = {
                   "transcript": alternative.transcript,
                   "confidence": alternative.confidence,
                   "words": []
               }
               
               # Extract word-level information
               for word in alternative.words:
                   word_info = {
                       "word": word.word,
                       "start_time": word.start_time.total_seconds(),
                       "end_time": word.end_time.total_seconds()
                   }
                   if hasattr(word, 'confidence'):
                       word_info["confidence"] = word.confidence
                   result_data["words"].append(word_info)
               
               results.append(result_data)
       
       return results
   
   def transcribe_streaming_python():
       """Test streaming recognition"""
       client = speech.SpeechClient()
       
       config = speech.RecognitionConfig(
           encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
           sample_rate_hertz=16000,
           language_code="en-US",
       )
       
       streaming_config = speech.StreamingRecognitionConfig(
           config=config,
           interim_results=True,
       )
       
       print("Streaming recognition configured")
       return "Streaming setup complete"
   
   if __name__ == "__main__":
       import sys
       import os
       
       project_id = os.environ.get('PROJECT_ID')
       bucket_name = os.environ.get('BUCKET_NAME')
       
       if not project_id or not bucket_name:
           print("Please set PROJECT_ID and BUCKET_NAME environment variables")
           sys.exit(1)
       
       try:
           # Test basic transcription
           results = transcribe_audio_python(project_id, bucket_name)
           
           print("=== Python Client Results ===")
           for i, result in enumerate(results):
               print(f"Alternative {i+1}:")
               print(f"Transcript: {result['transcript']}")
               print(f"Confidence: {result['confidence']:.2f}")
               print(f"Word count: {len(result['words'])}")
               print()
           
           # Save results
           with open('python-response.json', 'w') as f:
               json.dump(results, f, indent=2)
           
           # Test streaming setup
           streaming_result = transcribe_streaming_python()
           print(f"Streaming test: {streaming_result}")
           
       except Exception as e:
           print(f"Error: {str(e)}")
           sys.exit(1)
   EOF
   ```

3. **Run Python Script**
   ```bash
   python3 speech_client.py
   ```

![Python Client Method](https://via.placeholder.com/600x300/2196F3/FFFFFF?text=Python+Client+Method)

---

### 📊 Task 3: Compare Results

1. **Create Comparison Script**
   ```bash
   cat > compare_results.py << 'EOF'
   #!/usr/bin/env python3
   
   import json
   import os
   
   def load_json_file(filename):
       """Load JSON file safely"""
       try:
           with open(filename, 'r') as f:
               return json.load(f)
       except:
           return None
   
   def compare_transcription_results():
       """Compare results from all three methods"""
       
       print("=== TRANSCRIPTION COMPARISON ===")
       print()
       
       # Load REST API results
       rest_data = load_json_file('rest-response.json')
       if rest_data and 'results' in rest_data:
           rest_transcript = rest_data['results'][0]['alternatives'][0]['transcript']
           rest_confidence = rest_data['results'][0]['alternatives'][0]['confidence']
           print(f"1. REST API:")
           print(f"   Transcript: {rest_transcript}")
           print(f"   Confidence: {rest_confidence:.3f}")
       else:
           print("1. REST API: No results available")
       
       print()
       
       # Load gcloud results  
       gcloud_data = load_json_file('gcloud-response.json')
       if gcloud_data and 'results' in gcloud_data:
           gcloud_transcript = gcloud_data['results'][0]['alternatives'][0]['transcript']
           gcloud_confidence = gcloud_data['results'][0]['alternatives'][0].get('confidence', 'N/A')
           print(f"2. gcloud CLI:")
           print(f"   Transcript: {gcloud_transcript}")
           print(f"   Confidence: {gcloud_confidence}")
       else:
           print("2. gcloud CLI: No results available")
       
       print()
       
       # Load Python client results
       python_data = load_json_file('python-response.json')
       if python_data:
           python_transcript = python_data[0]['transcript']
           python_confidence = python_data[0]['confidence']
           print(f"3. Python Client:")
           print(f"   Transcript: {python_transcript}")
           print(f"   Confidence: {python_confidence:.3f}")
           print(f"   Word-level data: {len(python_data[0]['words'])} words")
       else:
           print("3. Python Client: No results available")
       
       print()
       print("=== ANALYSIS ===")
       
       # Compare transcripts
       transcripts = []
       if rest_data and 'results' in rest_data:
           transcripts.append(rest_data['results'][0]['alternatives'][0]['transcript'])
       if gcloud_data and 'results' in gcloud_data:
           transcripts.append(gcloud_data['results'][0]['alternatives'][0]['transcript'])
       if python_data:
           transcripts.append(python_data[0]['transcript'])
       
       if len(set(transcripts)) == 1:
           print("✅ All methods produced identical transcripts")
       else:
           print("⚠️ Methods produced different transcripts")
           print("This could be due to different configurations or timing")
       
       print()
       print("=== METHOD COMPARISON ===")
       print("REST API:      Direct HTTP calls, maximum control")
       print("gcloud CLI:    Simple command-line interface")  
       print("Python Client: Full SDK features, best for applications")
   
   if __name__ == "__main__":
       compare_transcription_results()
   EOF
   ```

2. **Run Comparison**
   ```bash
   python3 compare_results.py
   ```

![Compare Results](https://via.placeholder.com/600x300/607D8B/FFFFFF?text=Compare+Results)

---

### 🔄 Task 4: Test Advanced Features

1. **Long-Running Recognition (REST)**
   ```bash
   cat > long-running-request.json << EOF
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
   
   # Submit long-running operation
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://speech.googleapis.com/v1/speech:longrunningrecognize" \
     -d @long-running-request.json > long-running-response.json
   
   echo "Long-running operation submitted"
   jq '.name' long-running-response.json
   ```

2. **Check Operation Status**
   ```bash
   OPERATION_NAME=$(jq -r '.name' long-running-response.json)
   
   curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
     "https://speech.googleapis.com/v1/operations/$OPERATION_NAME" > operation-status.json
   
   echo "Operation status:"
   jq '.done' operation-status.json
   ```

3. **Batch Processing Test**
   ```bash
   cat > batch_test.py << 'EOF'
   #!/usr/bin/env python3
   
   import os
   import time
   from google.cloud import speech
   
   def test_batch_processing():
       """Test processing multiple files"""
       
       client = speech.SpeechClient()
       bucket_name = os.environ.get('BUCKET_NAME')
       
       files_to_process = [
           {"uri": f"gs://{bucket_name}/brooklyn.flac", "encoding": "FLAC"},
           {"uri": f"gs://{bucket_name}/hello.wav", "encoding": "LINEAR16"}
       ]
       
       results = []
       
       for file_info in files_to_process:
           print(f"Processing {file_info['uri']}...")
           
           if file_info['encoding'] == 'FLAC':
               encoding = speech.RecognitionConfig.AudioEncoding.FLAC
           else:
               encoding = speech.RecognitionConfig.AudioEncoding.LINEAR16
           
           config = speech.RecognitionConfig(
               encoding=encoding,
               sample_rate_hertz=16000,
               language_code="en-US"
           )
           
           audio = speech.RecognitionAudio(uri=file_info['uri'])
           
           try:
               response = client.recognize(config=config, audio=audio)
               
               if response.results:
                   transcript = response.results[0].alternatives[0].transcript
                   confidence = response.results[0].alternatives[0].confidence
                   
                   results.append({
                       "file": file_info['uri'],
                       "transcript": transcript,
                       "confidence": confidence
                   })
                   
                   print(f"✅ Success: {transcript}")
               else:
                   print(f"❌ No results for {file_info['uri']}")
                   
           except Exception as e:
               print(f"❌ Error processing {file_info['uri']}: {str(e)}")
           
           time.sleep(1)  # Rate limiting
       
       print(f"\nBatch processing complete. Processed {len(results)} files successfully.")
       return results
   
   if __name__ == "__main__":
       test_batch_processing()
   EOF
   
   python3 batch_test.py
   ```

![Advanced Features](https://via.placeholder.com/600x300/795548/FFFFFF?text=Advanced+Features)

---

### 🎛️ Task 5: Test Different Audio Formats

1. **Test Multiple Formats Script**
   ```bash
   cat > test_formats.py << 'EOF'
   #!/usr/bin/env python3
   
   import os
   import json
   from google.cloud import speech
   
   def test_audio_formats():
       """Test different audio formats"""
       
       client = speech.SpeechClient()
       bucket_name = os.environ.get('BUCKET_NAME')
       
       format_tests = [
           {
               "name": "FLAC Format",
               "uri": f"gs://{bucket_name}/brooklyn.flac",
               "encoding": speech.RecognitionConfig.AudioEncoding.FLAC,
               "sample_rate": 16000
           },
           {
               "name": "WAV Format", 
               "uri": f"gs://{bucket_name}/hello.wav",
               "encoding": speech.RecognitionConfig.AudioEncoding.LINEAR16,
               "sample_rate": 16000
           }
       ]
       
       results = {"format_tests": []}
       
       for test in format_tests:
           print(f"\nTesting {test['name']}...")
           
           config = speech.RecognitionConfig(
               encoding=test['encoding'],
               sample_rate_hertz=test['sample_rate'],
               language_code="en-US",
               enable_word_time_offsets=True,
               enable_automatic_punctuation=True
           )
           
           audio = speech.RecognitionAudio(uri=test['uri'])
           
           try:
               response = client.recognize(config=config, audio=audio)
               
               if response.results:
                   result = response.results[0].alternatives[0]
                   
                   test_result = {
                       "format": test['name'],
                       "status": "success",
                       "transcript": result.transcript,
                       "confidence": result.confidence,
                       "word_count": len(result.words) if hasattr(result, 'words') else 0
                   }
                   
                   print(f"✅ {test['name']}: {result.transcript}")
                   print(f"   Confidence: {result.confidence:.3f}")
                   
               else:
                   test_result = {
                       "format": test['name'],
                       "status": "no_results",
                       "error": "No transcription results"
                   }
                   print(f"❌ {test['name']}: No results")
               
               results["format_tests"].append(test_result)
               
           except Exception as e:
               test_result = {
                   "format": test['name'],
                   "status": "error",
                   "error": str(e)
               }
               results["format_tests"].append(test_result)
               print(f"❌ {test['name']}: Error - {str(e)}")
       
       # Save format test results
       with open('format-test-results.json', 'w') as f:
           json.dump(results, f, indent=2)
       
       print(f"\nFormat testing complete. Results saved to format-test-results.json")
       return results
   
   if __name__ == "__main__":
       test_audio_formats()
   EOF
   
   python3 test_formats.py
   ```

![Format Testing](https://via.placeholder.com/600x300/4CAF50/FFFFFF?text=Format+Testing)

---

### 📈 Task 6: Performance Analysis

1. **Create Performance Test**
   ```bash
   cat > performance_test.py << 'EOF'
   #!/usr/bin/env python3
   
   import time
   import json
   import os
   import requests
   import subprocess
   from google.cloud import speech
   
   def measure_rest_api_performance():
       """Measure REST API performance"""
       
       access_token = subprocess.run([
           'gcloud', 'auth', 'application-default', 'print-access-token'
       ], capture_output=True, text=True).stdout.strip()
       
       bucket_name = os.environ.get('BUCKET_NAME')
       
       request_data = {
           "config": {
               "encoding": "FLAC",
               "sampleRateHertz": 16000,
               "languageCode": "en-US"
           },
           "audio": {
               "uri": f"gs://{bucket_name}/brooklyn.flac"
           }
       }
       
       headers = {
           "Authorization": f"Bearer {access_token}",
           "Content-Type": "application/json"
       }
       
       start_time = time.time()
       
       response = requests.post(
           "https://speech.googleapis.com/v1/speech:recognize",
           headers=headers,
           json=request_data,
           timeout=30
       )
       
       end_time = time.time()
       
       return {
           "method": "REST API",
           "response_time": end_time - start_time,
           "status_code": response.status_code,
           "success": response.status_code == 200
       }
   
   def measure_python_client_performance():
       """Measure Python client performance"""
       
       client = speech.SpeechClient()
       bucket_name = os.environ.get('BUCKET_NAME')
       
       config = speech.RecognitionConfig(
           encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
           sample_rate_hertz=16000,
           language_code="en-US"
       )
       
       audio = speech.RecognitionAudio(uri=f"gs://{bucket_name}/brooklyn.flac")
       
       start_time = time.time()
       
       try:
           response = client.recognize(config=config, audio=audio)
           success = len(response.results) > 0
       except Exception as e:
           success = False
       
       end_time = time.time()
       
       return {
           "method": "Python Client",
           "response_time": end_time - start_time,
           "success": success
       }
   
   def run_performance_tests():
       """Run comprehensive performance tests"""
       
       print("Running performance tests...")
       
       results = {
           "test_timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
           "tests": []
       }
       
       # Test REST API
       print("Testing REST API performance...")
       try:
           rest_result = measure_rest_api_performance()
           results["tests"].append(rest_result)
           print(f"✅ REST API: {rest_result['response_time']:.2f}s")
       except Exception as e:
           print(f"❌ REST API test failed: {str(e)}")
       
       time.sleep(2)  # Rate limiting
       
       # Test Python client
       print("Testing Python client performance...")
       try:
           python_result = measure_python_client_performance()
           results["tests"].append(python_result)
           print(f"✅ Python Client: {python_result['response_time']:.2f}s")
       except Exception as e:
           print(f"❌ Python client test failed: {str(e)}")
       
       # Save results
       with open('performance-results.json', 'w') as f:
           json.dump(results, f, indent=2)
       
       print("\nPerformance test results:")
       for test in results["tests"]:
           status = "✅" if test["success"] else "❌"
           print(f"{status} {test['method']}: {test['response_time']:.2f}s")
       
       return results
   
   if __name__ == "__main__":
       run_performance_tests()
   EOF
   
   python3 performance_test.py
   ```

![Performance Analysis](https://via.placeholder.com/600x300/FF5722/FFFFFF?text=Performance+Analysis)

---

## ✅ Verification Steps

### 1. Method Testing
- [ ] REST API transcription successful
- [ ] gcloud CLI transcription successful
- [ ] Python client transcription successful
- [ ] All three methods produce results

### 2. Feature Comparison
- [ ] Word-level timestamps available
- [ ] Confidence scores calculated
- [ ] Multiple alternatives tested
- [ ] Different audio formats processed

### 3. Advanced Features
- [ ] Long-running operations tested
- [ ] Batch processing implemented
- [ ] Streaming configuration tested
- [ ] Performance metrics collected

---

## 🎯 Key Learning Points

1. **Multiple Access Methods** - REST, CLI, and SDK approaches
2. **Feature Parity** - All methods access same capabilities
3. **Use Case Optimization** - Different methods for different scenarios
4. **Performance Characteristics** - Response times and efficiency
5. **Integration Patterns** - How to choose the right method

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line approach
- **[Automation Solution](Automation-Solution.md)** - Scripted implementation

---

## 🎖️ Skills Boost Arcade

Complete this challenge for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Choose the right Speech API method based on your use case and integration needs!

</div>
