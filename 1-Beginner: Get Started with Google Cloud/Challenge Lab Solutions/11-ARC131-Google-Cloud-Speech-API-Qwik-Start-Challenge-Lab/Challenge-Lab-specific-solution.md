# ARC131: Google Cloud Speech API: Qwik Start: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Speech API](https://img.shields.io/badge/Speech%20API-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC131 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll use the Google Cloud Speech-to-Text API to transcribe audio files, work with different audio formats, and implement real-time speech recognition.

## 📋 Challenge Tasks

### Task 1: Enable Speech API and Setup

Enable the Speech-to-Text API and configure authentication.

### Task 2: Basic Audio Transcription

Transcribe a simple audio file using the API.

### Task 3: Advanced Audio Processing

Handle different audio formats and languages.

### Task 4: Real-time Speech Recognition

Implement streaming speech recognition.

### Task 5: Custom Speech Models

Configure and use custom speech models.

---

## 🚀 Solution Method 1: API Setup and Basic Transcription

### Step 1: Environment Setup

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME=${PROJECT_ID}-speech-demo
export REGION=us-central1

# Enable Speech API
gcloud services enable speech.googleapis.com

# Create service account
gcloud iam service-accounts create speech-api-sa \
    --description="Service account for Speech API demo" \
    --display-name="Speech API Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:speech-api-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/speech.editor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:speech-api-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Create and download key
gcloud iam service-accounts keys create speech-api-key.json \
    --iam-account=speech-api-sa@$PROJECT_ID.iam.gserviceaccount.com

# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=speech-api-key.json

# Create bucket for audio files
gsutil mb -l $REGION gs://$BUCKET_NAME
```

### Step 2: Download Sample Audio Files

```bash
# Create audio samples directory
mkdir ~/speech-samples
cd ~/speech-samples

# Download sample audio files from public sources
curl -o sample1.wav "https://storage.googleapis.com/cloud-samples-data/speech/hello.wav"
curl -o sample2.flac "https://storage.googleapis.com/cloud-samples-data/speech/commercial_mono.wav"

# Create a simple text-to-speech audio for testing
echo "Hello, this is a test of the Google Cloud Speech API. The API can transcribe audio files in multiple languages and formats." > test_text.txt

# Upload audio files to bucket
gsutil cp *.wav gs://$BUCKET_NAME/audio/
gsutil cp *.flac gs://$BUCKET_NAME/audio/
```

### Step 3: Basic Speech Recognition

```bash
# Create basic speech recognition script
cat > basic_speech_recognition.py << 'EOF'
from google.cloud import speech
import io
import sys

def transcribe_file(speech_file):
    """Transcribe the given audio file."""
    client = speech.SpeechClient()

    # Load the audio file
    with io.open(speech_file, "rb") as audio_file:
        content = audio_file.read()

    audio = speech.RecognitionAudio(content=content)
    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code="en-US",
    )

    # Perform the transcription
    response = client.recognize(config=config, audio=audio)

    # Print the results
    for result in response.results:
        print(f"Transcript: {result.alternatives[0].transcript}")
        print(f"Confidence: {result.alternatives[0].confidence}")

def transcribe_gcs_file(gcs_uri):
    """Transcribe the given audio file in Google Cloud Storage."""
    client = speech.SpeechClient()

    audio = speech.RecognitionAudio(uri=gcs_uri)
    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code="en-US",
    )

    # Perform the transcription
    response = client.recognize(config=config, audio=audio)

    # Print the results
    print(f"Transcribing: {gcs_uri}")
    for result in response.results:
        print(f"Transcript: {result.alternatives[0].transcript}")
        print(f"Confidence: {result.alternatives[0].confidence}")

def main():
    if len(sys.argv) > 1:
        if sys.argv[1].startswith('gs://'):
            transcribe_gcs_file(sys.argv[1])
        else:
            transcribe_file(sys.argv[1])
    else:
        # Default test with GCS file
        bucket_name = os.environ.get('BUCKET_NAME', 'your-bucket-name')
        gcs_uri = f"gs://{bucket_name}/audio/sample1.wav"
        transcribe_gcs_file(gcs_uri)

if __name__ == "__main__":
    import os
    main()
EOF

# Install dependencies
pip install google-cloud-speech

# Test basic transcription
export BUCKET_NAME=$BUCKET_NAME
python basic_speech_recognition.py
```

---

## 🚀 Solution Method 2: Advanced Audio Processing

### Step 1: Multi-format Audio Processing

```bash
# Create advanced speech processing script
cat > advanced_speech_processing.py << 'EOF'
from google.cloud import speech
from google.cloud import storage
import os
import json
from typing import List, Dict, Any

class AdvancedSpeechProcessor:
    def __init__(self, project_id: str):
        self.project_id = project_id
        self.speech_client = speech.SpeechClient()
        self.storage_client = storage.Client()
        
    def detect_audio_properties(self, gcs_uri: str) -> Dict[str, Any]:
        """Detect audio file properties for optimal configuration"""
        # This is a simplified version - in practice, you'd use audio libraries
        # to detect actual properties
        properties = {
            'encoding': speech.RecognitionConfig.AudioEncoding.LINEAR16,
            'sample_rate_hertz': 16000,
            'audio_channel_count': 1
        }
        
        # Detect encoding from file extension
        if gcs_uri.endswith('.flac'):
            properties['encoding'] = speech.RecognitionConfig.AudioEncoding.FLAC
        elif gcs_uri.endswith('.mp3'):
            properties['encoding'] = speech.RecognitionConfig.AudioEncoding.MP3
        elif gcs_uri.endswith('.wav'):
            properties['encoding'] = speech.RecognitionConfig.AudioEncoding.LINEAR16
        elif gcs_uri.endswith('.ogg'):
            properties['encoding'] = speech.RecognitionConfig.AudioEncoding.OGG_OPUS
        
        return properties
    
    def transcribe_with_enhanced_features(self, gcs_uri: str, language_code: str = "en-US") -> Dict[str, Any]:
        """Transcribe audio with enhanced features"""
        
        # Detect audio properties
        audio_properties = self.detect_audio_properties(gcs_uri)
        
        audio = speech.RecognitionAudio(uri=gcs_uri)
        config = speech.RecognitionConfig(
            encoding=audio_properties['encoding'],
            sample_rate_hertz=audio_properties['sample_rate_hertz'],
            language_code=language_code,
            audio_channel_count=audio_properties['audio_channel_count'],
            enable_separate_recognition_per_channel=True,
            enable_automatic_punctuation=True,
            enable_word_time_offsets=True,
            enable_word_confidence=True,
            profanity_filter=True,
            speech_contexts=[
                speech.SpeechContext(
                    phrases=["Google Cloud", "Speech API", "machine learning", "artificial intelligence"]
                )
            ],
            metadata=speech.RecognitionMetadata(
                interaction_type=speech.RecognitionMetadata.InteractionType.DISCUSSION,
                microphone_distance=speech.RecognitionMetadata.MicrophoneDistance.NEARFIELD,
                original_media_type=speech.RecognitionMetadata.OriginalMediaType.AUDIO,
                recording_device_type=speech.RecognitionMetadata.RecordingDeviceType.OTHER_OUTDOOR_DEVICE,
            ),
        )
        
        # Perform transcription
        response = self.speech_client.recognize(config=config, audio=audio)
        
        # Process results
        results = {
            'transcripts': [],
            'word_details': [],
            'statistics': {
                'total_alternatives': 0,
                'average_confidence': 0.0,
                'total_words': 0
            }
        }
        
        total_confidence = 0.0
        total_alternatives = 0
        
        for result in response.results:
            for alternative in result.alternatives:
                transcript_data = {
                    'transcript': alternative.transcript,
                    'confidence': alternative.confidence,
                    'words': []
                }
                
                # Process word-level details
                for word_info in alternative.words:
                    word_data = {
                        'word': word_info.word,
                        'start_time': word_info.start_time.total_seconds(),
                        'end_time': word_info.end_time.total_seconds(),
                        'confidence': getattr(word_info, 'confidence', 0.0)
                    }
                    transcript_data['words'].append(word_data)
                    results['word_details'].append(word_data)
                
                results['transcripts'].append(transcript_data)
                total_confidence += alternative.confidence
                total_alternatives += 1
        
        # Calculate statistics
        if total_alternatives > 0:
            results['statistics']['average_confidence'] = total_confidence / total_alternatives
        results['statistics']['total_alternatives'] = total_alternatives
        results['statistics']['total_words'] = len(results['word_details'])
        
        return results
    
    def transcribe_multiple_languages(self, gcs_uri: str, languages: List[str]) -> Dict[str, Any]:
        """Transcribe audio with multiple language alternatives"""
        audio_properties = self.detect_audio_properties(gcs_uri)
        
        audio = speech.RecognitionAudio(uri=gcs_uri)
        config = speech.RecognitionConfig(
            encoding=audio_properties['encoding'],
            sample_rate_hertz=audio_properties['sample_rate_hertz'],
            language_code=languages[0],  # Primary language
            alternative_language_codes=languages[1:],  # Alternative languages
            enable_automatic_punctuation=True,
            enable_language_detection=True,
        )
        
        response = self.speech_client.recognize(config=config, audio=audio)
        
        results = {
            'language_results': [],
            'best_transcript': '',
            'detected_language': ''
        }
        
        best_confidence = 0.0
        
        for result in response.results:
            if hasattr(result, 'language_code'):
                results['detected_language'] = result.language_code
            
            for alternative in result.alternatives:
                if alternative.confidence > best_confidence:
                    best_confidence = alternative.confidence
                    results['best_transcript'] = alternative.transcript
                
                results['language_results'].append({
                    'transcript': alternative.transcript,
                    'confidence': alternative.confidence,
                    'language': getattr(result, 'language_code', 'unknown')
                })
        
        return results
    
    def batch_transcribe_files(self, gcs_uris: List[str]) -> Dict[str, Any]:
        """Batch transcribe multiple files"""
        results = {}
        
        for gcs_uri in gcs_uris:
            try:
                print(f"Processing: {gcs_uri}")
                file_results = self.transcribe_with_enhanced_features(gcs_uri)
                results[gcs_uri] = {
                    'status': 'success',
                    'data': file_results
                }
            except Exception as e:
                results[gcs_uri] = {
                    'status': 'error',
                    'error': str(e)
                }
        
        return results
    
    def save_results_to_gcs(self, results: Dict[str, Any], output_bucket: str, output_path: str):
        """Save transcription results to Google Cloud Storage"""
        bucket = self.storage_client.bucket(output_bucket)
        blob = bucket.blob(output_path)
        
        blob.upload_from_string(
            json.dumps(results, indent=2, ensure_ascii=False),
            content_type='application/json'
        )
        
        print(f"Results saved to gs://{output_bucket}/{output_path}")

def main():
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = os.environ.get('BUCKET_NAME')
    
    processor = AdvancedSpeechProcessor(project_id)
    
    # Test files
    test_files = [
        f"gs://{bucket_name}/audio/sample1.wav",
        f"gs://{bucket_name}/audio/sample2.flac"
    ]
    
    # Single file with enhanced features
    print("=== Enhanced Transcription ===")
    enhanced_results = processor.transcribe_with_enhanced_features(test_files[0])
    print(json.dumps(enhanced_results, indent=2))
    
    # Multi-language detection
    print("\n=== Multi-language Detection ===")
    languages = ["en-US", "es-ES", "fr-FR", "de-DE"]
    lang_results = processor.transcribe_multiple_languages(test_files[0], languages)
    print(json.dumps(lang_results, indent=2))
    
    # Batch processing
    print("\n=== Batch Processing ===")
    batch_results = processor.batch_transcribe_files(test_files)
    
    # Save results
    processor.save_results_to_gcs(
        batch_results, 
        bucket_name, 
        "results/batch_transcription_results.json"
    )

if __name__ == "__main__":
    main()
EOF

# Run advanced processing
python advanced_speech_processing.py
```

---

## 🚀 Solution Method 3: Real-time Speech Recognition

### Step 1: Streaming Speech Recognition

```bash
# Create streaming speech recognition script
cat > streaming_speech_recognition.py << 'EOF'
from google.cloud import speech
import pyaudio
import threading
import queue
import sys

class StreamingSpeechRecognizer:
    def __init__(self, rate=16000, chunk_size=1024):
        self.rate = rate
        self.chunk_size = chunk_size
        self.audio_queue = queue.Queue()
        self.is_recording = False
        
        # Audio configuration
        self.audio_format = pyaudio.paInt16
        self.channels = 1
        
        # Speech client
        self.client = speech.SpeechClient()
        
        # Recognition config
        self.config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=rate,
            language_code="en-US",
            enable_automatic_punctuation=True,
            enable_word_time_offsets=True,
        )
        
        # Streaming config
        self.streaming_config = speech.StreamingRecognitionConfig(
            config=self.config,
            interim_results=True,
            single_utterance=False,
        )
    
    def audio_generator(self):
        """Generate audio chunks for streaming"""
        while self.is_recording:
            try:
                chunk = self.audio_queue.get(timeout=1)
                if chunk is None:
                    return
                yield speech.StreamingRecognizeRequest(audio_content=chunk)
            except queue.Empty:
                continue
    
    def record_audio(self):
        """Record audio from microphone"""
        audio_interface = pyaudio.PyAudio()
        
        stream = audio_interface.open(
            format=self.audio_format,
            channels=self.channels,
            rate=self.rate,
            input=True,
            frames_per_buffer=self.chunk_size
        )
        
        print("Recording... Press Ctrl+C to stop")
        
        try:
            while self.is_recording:
                data = stream.read(self.chunk_size, exception_on_overflow=False)
                self.audio_queue.put(data)
        except KeyboardInterrupt:
            print("\nStopping recording...")
        finally:
            stream.stop_stream()
            stream.close()
            audio_interface.terminate()
    
    def start_streaming_recognition(self):
        """Start streaming speech recognition"""
        self.is_recording = True
        
        # Start audio recording in separate thread
        audio_thread = threading.Thread(target=self.record_audio)
        audio_thread.daemon = True
        audio_thread.start()
        
        try:
            # Start streaming recognition
            requests = self.audio_generator()
            responses = self.client.streaming_recognize(
                config=self.streaming_config,
                requests=requests
            )
            
            self.process_responses(responses)
            
        except KeyboardInterrupt:
            print("\nStopping recognition...")
        finally:
            self.is_recording = False
            self.audio_queue.put(None)  # Signal audio thread to stop
    
    def process_responses(self, responses):
        """Process streaming recognition responses"""
        for response in responses:
            if not response.results:
                continue
            
            result = response.results[0]
            
            if not result.alternatives:
                continue
            
            transcript = result.alternatives[0].transcript
            confidence = result.alternatives[0].confidence
            
            if result.is_final:
                print(f"Final: {transcript} (Confidence: {confidence:.2f})")
                print("-" * 50)
            else:
                print(f"Interim: {transcript}")

class FileSpeechStreamer:
    """Stream audio from file for demonstration"""
    
    def __init__(self, audio_file_path):
        self.audio_file_path = audio_file_path
        self.client = speech.SpeechClient()
        
        self.config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
            enable_automatic_punctuation=True,
        )
        
        self.streaming_config = speech.StreamingRecognitionConfig(
            config=self.config,
            interim_results=True,
        )
    
    def stream_file(self, chunk_size=1024):
        """Stream audio file for recognition"""
        with open(self.audio_file_path, 'rb') as audio_file:
            # Skip WAV header (44 bytes)
            audio_file.seek(44)
            
            def request_generator():
                while True:
                    chunk = audio_file.read(chunk_size)
                    if not chunk:
                        break
                    yield speech.StreamingRecognizeRequest(audio_content=chunk)
            
            requests = request_generator()
            responses = self.client.streaming_recognize(
                config=self.streaming_config,
                requests=requests
            )
            
            print(f"Streaming recognition for: {self.audio_file_path}")
            print("-" * 50)
            
            for response in responses:
                if not response.results:
                    continue
                
                result = response.results[0]
                
                if not result.alternatives:
                    continue
                
                transcript = result.alternatives[0].transcript
                
                if result.is_final:
                    confidence = result.alternatives[0].confidence
                    print(f"Final: {transcript} (Confidence: {confidence:.2f})")
                else:
                    print(f"Interim: {transcript}")

def main():
    print("Speech Recognition Options:")
    print("1. Real-time microphone recognition")
    print("2. File streaming recognition")
    
    try:
        choice = input("Enter your choice (1 or 2): ").strip()
        
        if choice == "1":
            recognizer = StreamingSpeechRecognizer()
            recognizer.start_streaming_recognition()
        
        elif choice == "2":
            file_path = input("Enter audio file path: ").strip()
            if not file_path:
                file_path = "sample1.wav"  # Default
            
            streamer = FileSpeechStreamer(file_path)
            streamer.stream_file()
        
        else:
            print("Invalid choice")
    
    except KeyboardInterrupt:
        print("\nExiting...")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
EOF

# Install required dependencies
pip install pyaudio

# Run streaming recognition (will prompt for choice)
python streaming_speech_recognition.py
```

---

## 🚀 Solution Method 4: Long Audio Transcription

### Step 1: Long-running Operations

```bash
# Create long audio transcription script
cat > long_audio_transcription.py << 'EOF'
from google.cloud import speech
from google.cloud.speech import enums
from google.cloud.speech import types
import time
import json

class LongAudioTranscriber:
    def __init__(self):
        self.client = speech.SpeechClient()
    
    def transcribe_long_audio(self, gcs_uri, output_gcs_uri=None):
        """Transcribe long audio file using long-running operation"""
        
        audio = speech.RecognitionAudio(uri=gcs_uri)
        
        # Enhanced configuration for long audio
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
            enable_automatic_punctuation=True,
            enable_word_time_offsets=True,
            enable_word_confidence=True,
            enable_speaker_diarization=True,
            diarization_speaker_count=2,
            profanity_filter=True,
            speech_contexts=[
                speech.SpeechContext(
                    phrases=["Google Cloud", "Speech API", "transcription", "audio processing"]
                )
            ],
        )
        
        # Output configuration
        if output_gcs_uri:
            output_config = speech.TranscriptOutputConfig(
                gcs_uri=output_gcs_uri
            )
            request = speech.LongRunningRecognizeRequest(
                config=config,
                audio=audio,
                output_config=output_config
            )
        else:
            request = speech.LongRunningRecognizeRequest(
                config=config,
                audio=audio
            )
        
        print(f"Starting long-running transcription for: {gcs_uri}")
        operation = self.client.long_running_recognize(request=request)
        
        print("Waiting for operation to complete...")
        response = operation.result(timeout=7200)  # 2 hours timeout
        
        # Process results
        results = {
            'transcripts': [],
            'speaker_segments': [],
            'word_details': [],
            'statistics': {
                'total_speakers': 0,
                'total_words': 0,
                'total_duration': 0.0,
                'average_confidence': 0.0
            }
        }
        
        total_confidence = 0.0
        confidence_count = 0
        speakers = set()
        
        for result in response.results:
            alternative = result.alternatives[0]
            
            # Main transcript
            transcript_data = {
                'transcript': alternative.transcript,
                'confidence': alternative.confidence,
                'channel_tag': getattr(result, 'channel_tag', 0)
            }
            results['transcripts'].append(transcript_data)
            
            # Word-level details with speaker information
            for word_info in alternative.words:
                speaker_tag = getattr(word_info, 'speaker_tag', 0)
                speakers.add(speaker_tag)
                
                word_data = {
                    'word': word_info.word,
                    'start_time': word_info.start_time.total_seconds(),
                    'end_time': word_info.end_time.total_seconds(),
                    'speaker_tag': speaker_tag,
                    'confidence': getattr(word_info, 'confidence', 0.0)
                }
                results['word_details'].append(word_data)
            
            # Update statistics
            total_confidence += alternative.confidence
            confidence_count += 1
        
        # Generate speaker segments
        current_speaker = None
        current_segment = None
        
        for word_data in results['word_details']:
            if word_data['speaker_tag'] != current_speaker:
                if current_segment:
                    results['speaker_segments'].append(current_segment)
                
                current_speaker = word_data['speaker_tag']
                current_segment = {
                    'speaker': current_speaker,
                    'start_time': word_data['start_time'],
                    'end_time': word_data['end_time'],
                    'words': [word_data['word']],
                    'text': word_data['word']
                }
            else:
                current_segment['end_time'] = word_data['end_time']
                current_segment['words'].append(word_data['word'])
                current_segment['text'] += ' ' + word_data['word']
        
        if current_segment:
            results['speaker_segments'].append(current_segment)
        
        # Final statistics
        results['statistics']['total_speakers'] = len(speakers)
        results['statistics']['total_words'] = len(results['word_details'])
        if results['word_details']:
            results['statistics']['total_duration'] = results['word_details'][-1]['end_time']
        if confidence_count > 0:
            results['statistics']['average_confidence'] = total_confidence / confidence_count
        
        return results
    
    def create_srt_subtitles(self, transcription_results, output_file):
        """Create SRT subtitle file from transcription results"""
        
        def format_time(seconds):
            """Format time for SRT format"""
            hours = int(seconds // 3600)
            minutes = int((seconds % 3600) // 60)
            secs = int(seconds % 60)
            millis = int((seconds % 1) * 1000)
            return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"
        
        with open(output_file, 'w', encoding='utf-8') as f:
            subtitle_index = 1
            
            # Group words into subtitle chunks (every 10 words or 5 seconds)
            word_groups = []
            current_group = []
            
            for word_data in transcription_results['word_details']:
                current_group.append(word_data)
                
                # Create subtitle every 10 words or when 5 seconds elapsed
                if (len(current_group) >= 10 or 
                    (current_group and word_data['end_time'] - current_group[0]['start_time'] >= 5.0)):
                    word_groups.append(current_group)
                    current_group = []
            
            if current_group:
                word_groups.append(current_group)
            
            # Generate SRT entries
            for group in word_groups:
                if not group:
                    continue
                
                start_time = format_time(group[0]['start_time'])
                end_time = format_time(group[-1]['end_time'])
                text = ' '.join([word['word'] for word in group])
                
                f.write(f"{subtitle_index}\n")
                f.write(f"{start_time} --> {end_time}\n")
                f.write(f"{text}\n\n")
                
                subtitle_index += 1
        
        print(f"SRT subtitles saved to: {output_file}")

def main():
    import os
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = os.environ.get('BUCKET_NAME')
    
    transcriber = LongAudioTranscriber()
    
    # Test with sample audio
    gcs_uri = f"gs://{bucket_name}/audio/sample1.wav"
    output_uri = f"gs://{bucket_name}/results/transcript_output.txt"
    
    try:
        print("Starting long audio transcription...")
        results = transcriber.transcribe_long_audio(gcs_uri, output_uri)
        
        # Save detailed results
        with open('detailed_transcription.json', 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        
        # Create SRT subtitles
        transcriber.create_srt_subtitles(results, 'subtitles.srt')
        
        # Print summary
        print("\n=== Transcription Summary ===")
        print(f"Total speakers detected: {results['statistics']['total_speakers']}")
        print(f"Total words: {results['statistics']['total_words']}")
        print(f"Total duration: {results['statistics']['total_duration']:.2f} seconds")
        print(f"Average confidence: {results['statistics']['average_confidence']:.2f}")
        
        print("\n=== Speaker Segments ===")
        for segment in results['speaker_segments'][:5]:  # Show first 5 segments
            print(f"Speaker {segment['speaker']} ({segment['start_time']:.1f}s-{segment['end_time']:.1f}s): {segment['text'][:100]}...")
        
    except Exception as e:
        print(f"Error during transcription: {e}")

if __name__ == "__main__":
    main()
EOF

# Run long audio transcription
python long_audio_transcription.py
```

---

## ✅ Validation

### Test All Speech API Features

```bash
# Test basic recognition
echo "Testing basic speech recognition..."
python basic_speech_recognition.py gs://$BUCKET_NAME/audio/sample1.wav

# Test advanced features
echo "Testing advanced speech processing..."
python advanced_speech_processing.py

# Test long audio transcription
echo "Testing long audio transcription..."
python long_audio_transcription.py

# Check output files
echo "Checking generated files..."
ls -la *.json *.srt

# Verify bucket contents
echo "Checking bucket contents..."
gsutil ls -r gs://$BUCKET_NAME/

# Test API quota and usage
gcloud logging read "resource.type=api AND protoPayload.serviceName=speech.googleapis.com" --limit=10
```

---

## 🔧 Troubleshooting

**Issue**: Audio format not supported
- Check encoding parameters
- Verify sample rate settings
- Convert audio format if needed

**Issue**: Low transcription accuracy
- Check audio quality
- Add speech contexts for domain-specific terms
- Adjust language settings

**Issue**: Long-running operation timeout
- Increase timeout values
- Check audio file size limits
- Monitor operation status

---

## 📚 Key Learning Points

- **Audio Formats**: Supporting multiple audio formats and encodings
- **Enhanced Features**: Punctuation, confidence scores, word timing
- **Speaker Diarization**: Identifying different speakers
- **Real-time Processing**: Streaming speech recognition
- **Long Audio**: Handling long-duration audio files

---

## 🏆 Challenge Complete!

You've successfully mastered Google Cloud Speech API with:
- ✅ Basic audio transcription setup
- ✅ Advanced audio processing with enhanced features
- ✅ Real-time streaming speech recognition
- ✅ Long audio transcription with speaker diarization
- ✅ Output formatting (JSON, SRT subtitles)

<div align="center">

**🎉 Congratulations! You've completed ARC131!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC132%20Speech%20to%20Text-blue?style=for-the-badge)](../12-ARC132-Speech-to-Text-API-3-Ways-Challenge-Lab/)

</div>
