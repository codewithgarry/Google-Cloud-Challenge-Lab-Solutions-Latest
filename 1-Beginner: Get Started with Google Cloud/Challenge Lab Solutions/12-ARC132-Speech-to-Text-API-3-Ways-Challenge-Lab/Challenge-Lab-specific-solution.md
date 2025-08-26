# ARC132: Speech to Text API 3 Ways: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Speech to Text](https://img.shields.io/badge/Speech%20to%20Text-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC132 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll explore three different ways to use the Speech-to-Text API: through the console, command line, and client libraries.

## 📋 Challenge Tasks

### Task 1: Console-based Speech Recognition

Use the Google Cloud Console to transcribe audio files.

### Task 2: Command Line Interface (gcloud)

Implement speech recognition using gcloud commands.

### Task 3: Client Library Implementation

Build applications using Speech-to-Text client libraries.

### Task 4: REST API Direct Access

Access the API directly using REST calls.

### Task 5: Batch Processing Comparison

Compare efficiency across all three methods.

---

## 🚀 Solution Method 1: Google Cloud Console

### Step 1: Environment Setup

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME=${PROJECT_ID}-speech-3ways
export REGION=us-central1

# Enable required APIs
gcloud services enable speech.googleapis.com
gcloud services enable storage.googleapis.com

# Create bucket
gsutil mb -l $REGION gs://$BUCKET_NAME

# Create sample audio files directory
mkdir ~/speech-3ways-demo
cd ~/speech-3ways-demo
```

### Step 2: Prepare Audio Files

```bash
# Download sample audio files
curl -o english_sample.wav "https://storage.googleapis.com/cloud-samples-data/speech/hello.wav"
curl -o commercial_sample.wav "https://storage.googleapis.com/cloud-samples-data/speech/commercial_mono.wav"

# Create text samples for reference
echo "Hello, welcome to Google Cloud Speech API demonstration." > english_reference.txt
echo "This is a commercial audio sample for testing purposes." > commercial_reference.txt

# Upload to Cloud Storage
gsutil cp *.wav gs://$BUCKET_NAME/audio/
gsutil cp *.txt gs://$BUCKET_NAME/reference/

# Create different audio formats for testing
# Note: You would typically use audio conversion tools here
echo "Audio files prepared for testing different methods"
```

### Step 3: Console Method Documentation

```bash
# Create console instructions
cat > console_method.md << 'EOF'
# Method 1: Google Cloud Console

## Steps to use Speech-to-Text via Console:

1. **Navigate to Speech-to-Text**
   - Go to Google Cloud Console
   - Navigate to "Speech-to-Text" service
   - Click on "Transcriptions"

2. **Create New Transcription**
   - Click "Create Transcription"
   - Choose "Upload audio file" or "Use Cloud Storage URI"
   - For Cloud Storage: gs://PROJECT_ID-speech-3ways/audio/english_sample.wav

3. **Configure Settings**
   - Language: English (United States)
   - Model: Default
   - Enable automatic punctuation: Yes
   - Enable word-level confidence: Yes

4. **Advanced Options**
   - Audio encoding: Automatically detected
   - Sample rate: Automatically detected
   - Audio channels: Automatically detected

5. **Run Transcription**
   - Click "Create"
   - Wait for processing to complete
   - Review results with confidence scores

6. **Export Results**
   - Download transcription as JSON
   - Download transcription as SRT
   - Download transcription as TXT

## Console Advantages:
- User-friendly interface
- No coding required
- Visual confidence indicators
- Easy file management
- Multiple export formats

## Console Limitations:
- Manual process
- Limited automation
- No batch processing
- Limited customization
EOF

echo "Console method documentation created"
```

---

## 🚀 Solution Method 2: Command Line Interface (gcloud)

### Step 1: CLI Configuration

```bash
# Verify gcloud configuration
gcloud config list
gcloud auth list

# Set default project if needed
gcloud config set project $PROJECT_ID

# Test API access
gcloud services list --enabled | grep speech
```

### Step 2: Basic gcloud Speech Commands

```bash
# Create CLI demonstration script
cat > cli_method.py << 'EOF'
import subprocess
import json
import os
import time

class GCloudSpeechCLI:
    def __init__(self, project_id, bucket_name):
        self.project_id = project_id
        self.bucket_name = bucket_name
    
    def transcribe_local_file(self, audio_file, language_code="en-US"):
        """Transcribe local audio file using gcloud"""
        print(f"Transcribing local file: {audio_file}")
        
        # Create temporary request file
        request_data = {
            "config": {
                "encoding": "LINEAR16",
                "sampleRateHertz": 16000,
                "languageCode": language_code,
                "enableAutomaticPunctuation": True,
                "enableWordTimeOffsets": True
            },
            "audio": {
                "content": self._encode_audio_file(audio_file)
            }
        }
        
        with open("request.json", "w") as f:
            json.dump(request_data, f)
        
        # Execute gcloud command
        cmd = [
            "gcloud", "ml", "speech", "recognize",
            "--audio-file-name", audio_file,
            "--language-code", language_code,
            "--include-word-time-offsets",
            "--format", "json"
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            return json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error: {e.stderr}")
            return None
    
    def transcribe_gcs_file(self, gcs_uri, language_code="en-US"):
        """Transcribe GCS file using gcloud"""
        print(f"Transcribing GCS file: {gcs_uri}")
        
        cmd = [
            "gcloud", "ml", "speech", "recognize-long-running",
            "--audio-file-name", gcs_uri,
            "--language-code", language_code,
            "--include-word-time-offsets",
            "--enable-automatic-punctuation",
            "--format", "json"
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            return json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"Error: {e.stderr}")
            return None
    
    def _encode_audio_file(self, audio_file):
        """Encode audio file to base64 for API request"""
        import base64
        
        with open(audio_file, "rb") as f:
            content = f.read()
        
        return base64.b64encode(content).decode('utf-8')
    
    def batch_transcribe_with_cli(self, file_list):
        """Batch transcribe multiple files using CLI"""
        results = {}
        
        for audio_file in file_list:
            try:
                if audio_file.startswith('gs://'):
                    result = self.transcribe_gcs_file(audio_file)
                else:
                    result = self.transcribe_local_file(audio_file)
                
                results[audio_file] = {
                    'status': 'success',
                    'data': result
                }
                
                # Add delay to avoid rate limiting
                time.sleep(2)
                
            except Exception as e:
                results[audio_file] = {
                    'status': 'error',
                    'error': str(e)
                }
        
        return results
    
    def create_batch_script(self, file_list, output_dir="cli_results"):
        """Create bash script for batch processing"""
        
        os.makedirs(output_dir, exist_ok=True)
        
        script_content = f"""#!/bin/bash

# Batch Speech-to-Text processing script
# Generated for project: {self.project_id}

set -e

echo "Starting batch transcription..."
echo "Output directory: {output_dir}"

"""
        
        for i, audio_file in enumerate(file_list):
            output_file = f"{output_dir}/result_{i:03d}.json"
            
            if audio_file.startswith('gs://'):
                script_content += f"""
echo "Processing {audio_file}..."
gcloud ml speech recognize-long-running \\
    --audio-file-name="{audio_file}" \\
    --language-code="en-US" \\
    --include-word-time-offsets \\
    --enable-automatic-punctuation \\
    --format=json > "{output_file}"

"""
            else:
                script_content += f"""
echo "Processing {audio_file}..."
gcloud ml speech recognize \\
    --audio-file-name="{audio_file}" \\
    --language-code="en-US" \\
    --include-word-time-offsets \\
    --format=json > "{output_file}"

"""
        
        script_content += """
echo "Batch processing complete!"
echo "Results saved in: """ + output_dir + """"
"""
        
        with open("batch_transcribe.sh", "w") as f:
            f.write(script_content)
        
        # Make script executable
        os.chmod("batch_transcribe.sh", 0o755)
        
        print("Batch script created: batch_transcribe.sh")
        return "batch_transcribe.sh"

def demonstrate_cli_method():
    """Demonstrate CLI-based speech recognition"""
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-speech-3ways"
    
    cli_processor = GCloudSpeechCLI(project_id, bucket_name)
    
    # Test files
    test_files = [
        "english_sample.wav",
        f"gs://{bucket_name}/audio/english_sample.wav",
        f"gs://{bucket_name}/audio/commercial_sample.wav"
    ]
    
    # Single file transcription
    print("=== Single File Transcription ===")
    if os.path.exists("english_sample.wav"):
        result = cli_processor.transcribe_local_file("english_sample.wav")
        if result:
            print(json.dumps(result, indent=2))
    
    # GCS file transcription
    print("\n=== GCS File Transcription ===")
    gcs_result = cli_processor.transcribe_gcs_file(f"gs://{bucket_name}/audio/english_sample.wav")
    if gcs_result:
        print("GCS transcription successful")
    
    # Create batch script
    print("\n=== Creating Batch Script ===")
    script_file = cli_processor.create_batch_script(test_files)
    print(f"Created batch script: {script_file}")
    
    return cli_processor

if __name__ == "__main__":
    demonstrate_cli_method()
EOF

# Run CLI demonstration
python cli_method.py
```

### Step 3: Advanced CLI Operations

```bash
# Create advanced CLI operations script
cat > advanced_cli_operations.sh << 'EOF'
#!/bin/bash

# Advanced gcloud Speech-to-Text operations
set -e

PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-speech-3ways"

echo "=== Advanced CLI Speech Operations ==="

# Function to transcribe with custom configuration
transcribe_with_config() {
    local audio_file=$1
    local config_file=$2
    local output_file=$3
    
    echo "Transcribing $audio_file with custom config..."
    
    gcloud ml speech recognize \
        --audio-file-name="$audio_file" \
        --language-code="en-US" \
        --include-word-time-offsets \
        --enable-automatic-punctuation \
        --enable-word-confidence \
        --profanity-filter \
        --format=json > "$output_file"
    
    echo "Results saved to: $output_file"
}

# Function for long-running operations
transcribe_long_audio() {
    local gcs_uri=$1
    local operation_name=$2
    
    echo "Starting long-running transcription for: $gcs_uri"
    
    # Start operation
    gcloud ml speech operations describe $operation_name || \
    gcloud ml speech recognize-long-running \
        --audio-file-name="$gcs_uri" \
        --language-code="en-US" \
        --include-word-time-offsets \
        --enable-automatic-punctuation \
        --async \
        --operation-id="$operation_name"
    
    # Wait for completion
    echo "Waiting for operation to complete..."
    while true; do
        status=$(gcloud ml speech operations describe $operation_name --format="value(done)")
        if [ "$status" = "True" ]; then
            break
        fi
        echo "Operation still running..."
        sleep 10
    done
    
    # Get results
    echo "Getting results..."
    gcloud ml speech operations describe $operation_name --format=json
}

# Function to create speech context for better accuracy
create_speech_context() {
    local phrases_file=$1
    
    cat > "$phrases_file" << EOL
{
    "speechContexts": [
        {
            "phrases": [
                "Google Cloud",
                "Speech API", 
                "machine learning",
                "artificial intelligence",
                "cloud computing",
                "transcription"
            ]
        }
    ]
}
EOL

    echo "Speech context created: $phrases_file"
}

# Function for multi-language detection
transcribe_multilanguage() {
    local audio_file=$1
    local output_file=$2
    
    echo "Transcribing with language detection: $audio_file"
    
    gcloud ml speech recognize \
        --audio-file-name="$audio_file" \
        --language-code="en-US" \
        --alternative-language-codes="es-ES,fr-FR,de-DE" \
        --include-word-time-offsets \
        --enable-automatic-punctuation \
        --format=json > "$output_file"
    
    echo "Multi-language results saved to: $output_file"
}

# Main execution
main() {
    echo "Starting advanced CLI operations..."
    
    # Create output directory
    mkdir -p cli_advanced_results
    
    # Test audio files
    AUDIO_FILE="gs://${BUCKET_NAME}/audio/english_sample.wav"
    
    # Basic transcription with enhanced features
    echo "1. Enhanced transcription..."
    transcribe_with_config "$AUDIO_FILE" "config.json" "cli_advanced_results/enhanced.json"
    
    # Multi-language transcription
    echo "2. Multi-language transcription..."
    transcribe_multilanguage "$AUDIO_FILE" "cli_advanced_results/multilang.json"
    
    # Create speech context
    echo "3. Creating speech context..."
    create_speech_context "speech_context.json"
    
    # Long-running operation (if audio is long enough)
    echo "4. Testing long-running operation..."
    OPERATION_ID="long-op-$(date +%s)"
    # transcribe_long_audio "$AUDIO_FILE" "$OPERATION_ID"
    
    echo "Advanced CLI operations completed!"
    echo "Results available in: cli_advanced_results/"
}

# Run main function
main
EOF

# Make script executable and run
chmod +x advanced_cli_operations.sh
./advanced_cli_operations.sh
```

---

## 🚀 Solution Method 3: Client Libraries

### Step 1: Python Client Library Implementation

```bash
# Create comprehensive client library script
cat > client_library_method.py << 'EOF'
from google.cloud import speech
from google.cloud import storage
import io
import json
import time
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
import queue
import os

class SpeechClientLibraryDemo:
    def __init__(self, project_id):
        self.project_id = project_id
        self.speech_client = speech.SpeechClient()
        self.storage_client = storage.Client()
    
    def method1_synchronous_recognition(self, audio_content, language_code="en-US"):
        """Method 1: Synchronous recognition for short audio"""
        print("=== Method 1: Synchronous Recognition ===")
        
        # Configure recognition
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code=language_code,
            enable_automatic_punctuation=True,
            enable_word_time_offsets=True,
            enable_word_confidence=True,
        )
        
        audio = speech.RecognitionAudio(content=audio_content)
        
        # Perform recognition
        response = self.speech_client.recognize(config=config, audio=audio)
        
        # Process results
        results = []
        for result in response.results:
            result_data = {
                'transcript': result.alternatives[0].transcript,
                'confidence': result.alternatives[0].confidence,
                'words': []
            }
            
            for word_info in result.alternatives[0].words:
                word_data = {
                    'word': word_info.word,
                    'start_time': word_info.start_time.total_seconds(),
                    'end_time': word_info.end_time.total_seconds(),
                    'confidence': getattr(word_info, 'confidence', 0.0)
                }
                result_data['words'].append(word_data)
            
            results.append(result_data)
        
        return results
    
    def method2_long_running_recognition(self, gcs_uri, language_code="en-US"):
        """Method 2: Asynchronous recognition for long audio"""
        print("=== Method 2: Long-running Recognition ===")
        
        # Configure recognition for long audio
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code=language_code,
            enable_automatic_punctuation=True,
            enable_word_time_offsets=True,
            enable_speaker_diarization=True,
            diarization_speaker_count=2,
            profanity_filter=True,
        )
        
        audio = speech.RecognitionAudio(uri=gcs_uri)
        
        # Start long-running operation
        operation = self.speech_client.long_running_recognize(
            config=config, audio=audio
        )
        
        print(f"Waiting for operation to complete... (Operation name: {operation.operation.name})")
        response = operation.result(timeout=1800)  # 30 minutes timeout
        
        # Process results
        results = []
        for result in response.results:
            result_data = {
                'transcript': result.alternatives[0].transcript,
                'confidence': result.alternatives[0].confidence,
                'channel_tag': getattr(result, 'channel_tag', 0),
                'words': []
            }
            
            for word_info in result.alternatives[0].words:
                word_data = {
                    'word': word_info.word,
                    'start_time': word_info.start_time.total_seconds(),
                    'end_time': word_info.end_time.total_seconds(),
                    'speaker_tag': getattr(word_info, 'speaker_tag', 0)
                }
                result_data['words'].append(word_data)
            
            results.append(result_data)
        
        return results
    
    def method3_streaming_recognition(self, audio_generator):
        """Method 3: Streaming recognition for real-time audio"""
        print("=== Method 3: Streaming Recognition ===")
        
        # Configure streaming recognition
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
            enable_automatic_punctuation=True,
        )
        
        streaming_config = speech.StreamingRecognitionConfig(
            config=config,
            interim_results=True,
        )
        
        # Perform streaming recognition
        requests = (speech.StreamingRecognizeRequest(audio_content=chunk)
                   for chunk in audio_generator)
        
        responses = self.speech_client.streaming_recognize(
            config=streaming_config, requests=requests
        )
        
        # Process streaming results
        results = []
        for response in responses:
            for result in response.results:
                if result.is_final:
                    result_data = {
                        'transcript': result.alternatives[0].transcript,
                        'confidence': result.alternatives[0].confidence,
                        'is_final': True
                    }
                    results.append(result_data)
                    print(f"Final: {result.alternatives[0].transcript}")
                else:
                    print(f"Interim: {result.alternatives[0].transcript}")
        
        return results
    
    def batch_processing_with_threading(self, audio_files, max_workers=5):
        """Batch process multiple audio files using threading"""
        print("=== Batch Processing with Threading ===")
        
        def process_single_file(file_info):
            file_path, gcs_uri = file_info
            try:
                if os.path.exists(file_path):
                    with open(file_path, 'rb') as f:
                        content = f.read()
                    result = self.method1_synchronous_recognition(content)
                else:
                    result = self.method2_long_running_recognition(gcs_uri)
                
                return {
                    'file': file_path,
                    'status': 'success',
                    'result': result
                }
            except Exception as e:
                return {
                    'file': file_path,
                    'status': 'error',
                    'error': str(e)
                }
        
        results = []
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_file = {
                executor.submit(process_single_file, file_info): file_info 
                for file_info in audio_files
            }
            
            for future in as_completed(future_to_file):
                file_info = future_to_file[future]
                try:
                    result = future.result()
                    results.append(result)
                    print(f"Completed processing: {file_info[0]}")
                except Exception as e:
                    print(f"Error processing {file_info[0]}: {e}")
        
        return results
    
    def compare_all_methods(self, test_audio_file, gcs_uri):
        """Compare all three methods with the same audio"""
        print("=== Comparing All Methods ===")
        
        comparison_results = {}
        
        # Method 1: Synchronous (for short audio)
        try:
            start_time = time.time()
            with open(test_audio_file, 'rb') as f:
                content = f.read()
            
            sync_result = self.method1_synchronous_recognition(content)
            sync_time = time.time() - start_time
            
            comparison_results['synchronous'] = {
                'result': sync_result,
                'processing_time': sync_time,
                'status': 'success'
            }
        except Exception as e:
            comparison_results['synchronous'] = {
                'status': 'error',
                'error': str(e)
            }
        
        # Method 2: Long-running (for same audio via GCS)
        try:
            start_time = time.time()
            longrun_result = self.method2_long_running_recognition(gcs_uri)
            longrun_time = time.time() - start_time
            
            comparison_results['long_running'] = {
                'result': longrun_result,
                'processing_time': longrun_time,
                'status': 'success'
            }
        except Exception as e:
            comparison_results['long_running'] = {
                'status': 'error',
                'error': str(e)
            }
        
        # Method 3: Streaming simulation
        try:
            start_time = time.time()
            
            def audio_generator():
                with open(test_audio_file, 'rb') as f:
                    while True:
                        chunk = f.read(1024)
                        if not chunk:
                            break
                        yield chunk
            
            streaming_result = self.method3_streaming_recognition(audio_generator())
            streaming_time = time.time() - start_time
            
            comparison_results['streaming'] = {
                'result': streaming_result,
                'processing_time': streaming_time,
                'status': 'success'
            }
        except Exception as e:
            comparison_results['streaming'] = {
                'status': 'error',
                'error': str(e)
            }
        
        return comparison_results
    
    def demonstrate_advanced_features(self, gcs_uri):
        """Demonstrate advanced features of the client library"""
        print("=== Advanced Features Demo ===")
        
        # Multi-channel audio processing
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
            audio_channel_count=2,
            enable_separate_recognition_per_channel=True,
            enable_automatic_punctuation=True,
            enable_word_time_offsets=True,
            enable_speaker_diarization=True,
            diarization_speaker_count=3,
            speech_contexts=[
                speech.SpeechContext(
                    phrases=["Google Cloud", "Speech API", "transcription", "audio processing"]
                )
            ],
            metadata=speech.RecognitionMetadata(
                interaction_type=speech.RecognitionMetadata.InteractionType.DISCUSSION,
                microphone_distance=speech.RecognitionMetadata.MicrophoneDistance.MIDFIELD,
                original_media_type=speech.RecognitionMetadata.OriginalMediaType.AUDIO,
            ),
        )
        
        audio = speech.RecognitionAudio(uri=gcs_uri)
        
        try:
            response = self.speech_client.recognize(config=config, audio=audio)
            
            advanced_results = {
                'channels': {},
                'speakers': {},
                'overall_transcript': ""
            }
            
            for result in response.results:
                channel = getattr(result, 'channel_tag', 0)
                
                if channel not in advanced_results['channels']:
                    advanced_results['channels'][channel] = []
                
                result_data = {
                    'transcript': result.alternatives[0].transcript,
                    'confidence': result.alternatives[0].confidence,
                    'words': []
                }
                
                for word_info in result.alternatives[0].words:
                    speaker = getattr(word_info, 'speaker_tag', 0)
                    
                    if speaker not in advanced_results['speakers']:
                        advanced_results['speakers'][speaker] = []
                    
                    word_data = {
                        'word': word_info.word,
                        'start_time': word_info.start_time.total_seconds(),
                        'end_time': word_info.end_time.total_seconds(),
                        'speaker': speaker
                    }
                    
                    result_data['words'].append(word_data)
                    advanced_results['speakers'][speaker].append(word_data)
                
                advanced_results['channels'][channel].append(result_data)
                advanced_results['overall_transcript'] += result_data['transcript'] + " "
            
            return advanced_results
            
        except Exception as e:
            print(f"Error in advanced features demo: {e}")
            return None

def main():
    """Main demonstration function"""
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-speech-3ways"
    
    demo = SpeechClientLibraryDemo(project_id)
    
    # Test files
    test_audio = "english_sample.wav"
    gcs_uri = f"gs://{bucket_name}/audio/english_sample.wav"
    
    # Demonstrate all methods
    if os.path.exists(test_audio):
        print("Starting comprehensive client library demonstration...")
        
        # Compare all methods
        comparison = demo.compare_all_methods(test_audio, gcs_uri)
        
        # Save comparison results
        with open('client_library_comparison.json', 'w') as f:
            json.dump(comparison, f, indent=2, default=str)
        
        print("Comparison results saved to: client_library_comparison.json")
        
        # Advanced features demo
        advanced_results = demo.demonstrate_advanced_features(gcs_uri)
        if advanced_results:
            with open('advanced_features_results.json', 'w') as f:
                json.dump(advanced_results, f, indent=2, default=str)
            print("Advanced features results saved to: advanced_features_results.json")
        
        # Batch processing demo
        batch_files = [
            (test_audio, gcs_uri),
            ("commercial_sample.wav", f"gs://{bucket_name}/audio/commercial_sample.wav")
        ]
        
        batch_results = demo.batch_processing_with_threading(batch_files)
        
        with open('batch_processing_results.json', 'w') as f:
            json.dump(batch_results, f, indent=2, default=str)
        
        print("Batch processing results saved to: batch_processing_results.json")
    
    else:
        print(f"Test audio file {test_audio} not found. Please ensure audio files are available.")

if __name__ == "__main__":
    main()
EOF

# Install required dependencies
pip install google-cloud-speech google-cloud-storage

# Run client library demonstration
python client_library_method.py
```

---

## 🚀 Solution Method 4: REST API Direct Access

### Step 1: REST API Implementation

```bash
# Create REST API demonstration script
cat > rest_api_method.py << 'EOF'
import requests
import json
import base64
import time
import os
from google.auth.transport.requests import Request
from google.oauth2 import service_account

class SpeechRESTAPI:
    def __init__(self, credentials_path=None):
        self.base_url = "https://speech.googleapis.com/v1"
        
        if credentials_path:
            credentials = service_account.Credentials.from_service_account_file(
                credentials_path,
                scopes=['https://www.googleapis.com/auth/cloud-platform']
            )
        else:
            import google.auth
            credentials, _ = google.auth.default()
        
        credentials.refresh(Request())
        self.access_token = credentials.token
        
        self.headers = {
            'Authorization': f'Bearer {self.access_token}',
            'Content-Type': 'application/json'
        }
    
    def method1_synchronous_rest(self, audio_content, language_code="en-US"):
        """Method 1: Synchronous recognition via REST API"""
        print("=== REST API Method 1: Synchronous Recognition ===")
        
        # Encode audio content to base64
        audio_base64 = base64.b64encode(audio_content).decode('utf-8')
        
        # Prepare request payload
        payload = {
            "config": {
                "encoding": "LINEAR16",
                "sampleRateHertz": 16000,
                "languageCode": language_code,
                "enableAutomaticPunctuation": True,
                "enableWordTimeOffsets": True,
                "enableWordConfidence": True
            },
            "audio": {
                "content": audio_base64
            }
        }
        
        # Make REST API call
        url = f"{self.base_url}/speech:recognize"
        response = requests.post(url, headers=self.headers, json=payload)
        
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"REST API error: {response.status_code} - {response.text}")
    
    def method2_longrunning_rest(self, gcs_uri, language_code="en-US"):
        """Method 2: Long-running recognition via REST API"""
        print("=== REST API Method 2: Long-running Recognition ===")
        
        # Prepare request payload
        payload = {
            "config": {
                "encoding": "LINEAR16",
                "sampleRateHertz": 16000,
                "languageCode": language_code,
                "enableAutomaticPunctuation": True,
                "enableWordTimeOffsets": True,
                "enableSpeakerDiarization": True,
                "diarizationSpeakerCount": 2
            },
            "audio": {
                "uri": gcs_uri
            }
        }
        
        # Start long-running operation
        url = f"{self.base_url}/speech:longrunningrecognize"
        response = requests.post(url, headers=self.headers, json=payload)
        
        if response.status_code != 200:
            raise Exception(f"REST API error: {response.status_code} - {response.text}")
        
        operation_response = response.json()
        operation_name = operation_response['name']
        
        print(f"Operation started: {operation_name}")
        
        # Poll for completion
        operation_url = f"https://speech.googleapis.com/v1/operations/{operation_name}"
        
        while True:
            op_response = requests.get(operation_url, headers=self.headers)
            
            if op_response.status_code != 200:
                raise Exception(f"Operation polling error: {op_response.status_code}")
            
            operation_data = op_response.json()
            
            if operation_data.get('done', False):
                if 'error' in operation_data:
                    raise Exception(f"Operation failed: {operation_data['error']}")
                
                return operation_data.get('response', {})
            
            print("Operation still running...")
            time.sleep(5)
    
    def method3_batch_rest(self, requests_list):
        """Method 3: Batch processing via REST API"""
        print("=== REST API Method 3: Batch Processing ===")
        
        results = []
        
        for i, request_data in enumerate(requests_list):
            try:
                print(f"Processing request {i+1}/{len(requests_list)}")
                
                if 'uri' in request_data['audio']:
                    # Long-running for GCS URIs
                    result = self.method2_longrunning_rest(
                        request_data['audio']['uri'],
                        request_data['config'].get('languageCode', 'en-US')
                    )
                else:
                    # Synchronous for content
                    audio_content = base64.b64decode(request_data['audio']['content'])
                    result = self.method1_synchronous_rest(
                        audio_content,
                        request_data['config'].get('languageCode', 'en-US')
                    )
                
                results.append({
                    'request_index': i,
                    'status': 'success',
                    'result': result
                })
                
                # Rate limiting
                time.sleep(1)
                
            except Exception as e:
                results.append({
                    'request_index': i,
                    'status': 'error',
                    'error': str(e)
                })
        
        return results
    
    def advanced_rest_features(self, gcs_uri):
        """Demonstrate advanced REST API features"""
        print("=== REST API Advanced Features ===")
        
        payload = {
            "config": {
                "encoding": "LINEAR16",
                "sampleRateHertz": 16000,
                "languageCode": "en-US",
                "alternativeLanguageCodes": ["es-ES", "fr-FR"],
                "maxAlternatives": 3,
                "enableAutomaticPunctuation": True,
                "enableWordTimeOffsets": True,
                "enableWordConfidence": True,
                "enableSpeakerDiarization": True,
                "diarizationSpeakerCount": 3,
                "profanityFilter": True,
                "speechContexts": [
                    {
                        "phrases": [
                            "Google Cloud",
                            "Speech API",
                            "REST API",
                            "transcription"
                        ]
                    }
                ],
                "metadata": {
                    "interactionType": "DISCUSSION",
                    "microphoneDistance": "MIDFIELD",
                    "originalMediaType": "AUDIO",
                    "recordingDeviceType": "OTHER_OUTDOOR_DEVICE"
                }
            },
            "audio": {
                "uri": gcs_uri
            }
        }
        
        url = f"{self.base_url}/speech:recognize"
        response = requests.post(url, headers=self.headers, json=payload)
        
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"Advanced features error: {response.status_code} - {response.text}")
    
    def create_curl_examples(self, output_file="curl_examples.sh"):
        """Generate curl command examples"""
        
        curl_script = f"""#!/bin/bash

# REST API Examples using curl
# Generated Speech-to-Text API examples

ACCESS_TOKEN=$(gcloud auth print-access-token)
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${{PROJECT_ID}}-speech-3ways"

echo "=== Speech-to-Text REST API Examples ==="

# Example 1: Synchronous recognition
echo "1. Synchronous Recognition"
curl -X POST \\
     -H "Authorization: Bearer $ACCESS_TOKEN" \\
     -H "Content-Type: application/json" \\
     -d @- \\
     "https://speech.googleapis.com/v1/speech:recognize" << 'EOF'
{{
  "config": {{
    "encoding": "LINEAR16",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "enableAutomaticPunctuation": true
  }},
  "audio": {{
    "uri": "gs://$BUCKET_NAME/audio/english_sample.wav"
  }}
}}
EOF

echo ""

# Example 2: Long-running recognition
echo "2. Long-running Recognition"
curl -X POST \\
     -H "Authorization: Bearer $ACCESS_TOKEN" \\
     -H "Content-Type: application/json" \\
     -d @- \\
     "https://speech.googleapis.com/v1/speech:longrunningrecognize" << 'EOF'
{{
  "config": {{
    "encoding": "LINEAR16",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "enableAutomaticPunctuation": true,
    "enableSpeakerDiarization": true,
    "diarizationSpeakerCount": 2
  }},
  "audio": {{
    "uri": "gs://$BUCKET_NAME/audio/commercial_sample.wav"
  }}
}}
EOF

echo ""

# Example 3: Check operation status
echo "3. Check Operation Status (replace OPERATION_NAME)"
# curl -H "Authorization: Bearer $ACCESS_TOKEN" \\
#      "https://speech.googleapis.com/v1/operations/OPERATION_NAME"

echo "Examples complete!"
"""
        
        with open(output_file, 'w') as f:
            f.write(curl_script)
        
        os.chmod(output_file, 0o755)
        print(f"Curl examples saved to: {output_file}")

def main():
    """Main REST API demonstration"""
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-speech-3ways"
    
    # Initialize REST API client
    rest_client = SpeechRESTAPI()
    
    # Test synchronous recognition
    test_audio = "english_sample.wav"
    gcs_uri = f"gs://{bucket_name}/audio/english_sample.wav"
    
    results = {}
    
    if os.path.exists(test_audio):
        print("Starting REST API demonstrations...")
        
        # Method 1: Synchronous
        try:
            with open(test_audio, 'rb') as f:
                audio_content = f.read()
            
            sync_result = rest_client.method1_synchronous_rest(audio_content)
            results['synchronous'] = sync_result
            print("✓ Synchronous recognition completed")
        
        except Exception as e:
            print(f"✗ Synchronous recognition failed: {e}")
            results['synchronous'] = {'error': str(e)}
        
        # Method 2: Long-running
        try:
            longrun_result = rest_client.method2_longrunning_rest(gcs_uri)
            results['long_running'] = longrun_result
            print("✓ Long-running recognition completed")
        
        except Exception as e:
            print(f"✗ Long-running recognition failed: {e}")
            results['long_running'] = {'error': str(e)}
        
        # Advanced features
        try:
            advanced_result = rest_client.advanced_rest_features(gcs_uri)
            results['advanced_features'] = advanced_result
            print("✓ Advanced features demonstration completed")
        
        except Exception as e:
            print(f"✗ Advanced features failed: {e}")
            results['advanced_features'] = {'error': str(e)}
        
        # Save results
        with open('rest_api_results.json', 'w') as f:
            json.dump(results, f, indent=2, default=str)
        
        print("REST API results saved to: rest_api_results.json")
        
        # Generate curl examples
        rest_client.create_curl_examples()
    
    else:
        print(f"Test audio file {test_audio} not found")

if __name__ == "__main__":
    main()
EOF

# Run REST API demonstration
python rest_api_method.py
```

---

## 🚀 Solution Method 5: Performance Comparison

### Step 1: Comprehensive Comparison

```bash
# Create comparison analysis script
cat > method_comparison.py << 'EOF'
import time
import json
import subprocess
import os
from datetime import datetime
import matplotlib.pyplot as plt
import pandas as pd

class SpeechMethodComparison:
    def __init__(self, project_id, bucket_name):
        self.project_id = project_id
        self.bucket_name = bucket_name
        self.results = {
            'console': {},
            'cli': {},
            'client_library': {},
            'rest_api': {}
        }
    
    def measure_cli_performance(self, audio_files):
        """Measure CLI method performance"""
        print("=== Measuring CLI Performance ===")
        
        cli_results = []
        
        for audio_file in audio_files:
            start_time = time.time()
            
            try:
                cmd = [
                    "gcloud", "ml", "speech", "recognize",
                    "--audio-file-name", audio_file,
                    "--language-code", "en-US",
                    "--format", "json"
                ]
                
                result = subprocess.run(
                    cmd, 
                    capture_output=True, 
                    text=True, 
                    check=True,
                    timeout=300  # 5 minute timeout
                )
                
                processing_time = time.time() - start_time
                
                cli_results.append({
                    'file': audio_file,
                    'status': 'success',
                    'processing_time': processing_time,
                    'result_size': len(result.stdout)
                })
                
            except Exception as e:
                processing_time = time.time() - start_time
                cli_results.append({
                    'file': audio_file,
                    'status': 'error',
                    'processing_time': processing_time,
                    'error': str(e)
                })
        
        return cli_results
    
    def measure_client_library_performance(self, audio_files):
        """Measure client library performance"""
        print("=== Measuring Client Library Performance ===")
        
        from google.cloud import speech
        client = speech.SpeechClient()
        
        library_results = []
        
        for audio_file in audio_files:
            start_time = time.time()
            
            try:
                if audio_file.startswith('gs://'):
                    # GCS file
                    audio = speech.RecognitionAudio(uri=audio_file)
                else:
                    # Local file
                    with open(audio_file, 'rb') as f:
                        content = f.read()
                    audio = speech.RecognitionAudio(content=content)
                
                config = speech.RecognitionConfig(
                    encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
                    sample_rate_hertz=16000,
                    language_code="en-US",
                )
                
                response = client.recognize(config=config, audio=audio)
                processing_time = time.time() - start_time
                
                library_results.append({
                    'file': audio_file,
                    'status': 'success',
                    'processing_time': processing_time,
                    'result_count': len(response.results)
                })
                
            except Exception as e:
                processing_time = time.time() - start_time
                library_results.append({
                    'file': audio_file,
                    'status': 'error',
                    'processing_time': processing_time,
                    'error': str(e)
                })
        
        return library_results
    
    def measure_rest_api_performance(self, audio_files):
        """Measure REST API performance"""
        print("=== Measuring REST API Performance ===")
        
        import requests
        from google.auth.transport.requests import Request
        import google.auth
        import base64
        
        # Get access token
        credentials, _ = google.auth.default()
        credentials.refresh(Request())
        access_token = credentials.token
        
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json'
        }
        
        rest_results = []
        
        for audio_file in audio_files:
            start_time = time.time()
            
            try:
                if audio_file.startswith('gs://'):
                    # GCS URI
                    payload = {
                        "config": {
                            "encoding": "LINEAR16",
                            "sampleRateHertz": 16000,
                            "languageCode": "en-US"
                        },
                        "audio": {
                            "uri": audio_file
                        }
                    }
                else:
                    # Local file
                    with open(audio_file, 'rb') as f:
                        content = f.read()
                    
                    audio_base64 = base64.b64encode(content).decode('utf-8')
                    payload = {
                        "config": {
                            "encoding": "LINEAR16",
                            "sampleRateHertz": 16000,
                            "languageCode": "en-US"
                        },
                        "audio": {
                            "content": audio_base64
                        }
                    }
                
                response = requests.post(
                    "https://speech.googleapis.com/v1/speech:recognize",
                    headers=headers,
                    json=payload,
                    timeout=300
                )
                
                processing_time = time.time() - start_time
                
                if response.status_code == 200:
                    result_data = response.json()
                    rest_results.append({
                        'file': audio_file,
                        'status': 'success',
                        'processing_time': processing_time,
                        'result_count': len(result_data.get('results', []))
                    })
                else:
                    rest_results.append({
                        'file': audio_file,
                        'status': 'error',
                        'processing_time': processing_time,
                        'error': f"HTTP {response.status_code}"
                    })
                
            except Exception as e:
                processing_time = time.time() - start_time
                rest_results.append({
                    'file': audio_file,
                    'status': 'error',
                    'processing_time': processing_time,
                    'error': str(e)
                })
        
        return rest_results
    
    def create_performance_report(self, all_results):
        """Create comprehensive performance report"""
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'summary': {},
            'detailed_results': all_results,
            'recommendations': {}
        }
        
        # Calculate summary statistics
        for method, results in all_results.items():
            if results:
                successful_results = [r for r in results if r['status'] == 'success']
                
                if successful_results:
                    processing_times = [r['processing_time'] for r in successful_results]
                    
                    report['summary'][method] = {
                        'total_files': len(results),
                        'successful_files': len(successful_results),
                        'success_rate': len(successful_results) / len(results),
                        'average_processing_time': sum(processing_times) / len(processing_times),
                        'min_processing_time': min(processing_times),
                        'max_processing_time': max(processing_times)
                    }
                else:
                    report['summary'][method] = {
                        'total_files': len(results),
                        'successful_files': 0,
                        'success_rate': 0.0,
                        'average_processing_time': 0.0
                    }
        
        # Generate recommendations
        if report['summary']:
            fastest_method = min(
                report['summary'].items(),
                key=lambda x: x[1]['average_processing_time']
            )[0]
            
            most_reliable = max(
                report['summary'].items(),
                key=lambda x: x[1]['success_rate']
            )[0]
            
            report['recommendations'] = {
                'fastest_method': fastest_method,
                'most_reliable_method': most_reliable,
                'use_cases': {
                    'console': 'Best for: Manual transcription, exploring features, one-off tasks',
                    'cli': 'Best for: Scripting, automation, batch processing in shell scripts',
                    'client_library': 'Best for: Application integration, complex processing, real-time applications',
                    'rest_api': 'Best for: Language-agnostic integration, microservices, web applications'
                }
            }
        
        return report
    
    def create_visualization(self, performance_report):
        """Create performance visualization"""
        try:
            import matplotlib.pyplot as plt
            import pandas as pd
            
            # Extract data for visualization
            methods = []
            avg_times = []
            success_rates = []
            
            for method, stats in performance_report['summary'].items():
                methods.append(method.replace('_', ' ').title())
                avg_times.append(stats['average_processing_time'])
                success_rates.append(stats['success_rate'] * 100)
            
            # Create subplots
            fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
            
            # Processing time comparison
            ax1.bar(methods, avg_times, color=['blue', 'green', 'red', 'orange'])
            ax1.set_title('Average Processing Time by Method')
            ax1.set_ylabel('Time (seconds)')
            ax1.tick_params(axis='x', rotation=45)
            
            # Success rate comparison
            ax2.bar(methods, success_rates, color=['blue', 'green', 'red', 'orange'])
            ax2.set_title('Success Rate by Method')
            ax2.set_ylabel('Success Rate (%)')
            ax2.set_ylim(0, 100)
            ax2.tick_params(axis='x', rotation=45)
            
            plt.tight_layout()
            plt.savefig('speech_methods_comparison.png', dpi=300, bbox_inches='tight')
            plt.close()
            
            print("Visualization saved to: speech_methods_comparison.png")
            
        except ImportError:
            print("Matplotlib not available. Skipping visualization.")
        except Exception as e:
            print(f"Error creating visualization: {e}")

def main():
    """Main comparison function"""
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-speech-3ways"
    
    comparison = SpeechMethodComparison(project_id, bucket_name)
    
    # Test files
    test_files = [
        "english_sample.wav",
        f"gs://{bucket_name}/audio/english_sample.wav"
    ]
    
    # Only test files that exist
    available_files = []
    for file in test_files:
        if file.startswith('gs://') or os.path.exists(file):
            available_files.append(file)
    
    if not available_files:
        print("No test files available. Please ensure audio files are prepared.")
        return
    
    print(f"Testing with files: {available_files}")
    
    all_results = {}
    
    # Test CLI method
    try:
        cli_results = comparison.measure_cli_performance(available_files)
        all_results['cli'] = cli_results
        print("✓ CLI performance measured")
    except Exception as e:
        print(f"✗ CLI performance measurement failed: {e}")
        all_results['cli'] = []
    
    # Test Client Library method
    try:
        library_results = comparison.measure_client_library_performance(available_files)
        all_results['client_library'] = library_results
        print("✓ Client library performance measured")
    except Exception as e:
        print(f"✗ Client library performance measurement failed: {e}")
        all_results['client_library'] = []
    
    # Test REST API method
    try:
        rest_results = comparison.measure_rest_api_performance(available_files)
        all_results['rest_api'] = rest_results
        print("✓ REST API performance measured")
    except Exception as e:
        print(f"✗ REST API performance measurement failed: {e}")
        all_results['rest_api'] = []
    
    # Create performance report
    performance_report = comparison.create_performance_report(all_results)
    
    # Save report
    with open('speech_methods_performance_report.json', 'w') as f:
        json.dump(performance_report, f, indent=2, default=str)
    
    print("Performance report saved to: speech_methods_performance_report.json")
    
    # Create visualization
    comparison.create_visualization(performance_report)
    
    # Print summary
    print("\n=== Performance Summary ===")
    for method, stats in performance_report['summary'].items():
        print(f"{method.replace('_', ' ').title()}:")
        print(f"  Success Rate: {stats['success_rate']:.1%}")
        print(f"  Avg Time: {stats['average_processing_time']:.2f}s")
        print()
    
    if 'recommendations' in performance_report:
        print("=== Recommendations ===")
        print(f"Fastest Method: {performance_report['recommendations']['fastest_method']}")
        print(f"Most Reliable: {performance_report['recommendations']['most_reliable_method']}")

if __name__ == "__main__":
    main()
EOF

# Install additional dependencies for visualization
pip install matplotlib pandas

# Run performance comparison
python method_comparison.py
```

---

## ✅ Validation

### Verify All Three Methods

```bash
# Test all methods systematically
echo "=== Testing All Speech-to-Text Methods ==="

# 1. Verify CLI method
echo "1. Testing CLI method..."
if [ -f "english_sample.wav" ]; then
    gcloud ml speech recognize \
        --audio-file-name="english_sample.wav" \
        --language-code="en-US" \
        --format=json > cli_test_result.json
    echo "✓ CLI method tested"
else
    echo "⚠ CLI test skipped - no local audio file"
fi

# 2. Test client library
echo "2. Testing client library..."
python -c "
from google.cloud import speech
client = speech.SpeechClient()
print('✓ Client library initialized successfully')
"

# 3. Test REST API
echo "3. Testing REST API..."
ACCESS_TOKEN=$(gcloud auth print-access-token)
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
     "https://speech.googleapis.com/v1/speech:recognize" \
     -H "Content-Type: application/json" \
     -d '{}' > /dev/null && echo "✓ REST API accessible"

# 4. Run comprehensive comparison
echo "4. Running performance comparison..."
python method_comparison.py

echo "=== All Methods Validated ==="
```

---

## 🔧 Troubleshooting

**Issue**: Authentication errors across methods
- Verify service account permissions
- Check API enablement
- Refresh access tokens

**Issue**: Audio format compatibility
- Verify encoding settings
- Check sample rate requirements
- Test with different formats

**Issue**: Performance differences
- Consider file size impact
- Check network latency
- Review quota limitations

---

## 📚 Key Learning Points

- **Method Selection**: Choose based on use case and requirements
- **Performance Trade-offs**: Speed vs features vs ease of use
- **Authentication**: Different auth patterns for each method
- **Integration Patterns**: How to integrate into different architectures
- **Best Practices**: Optimization techniques for each approach

---

## 🏆 Challenge Complete!

You've successfully explored Speech-to-Text API through three different approaches:
- ✅ Google Cloud Console for manual transcription
- ✅ Command line interface for scripting and automation
- ✅ Client libraries for application integration
- ✅ REST API for direct HTTP access
- ✅ Performance comparison and optimization

<div align="center">

**🎉 Congratulations! You've completed ARC132!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC114%20Natural%20Language-blue?style=for-the-badge)](../13-ARC114-Google-Cloud-Natural-Language-API-Challenge-Lab/)

</div>
