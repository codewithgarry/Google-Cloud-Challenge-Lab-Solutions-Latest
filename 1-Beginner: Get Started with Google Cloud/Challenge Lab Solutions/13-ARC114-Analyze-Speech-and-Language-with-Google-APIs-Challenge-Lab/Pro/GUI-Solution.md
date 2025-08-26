# Google Cloud Natural Language API - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Natural Language](https://img.shields.io/badge/Natural%20Language-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)

**Lab ID**: ARC114 | **Duration**: 20-25 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Lab Overview

Explore Google Cloud Natural Language API for text analysis, sentiment analysis, entity extraction, and syntax analysis.

---

## 🧩 Challenge Tasks

1. **Enable Natural Language API** - Activate the service
2. **Sentiment Analysis** - Analyze text sentiment and scores
3. **Entity Analysis** - Extract entities and their metadata
4. **Syntax Analysis** - Parse text structure and grammar
5. **Classification** - Categorize content into predefined classes
6. **Batch Processing** - Analyze multiple documents

---

## 🖥️ Step-by-Step GUI Solution

### 📋 Prerequisites
- Google Cloud Console access
- Cloud Shell activated
- Natural Language API enabled

---

### 🚀 Task 1: Setup Environment

1. **Enable APIs**
   - Go to: **APIs & Services** → **Library**
   - Search and enable: `Cloud Natural Language API`
   - Search and enable: `Cloud Storage API`

2. **Open Cloud Shell**
   - Click **Activate Cloud Shell** (top-right)
   - Wait for shell to initialize

3. **Set Environment Variables**
   ```bash
   export PROJECT_ID=$(gcloud config get-value project)
   export BUCKET_NAME="$PROJECT_ID-nlp-lab"
   export REGION="us-central1"
   ```

![Setup Environment](https://via.placeholder.com/600x300/4285F4/FFFFFF?text=Setup+Environment)

---

### 📦 Task 2: Prepare Test Data

1. **Create Storage Bucket**
   ```bash
   gsutil mb -l $REGION gs://$BUCKET_NAME
   ```

2. **Create Sample Text Files**
   ```bash
   # Positive sentiment text
   cat > positive_review.txt << 'EOF'
   This product is absolutely amazing! I love the design and the quality is outstanding. 
   The customer service was excellent and delivery was super fast. 
   I would definitely recommend this to all my friends and family. 
   Best purchase I've made this year!
   EOF
   
   # Negative sentiment text
   cat > negative_review.txt << 'EOF'
   This product is terrible and completely disappointing. The quality is very poor 
   and it broke after just one day of use. Customer service was unhelpful and rude. 
   I want my money back immediately. This was a waste of money and time.
   EOF
   
   # News article text
   cat > news_article.txt << 'EOF'
   Google announced today that their new artificial intelligence technology 
   will be integrated into Google Cloud Platform services. The CEO, Sundar Pichai, 
   stated that this will revolutionize how businesses analyze data. 
   The technology will be available in the United States, Europe, and Asia 
   starting next month. Microsoft and Amazon are also developing similar technologies.
   EOF
   
   # Technical documentation
   cat > technical_doc.txt << 'EOF'
   The implementation involves configuring OAuth 2.0 authentication with Google Cloud APIs. 
   First, create a service account in the Google Cloud Console. 
   Then, download the JSON key file and set the GOOGLE_APPLICATION_CREDENTIALS 
   environment variable. Finally, use the client libraries to make API calls 
   with proper error handling and retry mechanisms.
   EOF
   ```

3. **Upload Files to Storage**
   ```bash
   gsutil cp *.txt gs://$BUCKET_NAME/
   gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/*
   ```

![Prepare Data](https://via.placeholder.com/600x300/34A853/FFFFFF?text=Prepare+Test+Data)

---

### 😊 Task 3: Sentiment Analysis

1. **Using Google Cloud Console**
   - Navigate to: **Artificial Intelligence** → **Natural Language**
   - Click **"Try the API"**
   - Select **"Analyze Sentiment"**
   - Paste text from `positive_review.txt`
   - Click **"Analyze"**

2. **Using Cloud Shell REST API**
   ```bash
   # Get authentication token
   export ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
   
   # Create sentiment analysis request
   cat > sentiment_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$(cat positive_review.txt | tr '\n' ' ')"
     },
     "encodingType": "UTF8"
   }
   EOF
   
   # Call Sentiment Analysis API
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://language.googleapis.com/v1/documents:analyzeSentiment" \
     -d @sentiment_request.json > sentiment_response.json
   
   # Display results
   echo "=== Sentiment Analysis Results ==="
   jq '.documentSentiment' sentiment_response.json
   ```

3. **Analyze Multiple Sentiments**
   ```bash
   # Function to analyze sentiment
   analyze_sentiment() {
       local file=$1
       local content=$(cat "$file" | tr '\n' ' ')
       
       cat > temp_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$content"
     },
     "encodingType": "UTF8"
   }
   EOF
       
       curl -s -X POST \
         -H "Authorization: Bearer $ACCESS_TOKEN" \
         -H "Content-Type: application/json" \
         "https://language.googleapis.com/v1/documents:analyzeSentiment" \
         -d @temp_request.json
   }
   
   # Analyze all text files
   echo "=== Analyzing All Documents ==="
   for file in *.txt; do
       echo "File: $file"
       analyze_sentiment "$file" | jq '.documentSentiment | {score: .score, magnitude: .magnitude}'
       echo "---"
   done
   ```

![Sentiment Analysis](https://via.placeholder.com/600x300/FF9800/FFFFFF?text=Sentiment+Analysis)

---

### 🏷️ Task 4: Entity Analysis

1. **Extract Entities from News Article**
   ```bash
   # Create entity analysis request
   cat > entity_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$(cat news_article.txt | tr '\n' ' ')"
     },
     "encodingType": "UTF8"
   }
   EOF
   
   # Call Entity Analysis API
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://language.googleapis.com/v1/documents:analyzeEntities" \
     -d @entity_request.json > entity_response.json
   
   # Display entities
   echo "=== Entity Analysis Results ==="
   jq '.entities[] | {name: .name, type: .type, salience: .salience}' entity_response.json
   ```

2. **Advanced Entity Analysis**
   ```bash
   # Extract entities with metadata
   echo "=== Detailed Entity Information ==="
   jq '.entities[] | {
     name: .name,
     type: .type,
     salience: .salience,
     mentions: [.mentions[] | {text: .text.content, type: .type}],
     metadata: .metadata
   }' entity_response.json
   
   # Count entities by type
   echo "=== Entity Count by Type ==="
   jq '.entities | group_by(.type) | map({type: .[0].type, count: length})' entity_response.json
   ```

3. **Test with Different Content Types**
   ```bash
   # Function to analyze entities
   analyze_entities() {
       local file=$1
       local content=$(cat "$file" | tr '\n' ' ')
       
       cat > temp_entity_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$content"
     },
     "encodingType": "UTF8"
   }
   EOF
       
       curl -s -X POST \
         -H "Authorization: Bearer $ACCESS_TOKEN" \
         -H "Content-Type: application/json" \
         "https://language.googleapis.com/v1/documents:analyzeEntities" \
         -d @temp_entity_request.json
   }
   
   # Analyze entities in all files
   for file in *.txt; do
       echo "=== Entities in $file ==="
       analyze_entities "$file" | jq '.entities[] | {name: .name, type: .type, salience: .salience}' | head -10
       echo ""
   done
   ```

![Entity Analysis](https://via.placeholder.com/600x300/9C27B0/FFFFFF?text=Entity+Analysis)

---

### 🔍 Task 5: Syntax Analysis

1. **Analyze Text Syntax**
   ```bash
   # Create syntax analysis request
   cat > syntax_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$(cat technical_doc.txt | tr '\n' ' ')"
     },
     "encodingType": "UTF8"
   }
   EOF
   
   # Call Syntax Analysis API
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://language.googleapis.com/v1/documents:analyzeSyntax" \
     -d @syntax_request.json > syntax_response.json
   
   # Display syntax information
   echo "=== Syntax Analysis Results ==="
   jq '.tokens[] | {text: .text.content, partOfSpeech: .partOfSpeech.tag, lemma: .lemma}' syntax_response.json | head -20
   ```

2. **Part-of-Speech Analysis**
   ```bash
   # Count parts of speech
   echo "=== Part of Speech Distribution ==="
   jq '.tokens | group_by(.partOfSpeech.tag) | map({pos: .[0].partOfSpeech.tag, count: length}) | sort_by(.count) | reverse' syntax_response.json
   
   # Extract specific POS types
   echo "=== Nouns ==="
   jq '.tokens[] | select(.partOfSpeech.tag == "NOUN") | .text.content' syntax_response.json
   
   echo "=== Verbs ==="
   jq '.tokens[] | select(.partOfSpeech.tag == "VERB") | .text.content' syntax_response.json
   ```

3. **Dependency Analysis**
   ```bash
   # Analyze sentence structure
   echo "=== Dependency Analysis ==="
   jq '.tokens[] | {
     text: .text.content,
     headTokenIndex: .dependencyEdge.headTokenIndex,
     label: .dependencyEdge.label
   }' syntax_response.json | head -15
   
   # Find sentence boundaries
   echo "=== Sentences ==="
   jq '.sentences[] | {text: .text.content, sentiment: .sentiment}' syntax_response.json
   ```

![Syntax Analysis](https://via.placeholder.com/600x300/2196F3/FFFFFF?text=Syntax+Analysis)

---

### 📊 Task 6: Text Classification

1. **Classify Content**
   ```bash
   # Create classification request
   cat > classification_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$(cat news_article.txt | tr '\n' ' ')"
     }
   }
   EOF
   
   # Call Classification API
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://language.googleapis.com/v1/documents:classifyText" \
     -d @classification_request.json > classification_response.json
   
   # Display classification results
   echo "=== Text Classification Results ==="
   jq '.categories[] | {name: .name, confidence: .confidence}' classification_response.json
   ```

2. **Classify Multiple Documents**
   ```bash
   # Function to classify text
   classify_text() {
       local file=$1
       local content=$(cat "$file" | tr '\n' ' ')
       
       # Skip if content is too short
       if [ ${#content} -lt 20 ]; then
           echo "Content too short for classification"
           return
       fi
       
       cat > temp_class_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$content"
     }
   }
   EOF
       
       curl -s -X POST \
         -H "Authorization: Bearer $ACCESS_TOKEN" \
         -H "Content-Type: application/json" \
         "https://language.googleapis.com/v1/documents:classifyText" \
         -d @temp_class_request.json
   }
   
   # Classify all documents
   for file in *.txt; do
       echo "=== Classification for $file ==="
       result=$(classify_text "$file")
       if echo "$result" | jq -e '.categories' > /dev/null 2>&1; then
           echo "$result" | jq '.categories[] | {name: .name, confidence: .confidence}'
       else
           echo "No classification available or content too short"
       fi
       echo ""
   done
   ```

![Text Classification](https://via.placeholder.com/600x300/607D8B/FFFFFF?text=Text+Classification)

---

### 🔄 Task 7: Comprehensive Analysis

1. **Multi-Feature Analysis**
   ```bash
   # Create comprehensive analysis request
   cat > comprehensive_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$(cat news_article.txt | tr '\n' ' ')"
     },
     "features": {
       "extractSyntax": true,
       "extractEntities": true,
       "extractDocumentSentiment": true,
       "extractEntitySentiment": true,
       "classifyText": true
     },
     "encodingType": "UTF8"
   }
   EOF
   
   # Call comprehensive annotation API
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://language.googleapis.com/v1/documents:annotateText" \
     -d @comprehensive_request.json > comprehensive_response.json
   
   echo "=== Comprehensive Analysis Results ==="
   echo "Document Sentiment:"
   jq '.documentSentiment' comprehensive_response.json
   
   echo -e "\nTop Entities:"
   jq '.entities[:5] | .[] | {name: .name, type: .type, salience: .salience}' comprehensive_response.json
   
   echo -e "\nClassification:"
   jq '.categories[]? | {name: .name, confidence: .confidence}' comprehensive_response.json
   ```

2. **Create Analysis Report**
   ```bash
   cat > analysis_report.py << 'EOF'
   #!/usr/bin/env python3
   
   import json
   import sys
   from datetime import datetime
   
   def create_analysis_report(response_file):
       with open(response_file, 'r') as f:
           data = json.load(f)
       
       print("="*60)
       print("NATURAL LANGUAGE API ANALYSIS REPORT")
       print("="*60)
       print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
       print()
       
       # Document sentiment
       if 'documentSentiment' in data:
           sentiment = data['documentSentiment']
           print("DOCUMENT SENTIMENT:")
           print(f"  Score: {sentiment.get('score', 'N/A')}")
           print(f"  Magnitude: {sentiment.get('magnitude', 'N/A')}")
           
           # Interpret sentiment
           score = sentiment.get('score', 0)
           if score > 0.2:
               interpretation = "Positive"
           elif score < -0.2:
               interpretation = "Negative"
           else:
               interpretation = "Neutral"
           print(f"  Interpretation: {interpretation}")
           print()
       
       # Entities
       if 'entities' in data:
           entities = data['entities']
           print(f"ENTITIES FOUND ({len(entities)}):")
           
           # Group by type
           entity_types = {}
           for entity in entities:
               entity_type = entity.get('type', 'UNKNOWN')
               if entity_type not in entity_types:
                   entity_types[entity_type] = []
               entity_types[entity_type].append(entity)
           
           for entity_type, type_entities in entity_types.items():
               print(f"  {entity_type}:")
               for entity in sorted(type_entities, key=lambda x: x.get('salience', 0), reverse=True)[:3]:
                   print(f"    - {entity.get('name')} (salience: {entity.get('salience', 0):.3f})")
           print()
       
       # Classification
       if 'categories' in data:
           categories = data['categories']
           print(f"CONTENT CLASSIFICATION ({len(categories)}):")
           for category in sorted(categories, key=lambda x: x.get('confidence', 0), reverse=True):
               print(f"  - {category.get('name')} (confidence: {category.get('confidence', 0):.3f})")
           print()
       
       # Language detection
       if 'language' in data:
           print(f"DETECTED LANGUAGE: {data['language']}")
           print()
       
       # Syntax summary
       if 'tokens' in data:
           tokens = data['tokens']
           pos_counts = {}
           for token in tokens:
               pos = token.get('partOfSpeech', {}).get('tag', 'UNKNOWN')
               pos_counts[pos] = pos_counts.get(pos, 0) + 1
           
           print(f"SYNTAX ANALYSIS ({len(tokens)} tokens):")
           for pos, count in sorted(pos_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
               print(f"  {pos}: {count}")
           print()
       
       print("="*60)
   
   if __name__ == "__main__":
       if len(sys.argv) > 1:
           create_analysis_report(sys.argv[1])
       else:
           create_analysis_report('comprehensive_response.json')
   EOF
   
   python3 analysis_report.py comprehensive_response.json
   ```

![Comprehensive Analysis](https://via.placeholder.com/600x300/795548/FFFFFF?text=Comprehensive+Analysis)

---

### 📊 Task 8: Batch Processing

1. **Batch Analysis Script**
   ```bash
   cat > batch_analysis.py << 'EOF'
   #!/usr/bin/env python3
   
   import json
   import os
   import subprocess
   import time
   from pathlib import Path
   
   def get_access_token():
       result = subprocess.run([
           'gcloud', 'auth', 'application-default', 'print-access-token'
       ], capture_output=True, text=True)
       return result.stdout.strip()
   
   def analyze_document(content, features=None):
       if features is None:
           features = {
               "extractSyntax": True,
               "extractEntities": True,
               "extractDocumentSentiment": True,
               "classifyText": True
           }
       
       access_token = get_access_token()
       
       request_data = {
           "document": {
               "type": "PLAIN_TEXT",
               "content": content
           },
           "features": features,
           "encodingType": "UTF8"
       }
       
       # Write request to temp file
       with open('/tmp/batch_request.json', 'w') as f:
           json.dump(request_data, f)
       
       # Make API call
       result = subprocess.run([
           'curl', '-s', '-X', 'POST',
           '-H', f'Authorization: Bearer {access_token}',
           '-H', 'Content-Type: application/json',
           'https://language.googleapis.com/v1/documents:annotateText',
           '-d', '@/tmp/batch_request.json'
       ], capture_output=True, text=True)
       
       try:
           return json.loads(result.stdout)
       except json.JSONDecodeError:
           return {"error": result.stdout}
   
   def process_all_files():
       results = {}
       
       # Get all text files
       text_files = list(Path('.').glob('*.txt'))
       
       print(f"Processing {len(text_files)} files...")
       
       for file_path in text_files:
           print(f"Analyzing {file_path.name}...")
           
           with open(file_path, 'r') as f:
               content = f.read()
           
           # Skip if content is too short
           if len(content.strip()) < 20:
               print(f"  Skipping {file_path.name} - content too short")
               continue
           
           try:
               analysis = analyze_document(content)
               results[file_path.name] = analysis
               
               # Print summary
               if 'documentSentiment' in analysis:
                   sentiment = analysis['documentSentiment']
                   score = sentiment.get('score', 0)
                   print(f"  Sentiment: {score:.3f} ({'Positive' if score > 0.2 else 'Negative' if score < -0.2 else 'Neutral'})")
               
               if 'entities' in analysis:
                   entity_count = len(analysis['entities'])
                   print(f"  Entities: {entity_count}")
               
               if 'categories' in analysis:
                   if analysis['categories']:
                       top_category = analysis['categories'][0]['name']
                       confidence = analysis['categories'][0]['confidence']
                       print(f"  Category: {top_category} ({confidence:.3f})")
               
               time.sleep(1)  # Rate limiting
               
           except Exception as e:
               print(f"  Error analyzing {file_path.name}: {str(e)}")
               results[file_path.name] = {"error": str(e)}
       
       # Save results
       with open('batch_analysis_results.json', 'w') as f:
           json.dump(results, f, indent=2)
       
       print(f"\nBatch analysis complete. Results saved to batch_analysis_results.json")
       return results
   
   if __name__ == "__main__":
       process_all_files()
   EOF
   
   python3 batch_analysis.py
   ```

2. **Generate Summary Report**
   ```bash
   cat > generate_summary.py << 'EOF'
   #!/usr/bin/env python3
   
   import json
   from collections import defaultdict
   
   def generate_summary_report():
       with open('batch_analysis_results.json', 'r') as f:
           results = json.load(f)
       
       print("="*60)
       print("BATCH ANALYSIS SUMMARY REPORT")
       print("="*60)
       
       total_files = len(results)
       successful_analyses = len([r for r in results.values() if 'error' not in r])
       
       print(f"Total files processed: {total_files}")
       print(f"Successful analyses: {successful_analyses}")
       print(f"Success rate: {successful_analyses/total_files*100:.1f}%")
       print()
       
       # Sentiment distribution
       sentiments = {'Positive': 0, 'Negative': 0, 'Neutral': 0}
       sentiment_scores = []
       
       # Entity type distribution
       entity_types = defaultdict(int)
       
       # Category distribution
       categories = defaultdict(int)
       
       for filename, analysis in results.items():
           if 'error' in analysis:
               continue
           
           # Process sentiment
           if 'documentSentiment' in analysis:
               score = analysis['documentSentiment'].get('score', 0)
               sentiment_scores.append(score)
               
               if score > 0.2:
                   sentiments['Positive'] += 1
               elif score < -0.2:
                   sentiments['Negative'] += 1
               else:
                   sentiments['Neutral'] += 1
           
           # Process entities
           if 'entities' in analysis:
               for entity in analysis['entities']:
                   entity_types[entity.get('type', 'UNKNOWN')] += 1
           
           # Process categories
           if 'categories' in analysis:
               for category in analysis['categories']:
                   cat_name = category.get('name', 'UNKNOWN').split('/')[-1]
                   categories[cat_name] += 1
       
       # Display sentiment distribution
       print("SENTIMENT DISTRIBUTION:")
       for sentiment, count in sentiments.items():
           percentage = count / successful_analyses * 100 if successful_analyses > 0 else 0
           print(f"  {sentiment}: {count} ({percentage:.1f}%)")
       
       if sentiment_scores:
           avg_sentiment = sum(sentiment_scores) / len(sentiment_scores)
           print(f"  Average sentiment score: {avg_sentiment:.3f}")
       print()
       
       # Display top entity types
       print("TOP ENTITY TYPES:")
       for entity_type, count in sorted(entity_types.items(), key=lambda x: x[1], reverse=True)[:5]:
           print(f"  {entity_type}: {count}")
       print()
       
       # Display top categories
       if categories:
           print("TOP CONTENT CATEGORIES:")
           for category, count in sorted(categories.items(), key=lambda x: x[1], reverse=True)[:5]:
               print(f"  {category}: {count}")
           print()
       
       print("="*60)
   
   if __name__ == "__main__":
       generate_summary_report()
   EOF
   
   python3 generate_summary.py
   ```

![Batch Processing](https://via.placeholder.com/600x300/4CAF50/FFFFFF?text=Batch+Processing)

---

### 🎛️ Task 9: Advanced Features

1. **Entity Sentiment Analysis**
   ```bash
   # Create entity sentiment request
   cat > entity_sentiment_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$(cat news_article.txt | tr '\n' ' ')"
     },
     "features": {
       "extractEntitySentiment": true
     },
     "encodingType": "UTF8"
   }
   EOF
   
   # Call API
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://language.googleapis.com/v1/documents:annotateText" \
     -d @entity_sentiment_request.json > entity_sentiment_response.json
   
   # Display entity sentiments
   echo "=== Entity Sentiment Analysis ==="
   jq '.entities[] | {
     name: .name,
     type: .type,
     sentiment: .sentiment,
     salience: .salience
   }' entity_sentiment_response.json
   ```

2. **Language Detection**
   ```bash
   # Create multilingual test content
   cat > multilingual.txt << 'EOF'
   Hello, this is English text. 
   Bonjour, ceci est du texte français.
   Hola, este es texto en español.
   Guten Tag, das ist deutscher Text.
   EOF
   
   # Detect language
   cat > language_request.json << EOF
   {
     "document": {
       "type": "PLAIN_TEXT",
       "content": "$(cat multilingual.txt | tr '\n' ' ')"
     }
   }
   EOF
   
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://language.googleapis.com/v1/documents:analyzeSentiment" \
     -d @language_request.json | jq '.language'
   ```

3. **Performance Testing**
   ```bash
   cat > performance_test.py << 'EOF'
   #!/usr/bin/env python3
   
   import time
   import json
   import subprocess
   from statistics import mean, median
   
   def time_api_call(content, feature_type):
       access_token = subprocess.run([
           'gcloud', 'auth', 'application-default', 'print-access-token'
       ], capture_output=True, text=True).stdout.strip()
       
       features = {
           "sentiment": {"extractDocumentSentiment": True},
           "entities": {"extractEntities": True},
           "syntax": {"extractSyntax": True},
           "classification": {"classifyText": True}
       }
       
       request_data = {
           "document": {
               "type": "PLAIN_TEXT",
               "content": content
           },
           "features": features.get(feature_type, features["sentiment"]),
           "encodingType": "UTF8"
       }
       
       # Write request
       with open('/tmp/perf_request.json', 'w') as f:
           json.dump(request_data, f)
       
       start_time = time.time()
       
       result = subprocess.run([
           'curl', '-s', '-X', 'POST',
           '-H', f'Authorization: Bearer {access_token}',
           '-H', 'Content-Type: application/json',
           'https://language.googleapis.com/v1/documents:annotateText',
           '-d', '@/tmp/perf_request.json'
       ], capture_output=True, text=True)
       
       end_time = time.time()
       
       return end_time - start_time, result.returncode == 0
   
   def run_performance_tests():
       # Test content
       with open('news_article.txt', 'r') as f:
           content = f.read()
       
       test_types = ['sentiment', 'entities', 'syntax', 'classification']
       results = {}
       
       print("Running performance tests...")
       
       for test_type in test_types:
           print(f"Testing {test_type}...")
           times = []
           
           for i in range(3):  # Run 3 times for average
               duration, success = time_api_call(content, test_type)
               if success:
                   times.append(duration)
               time.sleep(1)  # Rate limiting
           
           if times:
               results[test_type] = {
                   'avg_time': mean(times),
                   'median_time': median(times),
                   'min_time': min(times),
                   'max_time': max(times),
                   'runs': len(times)
               }
           else:
               results[test_type] = {'error': 'All requests failed'}
       
       # Display results
       print("\nPerformance Test Results:")
       print("-" * 40)
       for test_type, metrics in results.items():
           if 'error' not in metrics:
               print(f"{test_type.capitalize():12} | Avg: {metrics['avg_time']:.3f}s | Median: {metrics['median_time']:.3f}s")
           else:
               print(f"{test_type.capitalize():12} | {metrics['error']}")
       
       return results
   
   if __name__ == "__main__":
       run_performance_tests()
   EOF
   
   python3 performance_test.py
   ```

![Advanced Features](https://via.placeholder.com/600x300/FF5722/FFFFFF?text=Advanced+Features)

---

## ✅ Verification Steps

### 1. API Features Testing
- [ ] Sentiment analysis working for all content types
- [ ] Entity extraction identifying key entities
- [ ] Syntax analysis parsing grammar correctly
- [ ] Text classification providing accurate categories

### 2. Content Analysis
- [ ] Positive sentiment detected in positive_review.txt
- [ ] Negative sentiment detected in negative_review.txt
- [ ] Entities extracted from news_article.txt
- [ ] Technical terms identified in technical_doc.txt

### 3. Advanced Features
- [ ] Entity sentiment analysis working
- [ ] Batch processing multiple documents
- [ ] Performance metrics collected
- [ ] Comprehensive analysis reports generated

---

## 🎯 Key Learning Points

1. **Multiple Analysis Types** - Sentiment, entities, syntax, classification
2. **Batch Processing** - Efficient analysis of multiple documents
3. **Entity Sentiment** - Sentiment analysis for specific entities
4. **Comprehensive Features** - Combined analysis with single API call
5. **Performance Optimization** - Understanding API response times

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line approach
- **[Automation Solution](Automation-Solution.md)** - Scripted implementation

---

## 🎖️ Skills Boost Arcade

Complete this challenge for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Use comprehensive analysis to get all Natural Language API features in a single API call!

</div>
