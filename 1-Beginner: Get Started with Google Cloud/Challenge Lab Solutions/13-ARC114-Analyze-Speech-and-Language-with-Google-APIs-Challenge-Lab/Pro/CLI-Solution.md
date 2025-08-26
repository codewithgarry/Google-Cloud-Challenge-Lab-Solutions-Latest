# Google Cloud Natural Language API - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Command Line](https://img.shields.io/badge/Command%20Line-000000?style=for-the-badge&logo=windows-terminal&logoColor=white)

**Lab ID**: ARC114 | **Duration**: 20-25 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Quick Solution

Complete command sequence for Natural Language API analysis:

```bash
# Set up environment
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME="$PROJECT_ID-nlp-lab"

# Enable APIs
gcloud services enable language.googleapis.com storage-api.googleapis.com

# Create test content
echo "This product is absolutely amazing! I love it." > positive.txt
echo "This product is terrible and disappointing." > negative.txt
echo "Google announced new AI technology. CEO Sundar Pichai made the announcement." > news.txt

# Get access token
export ACCESS_TOKEN=$(gcloud auth application-default print-access-token)

# Sentiment Analysis
curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeSentiment" \
  -d '{
    "document": {
      "type": "PLAIN_TEXT",
      "content": "This product is absolutely amazing! I love it."
    }
  }' | jq '.documentSentiment'

# Entity Analysis
curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeEntities" \
  -d '{
    "document": {
      "type": "PLAIN_TEXT",
      "content": "Google announced new AI technology. CEO Sundar Pichai made the announcement."
    }
  }' | jq '.entities[] | {name: .name, type: .type, salience: .salience}'

# Comprehensive Analysis
curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:annotateText" \
  -d '{
    "document": {
      "type": "PLAIN_TEXT",
      "content": "Google announced new AI technology. CEO Sundar Pichai made the announcement."
    },
    "features": {
      "extractSyntax": true,
      "extractEntities": true,
      "extractDocumentSentiment": true,
      "classifyText": true
    }
  }' | jq '{sentiment: .documentSentiment, entities: [.entities[] | {name: .name, type: .type}], categories: [.categories[]? | {name: .name, confidence: .confidence}]}'
```

---

## 📋 Complete CLI Commands

### 🔧 Environment Setup

```bash
# Configure project and environment
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME="$PROJECT_ID-nlp-analysis"
export REGION="us-central1"

# Enable required APIs
echo "Enabling Natural Language API..."
gcloud services enable language.googleapis.com
gcloud services enable storage-api.googleapis.com

# Verify APIs enabled
gcloud services list --enabled --filter="name:language OR name:storage"

# Create storage bucket for test files
gsutil mb -l $REGION gs://$BUCKET_NAME
```

### 📝 Test Content Creation

```bash
# Create diverse test content
echo "Creating test content files..."

# Positive sentiment review
cat > positive_review.txt << 'EOF'
This product is absolutely fantastic! The quality is outstanding and exceeds all my expectations. 
The customer service team was incredibly helpful and responsive. 
I would definitely recommend this to everyone. Five stars!
EOF

# Negative sentiment review
cat > negative_review.txt << 'EOF'
This product is completely disappointing and a waste of money. 
The quality is terrible and it broke immediately. 
Customer service was unhelpful and rude. I want a full refund.
EOF

# News article with entities
cat > news_article.txt << 'EOF'
Google announced today that their new artificial intelligence technology will be integrated 
into Google Cloud Platform. The CEO, Sundar Pichai, stated during the announcement in 
Mountain View, California that this technology will revolutionize data analysis. 
The new features will be available in the United States, United Kingdom, and Germany 
starting next month. Microsoft and Amazon are also developing similar AI technologies.
EOF

# Technical documentation
cat > technical_doc.txt << 'EOF'
To implement OAuth 2.0 authentication with Google Cloud APIs, you must first create 
a service account in the Google Cloud Console. Download the JSON credentials file 
and set the GOOGLE_APPLICATION_CREDENTIALS environment variable. Use the client 
libraries to make authenticated API calls with proper error handling and retry logic.
EOF

# Mixed sentiment content
cat > mixed_review.txt << 'EOF'
The product has some good features like the nice design and fast shipping. 
However, the build quality is questionable and the price is too high for what you get. 
Some customers might like it, but I expected better for this price range.
EOF

# Upload files to Cloud Storage
gsutil cp *.txt gs://$BUCKET_NAME/
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/*

echo "Test files created and uploaded to gs://$BUCKET_NAME/"
```

### 🔑 Authentication Setup

```bash
# Get authentication token
echo "Setting up authentication..."
export ACCESS_TOKEN=$(gcloud auth application-default print-access-token)

# Verify token
echo "Access token obtained: ${ACCESS_TOKEN:0:20}..."

# Test API connectivity
echo "Testing API connectivity..."
curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeSentiment" \
  -d '{"document": {"type": "PLAIN_TEXT", "content": "Hello world"}}' \
  | jq -e '.documentSentiment' > /dev/null && echo "✅ API connection successful" || echo "❌ API connection failed"
```

### 😊 Sentiment Analysis

```bash
echo "=== SENTIMENT ANALYSIS ==="

# Function to analyze sentiment
analyze_sentiment() {
    local content="$1"
    local label="$2"
    
    echo "Analyzing sentiment for: $label"
    
    result=$(curl -s -X POST \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      "https://language.googleapis.com/v1/documents:analyzeSentiment" \
      -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
    
    echo "$result" | jq '{
      score: .documentSentiment.score,
      magnitude: .documentSentiment.magnitude,
      interpretation: (
        if .documentSentiment.score > 0.2 then "Positive"
        elif .documentSentiment.score < -0.2 then "Negative"
        else "Neutral" end
      )
    }'
    echo ""
}

# Analyze each test file
while IFS= read -r file; do
    if [[ -f "$file" ]]; then
        content=$(cat "$file" | tr '\n' ' ')
        analyze_sentiment "$content" "$file"
    fi
done <<< "$(ls *.txt)"

# Quick sentiment tests
echo "=== QUICK SENTIMENT TESTS ==="

# Test various sentiment levels
test_sentiments=(
    "I absolutely love this amazing product!"
    "This is the worst thing I've ever bought."
    "The product is okay, nothing special."
    "Fantastic quality and excellent service!"
    "Terrible quality and poor customer support."
)

for i in "${!test_sentiments[@]}"; do
    echo "Test $((i+1)): ${test_sentiments[i]}"
    curl -s -X POST \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      "https://language.googleapis.com/v1/documents:analyzeSentiment" \
      -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"${test_sentiments[i]}\"}}" \
      | jq -r '.documentSentiment | "Score: \(.score) | Magnitude: \(.magnitude)"'
    echo ""
done
```

### 🏷️ Entity Analysis

```bash
echo "=== ENTITY ANALYSIS ==="

# Function to analyze entities
analyze_entities() {
    local content="$1"
    local label="$2"
    
    echo "Analyzing entities for: $label"
    
    result=$(curl -s -X POST \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      "https://language.googleapis.com/v1/documents:analyzeEntities" \
      -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
    
    # Display entities summary
    echo "$result" | jq -r '.entities[] | "• \(.name) (\(.type)) - Salience: \(.salience | tostring | .[0:5])"' | head -10
    
    # Count entities by type
    echo "Entity counts by type:"
    echo "$result" | jq '.entities | group_by(.type) | map({type: .[0].type, count: length}) | .[] | "  \(.type): \(.count)"'
    echo ""
}

# Analyze entities in news article
content=$(cat news_article.txt | tr '\n' ' ')
analyze_entities "$content" "News Article"

# Test entity extraction with different content types
echo "=== ENTITY EXTRACTION TESTS ==="

# Person and organization test
person_org_text="Barack Obama was the President of the United States. He worked with Microsoft and Google on technology initiatives."
echo "Testing person/organization extraction:"
curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeEntities" \
  -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$person_org_text\"}}" \
  | jq '.entities[] | select(.type == "PERSON" or .type == "ORGANIZATION") | {name: .name, type: .type, salience: .salience}'

echo ""

# Location test
location_text="I traveled from New York to San Francisco, then to London, and finally to Tokyo."
echo "Testing location extraction:"
curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeEntities" \
  -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$location_text\"}}" \
  | jq '.entities[] | select(.type == "LOCATION") | {name: .name, type: .type, metadata: .metadata}'

echo ""

# Extract entities from all files
for file in *.txt; do
    if [[ -f "$file" ]]; then
        echo "Entities in $file:"
        content=$(cat "$file" | tr '\n' ' ')
        curl -s -X POST \
          -H "Authorization: Bearer $ACCESS_TOKEN" \
          -H "Content-Type: application/json" \
          "https://language.googleapis.com/v1/documents:analyzeEntities" \
          -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}" \
          | jq -r '.entities[] | "  \(.name) (\(.type))"' | head -5
        echo ""
    fi
done
```

### 🔍 Syntax Analysis

```bash
echo "=== SYNTAX ANALYSIS ==="

# Function to analyze syntax
analyze_syntax() {
    local content="$1"
    local label="$2"
    
    echo "Analyzing syntax for: $label"
    
    result=$(curl -s -X POST \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      "https://language.googleapis.com/v1/documents:analyzeSyntax" \
      -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
    
    # Token count
    token_count=$(echo "$result" | jq '.tokens | length')
    echo "Total tokens: $token_count"
    
    # Part-of-speech distribution
    echo "Part-of-speech distribution:"
    echo "$result" | jq '.tokens | group_by(.partOfSpeech.tag) | map({pos: .[0].partOfSpeech.tag, count: length}) | sort_by(.count) | reverse | .[] | "  \(.pos): \(.count)"' | head -8
    
    # Extract nouns
    echo "Sample nouns:"
    echo "$result" | jq -r '.tokens[] | select(.partOfSpeech.tag == "NOUN") | .text.content' | head -5 | sed 's/^/  /'
    
    # Extract verbs
    echo "Sample verbs:"
    echo "$result" | jq -r '.tokens[] | select(.partOfSpeech.tag == "VERB") | .text.content' | head -5 | sed 's/^/  /'
    
    echo ""
}

# Analyze syntax for technical document
content=$(cat technical_doc.txt | tr '\n' ' ')
analyze_syntax "$content" "Technical Document"

# Test syntax with simple sentence
simple_sentence="The quick brown fox jumps over the lazy dog."
echo "=== SIMPLE SYNTAX TEST ==="
echo "Sentence: $simple_sentence"

curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeSyntax" \
  -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$simple_sentence\"}}" \
  | jq '.tokens[] | {text: .text.content, pos: .partOfSpeech.tag, lemma: .lemma}'

echo ""

# Dependency parsing example
echo "=== DEPENDENCY ANALYSIS ==="
complex_sentence="Google's CEO announced new artificial intelligence features."
echo "Sentence: $complex_sentence"

curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeSyntax" \
  -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$complex_sentence\"}}" \
  | jq '.tokens[] | {text: .text.content, headIndex: .dependencyEdge.headTokenIndex, label: .dependencyEdge.label}'

echo ""
```

### 📊 Text Classification

```bash
echo "=== TEXT CLASSIFICATION ==="

# Function to classify text
classify_text() {
    local content="$1"
    local label="$2"
    
    echo "Classifying: $label"
    
    # Check content length (minimum required for classification)
    if [ ${#content} -lt 20 ]; then
        echo "  Content too short for classification"
        echo ""
        return
    fi
    
    result=$(curl -s -X POST \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      "https://language.googleapis.com/v1/documents:classifyText" \
      -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
    
    # Check if classification is available
    if echo "$result" | jq -e '.categories' > /dev/null; then
        echo "$result" | jq '.categories[] | "  \(.name) (confidence: \(.confidence | tonumber | . * 100 | round / 100))"'
    else
        echo "  No classification available"
    fi
    echo ""
}

# Test classification with news article
content=$(cat news_article.txt | tr '\n' ' ')
classify_text "$content" "News Article"

# Test with different content types
classification_tests=(
    "Apple Inc. reported strong quarterly earnings, beating analyst expectations for the third consecutive quarter."
    "The recipe for chocolate chip cookies requires flour, butter, sugar, eggs, and chocolate chips. Bake at 350 degrees for 12 minutes."
    "Scientists have discovered a new species of deep-sea fish in the Pacific Ocean. The research was published in Nature journal."
    "Breaking news: A major earthquake struck the region this morning, causing significant damage to buildings and infrastructure."
)

echo "=== CLASSIFICATION TESTS ==="
for i in "${!classification_tests[@]}"; do
    classify_text "${classification_tests[i]}" "Test $((i+1))"
done

# Try to classify all text files
for file in *.txt; do
    if [[ -f "$file" ]]; then
        content=$(cat "$file" | tr '\n' ' ')
        classify_text "$content" "$file"
    fi
done
```

### 🔄 Comprehensive Analysis

```bash
echo "=== COMPREHENSIVE ANALYSIS ==="

# Function to perform comprehensive analysis
comprehensive_analysis() {
    local content="$1"
    local label="$2"
    
    echo "Comprehensive analysis for: $label"
    echo "Content preview: ${content:0:100}..."
    echo ""
    
    result=$(curl -s -X POST \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      "https://language.googleapis.com/v1/documents:annotateText" \
      -d "{
        \"document\": {
          \"type\": \"PLAIN_TEXT\",
          \"content\": \"$content\"
        },
        \"features\": {
          \"extractSyntax\": true,
          \"extractEntities\": true,
          \"extractDocumentSentiment\": true,
          \"extractEntitySentiment\": true,
          \"classifyText\": true
        },
        \"encodingType\": \"UTF8\"
      }")
    
    # Document sentiment
    echo "Document Sentiment:"
    echo "$result" | jq '.documentSentiment | "  Score: \(.score) | Magnitude: \(.magnitude) | \(if .score > 0.2 then "Positive" elif .score < -0.2 then "Negative" else "Neutral" end)"'
    echo ""
    
    # Top entities
    echo "Top 5 Entities:"
    echo "$result" | jq -r '.entities[:5][] | "  • \(.name) (\(.type)) - Salience: \(.salience | tostring | .[0:5])"'
    echo ""
    
    # Entity sentiments
    echo "Entity Sentiments:"
    echo "$result" | jq -r '.entities[] | select(.sentiment) | "  • \(.name): \(.sentiment.score | tostring | .[0:5])"' | head -5
    echo ""
    
    # Classification
    echo "Classification:"
    if echo "$result" | jq -e '.categories' > /dev/null; then
        echo "$result" | jq -r '.categories[] | "  • \(.name) (confidence: \(.confidence | . * 100 | round / 100)%)"'
    else
        echo "  No classification available"
    fi
    echo ""
    
    # Syntax summary
    echo "Syntax Summary:"
    token_count=$(echo "$result" | jq '.tokens | length')
    echo "  Total tokens: $token_count"
    echo "$result" | jq '.tokens | group_by(.partOfSpeech.tag) | map({pos: .[0].partOfSpeech.tag, count: length}) | sort_by(.count) | reverse | .[:3][] | "  \(.pos): \(.count)"'
    echo ""
    
    echo "---"
}

# Perform comprehensive analysis on all test files
for file in *.txt; do
    if [[ -f "$file" ]]; then
        content=$(cat "$file" | tr '\n' ' ')
        comprehensive_analysis "$content" "$file"
    fi
done
```

### 🧪 Advanced Features Testing

```bash
echo "=== ADVANCED FEATURES ==="

# Entity Sentiment Analysis
echo "Entity Sentiment Analysis:"
news_content=$(cat news_article.txt | tr '\n' ' ')

curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:annotateText" \
  -d "{
    \"document\": {
      \"type\": \"PLAIN_TEXT\",
      \"content\": \"$news_content\"
    },
    \"features\": {
      \"extractEntitySentiment\": true
    }
  }" | jq '.entities[] | select(.sentiment) | {name: .name, type: .type, sentiment_score: .sentiment.score, sentiment_magnitude: .sentiment.magnitude}'

echo ""

# Language Detection
echo "=== LANGUAGE DETECTION ==="
multilingual_texts=(
    "Hello, this is English text."
    "Bonjour, ceci est du texte français."
    "Hola, este es texto en español."
    "Guten Tag, das ist deutscher Text."
    "Ciao, questo è testo italiano."
)

for text in "${multilingual_texts[@]}"; do
    echo "Text: $text"
    curl -s -X POST \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      "https://language.googleapis.com/v1/documents:analyzeSentiment" \
      -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$text\"}}" \
      | jq -r '.language // "unknown"' | xargs printf "  Detected language: %s\n"
    echo ""
done

# Batch Analysis
echo "=== BATCH PROCESSING ==="
batch_analyze() {
    local files=("$@")
    
    echo "Processing ${#files[@]} files in batch..."
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "Processing $file..."
            content=$(cat "$file" | tr '\n' ' ')
            
            # Quick analysis
            sentiment=$(curl -s -X POST \
              -H "Authorization: Bearer $ACCESS_TOKEN" \
              -H "Content-Type: application/json" \
              "https://language.googleapis.com/v1/documents:analyzeSentiment" \
              -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}" \
              | jq -r '.documentSentiment.score')
            
            entities=$(curl -s -X POST \
              -H "Authorization: Bearer $ACCESS_TOKEN" \
              -H "Content-Type: application/json" \
              "https://language.googleapis.com/v1/documents:analyzeEntities" \
              -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}" \
              | jq '.entities | length')
            
            echo "  Sentiment Score: $sentiment"
            echo "  Entity Count: $entities"
            echo ""
            
            sleep 1  # Rate limiting
        fi
    done
}

# Run batch analysis on all text files
text_files=(*.txt)
batch_analyze "${text_files[@]}"
```

### 📊 Performance Testing

```bash
echo "=== PERFORMANCE TESTING ==="

# Performance test function
test_api_performance() {
    local feature="$1"
    local content="$2"
    local iterations=3
    
    echo "Testing $feature performance ($iterations runs)..."
    
    local total_time=0
    local success_count=0
    
    for ((i=1; i<=iterations; i++)); do
        start_time=$(date +%s.%3N)
        
        case $feature in
            "sentiment")
                result=$(curl -s -X POST \
                  -H "Authorization: Bearer $ACCESS_TOKEN" \
                  -H "Content-Type: application/json" \
                  "https://language.googleapis.com/v1/documents:analyzeSentiment" \
                  -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
                ;;
            "entities")
                result=$(curl -s -X POST \
                  -H "Authorization: Bearer $ACCESS_TOKEN" \
                  -H "Content-Type: application/json" \
                  "https://language.googleapis.com/v1/documents:analyzeEntities" \
                  -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
                ;;
            "syntax")
                result=$(curl -s -X POST \
                  -H "Authorization: Bearer $ACCESS_TOKEN" \
                  -H "Content-Type: application/json" \
                  "https://language.googleapis.com/v1/documents:analyzeSyntax" \
                  -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
                ;;
        esac
        
        end_time=$(date +%s.%3N)
        duration=$(echo "$end_time - $start_time" | bc)
        
        if echo "$result" | jq -e '. | keys' > /dev/null 2>&1; then
            total_time=$(echo "$total_time + $duration" | bc)
            success_count=$((success_count + 1))
            echo "  Run $i: ${duration}s"
        else
            echo "  Run $i: Failed"
        fi
        
        sleep 1  # Rate limiting
    done
    
    if [ $success_count -gt 0 ]; then
        avg_time=$(echo "scale=3; $total_time / $success_count" | bc)
        echo "  Average time: ${avg_time}s (${success_count}/${iterations} successful)"
    else
        echo "  All runs failed"
    fi
    echo ""
}

# Test performance with news article content
test_content=$(cat news_article.txt | tr '\n' ' ')

test_api_performance "sentiment" "$test_content"
test_api_performance "entities" "$test_content"
test_api_performance "syntax" "$test_content"
```

### 📋 Final Verification

```bash
echo "=== FINAL VERIFICATION ==="

# Check all required components
echo "Verifying lab completion..."

# Check if files exist
echo "✅ Checking test files:"
for file in positive_review.txt negative_review.txt news_article.txt technical_doc.txt; do
    if [[ -f "$file" ]]; then
        echo "  ✅ $file exists"
    else
        echo "  ❌ $file missing"
    fi
done

# Verify API functionality
echo -e "\n✅ Testing API functionality:"

# Test sentiment
sentiment_test=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeSentiment" \
  -d '{"document": {"type": "PLAIN_TEXT", "content": "This is a test"}}')

if echo "$sentiment_test" | jq -e '.documentSentiment' > /dev/null; then
    echo "  ✅ Sentiment Analysis working"
else
    echo "  ❌ Sentiment Analysis failed"
fi

# Test entities
entity_test=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeEntities" \
  -d '{"document": {"type": "PLAIN_TEXT", "content": "Google is a technology company"}}')

if echo "$entity_test" | jq -e '.entities' > /dev/null; then
    echo "  ✅ Entity Analysis working"
else
    echo "  ❌ Entity Analysis failed"
fi

# Test syntax
syntax_test=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://language.googleapis.com/v1/documents:analyzeSyntax" \
  -d '{"document": {"type": "PLAIN_TEXT", "content": "This is a test sentence"}}')

if echo "$syntax_test" | jq -e '.tokens' > /dev/null; then
    echo "  ✅ Syntax Analysis working"
else
    echo "  ❌ Syntax Analysis failed"
fi

# Generate summary
echo -e "\n=== SUMMARY ==="
echo "Natural Language API features tested:"
echo "• Sentiment Analysis: Emotional tone detection"
echo "• Entity Analysis: Named entity recognition"
echo "• Syntax Analysis: Grammatical structure parsing"
echo "• Text Classification: Content categorization"
echo "• Entity Sentiment: Sentiment about specific entities"
echo "• Comprehensive Analysis: All features combined"

echo -e "\nFiles processed:"
ls *.txt 2>/dev/null | wc -l | xargs printf "• %d text files analyzed\n"

echo -e "\nStorage bucket:"
echo "• gs://$BUCKET_NAME"

echo -e "\n✅ Natural Language API lab completed successfully!"
```

---

## 🎯 Key CLI Commands Summary

| Feature | Command | Output |
|---------|---------|---------|
| **Sentiment** | `curl + analyzeSentiment` | Score and magnitude |
| **Entities** | `curl + analyzeEntities` | Named entities with types |
| **Syntax** | `curl + analyzeSyntax` | POS tags and structure |
| **Classification** | `curl + classifyText` | Content categories |
| **Comprehensive** | `curl + annotateText` | All features combined |

---

## ✅ Verification Checklist

- [ ] Sentiment analysis detects positive/negative emotions
- [ ] Entity analysis extracts people, organizations, locations
- [ ] Syntax analysis identifies parts of speech
- [ ] Text classification categorizes content types
- [ ] Comprehensive analysis combines all features
- [ ] Performance testing completed

---

<div align="center">

**⚡ Pro Tip**: Use comprehensive analysis (`annotateText`) to get all Natural Language features in a single API call!

</div>
