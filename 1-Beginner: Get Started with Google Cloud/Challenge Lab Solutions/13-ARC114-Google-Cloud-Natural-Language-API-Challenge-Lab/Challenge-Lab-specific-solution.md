# ARC114: Google Cloud Natural Language API: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Natural Language](https://img.shields.io/badge/Natural%20Language-34A853?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC114 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll explore the Google Cloud Natural Language API to analyze sentiment, extract entities, classify text, and perform syntax analysis on various text samples.

## 📋 Challenge Tasks

### Task 1: Sentiment Analysis

Analyze the sentiment of text content using the Natural Language API.

### Task 2: Entity Recognition

Extract and classify entities from text documents.

### Task 3: Text Classification

Classify text content into predefined categories.

### Task 4: Syntax Analysis

Perform detailed syntax analysis including parts of speech.

### Task 5: Batch Processing

Process multiple documents efficiently using batch operations.

---

## 🚀 Solution Method 1: Environment Setup and Basic Analysis

### Step 1: Environment Configuration

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME=${PROJECT_ID}-natural-language
export REGION=us-central1

# Enable Natural Language API
gcloud services enable language.googleapis.com

# Create service account
gcloud iam service-accounts create natural-language-sa \
    --description="Service account for Natural Language API demo" \
    --display-name="Natural Language Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:natural-language-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/language.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:natural-language-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Create and download key
gcloud iam service-accounts keys create natural-language-key.json \
    --iam-account=natural-language-sa@$PROJECT_ID.iam.gserviceaccount.com

# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=natural-language-key.json

# Create bucket for storing documents
gsutil mb -l $REGION gs://$BUCKET_NAME
```

### Step 2: Prepare Sample Text Data

```bash
# Create directory for text samples
mkdir ~/natural-language-demo
cd ~/natural-language-demo

# Create various text samples for analysis
cat > positive_review.txt << 'EOF'
I absolutely love this product! The quality is outstanding and it exceeded all my expectations. The customer service was exceptional, and the delivery was incredibly fast. I would definitely recommend this to anyone looking for a high-quality solution. This company has truly impressed me with their attention to detail and commitment to excellence.
EOF

cat > negative_review.txt << 'EOF'
This product is terrible and completely disappointing. The quality is poor, and it broke within a week of purchase. The customer service was unhelpful and rude when I tried to get a refund. I would never buy from this company again and strongly advise others to avoid this product at all costs.
EOF

cat > neutral_news.txt << 'EOF'
Google Cloud announced new updates to their Natural Language API during the annual Cloud Next conference. The updates include improved accuracy for entity recognition and expanded language support. The company stated that these improvements will be available to all customers starting next month. Industry analysts expect these changes to impact the competitive landscape in the AI services market.
EOF

cat > technical_article.txt << 'EOF'
Machine learning and artificial intelligence have revolutionized natural language processing. Google's Natural Language API leverages advanced neural networks to understand human language semantics, syntax, and context. The API can analyze sentiment, extract entities like people, places, and organizations, and classify text into various categories. This technology is widely used in content moderation, customer feedback analysis, and document processing workflows.
EOF

cat > business_email.txt << 'EOF'
Dear Mr. Johnson,

I hope this email finds you well. I am writing to follow up on our meeting last Tuesday regarding the new marketing campaign for our Q4 product launch. As discussed, we need to finalize the budget allocation by Friday, October 15th.

The team at Microsoft has expressed interest in a potential partnership, and we should schedule a call with their representatives next week. Please let me know your availability for Monday or Tuesday afternoon.

Looking forward to your response.

Best regards,
Sarah Thompson
Marketing Director
Tech Solutions Inc.
EOF

# Upload text files to Cloud Storage
gsutil cp *.txt gs://$BUCKET_NAME/texts/

echo "Sample text files created and uploaded to Cloud Storage"
```

---

## 🚀 Solution Method 2: Comprehensive Natural Language Analysis

### Step 1: Sentiment Analysis Implementation

```bash
# Create comprehensive sentiment analysis script
cat > sentiment_analysis.py << 'EOF'
from google.cloud import language_v1
import json
import os
from typing import Dict, List, Any

class SentimentAnalyzer:
    def __init__(self):
        self.client = language_v1.LanguageServiceClient()
    
    def analyze_sentiment(self, text_content: str, language_code: str = "en") -> Dict[str, Any]:
        """Analyze sentiment of text content"""
        
        # Create document object
        document = language_v1.Document(
            content=text_content,
            type_=language_v1.Document.Type.PLAIN_TEXT,
            language=language_code
        )
        
        # Analyze sentiment
        response = self.client.analyze_sentiment(
            request={
                'document': document,
                'encoding_type': language_v1.EncodingType.UTF8
            }
        )
        
        # Extract overall sentiment
        overall_sentiment = {
            'score': response.document_sentiment.score,
            'magnitude': response.document_sentiment.magnitude,
            'interpretation': self._interpret_sentiment(
                response.document_sentiment.score,
                response.document_sentiment.magnitude
            )
        }
        
        # Extract sentence-level sentiment
        sentence_sentiments = []
        for sentence in response.sentences:
            sentence_data = {
                'text': sentence.text.content,
                'sentiment_score': sentence.sentiment.score,
                'sentiment_magnitude': sentence.sentiment.magnitude,
                'interpretation': self._interpret_sentiment(
                    sentence.sentiment.score,
                    sentence.sentiment.magnitude
                )
            }
            sentence_sentiments.append(sentence_data)
        
        return {
            'overall_sentiment': overall_sentiment,
            'sentence_sentiments': sentence_sentiments,
            'total_sentences': len(sentence_sentiments)
        }
    
    def _interpret_sentiment(self, score: float, magnitude: float) -> str:
        """Interpret sentiment score and magnitude"""
        if magnitude < 0.1:
            return "Neutral (very low magnitude)"
        elif score > 0.25:
            if magnitude > 0.75:
                return "Clearly Positive"
            else:
                return "Positive"
        elif score < -0.25:
            if magnitude > 0.75:
                return "Clearly Negative"
            else:
                return "Negative"
        else:
            if magnitude > 0.5:
                return "Mixed"
            else:
                return "Neutral"
    
    def batch_sentiment_analysis(self, texts: List[str]) -> List[Dict[str, Any]]:
        """Analyze sentiment for multiple texts"""
        results = []
        
        for i, text in enumerate(texts):
            try:
                result = self.analyze_sentiment(text)
                result['text_index'] = i
                result['text_preview'] = text[:100] + "..." if len(text) > 100 else text
                results.append(result)
            except Exception as e:
                results.append({
                    'text_index': i,
                    'error': str(e),
                    'text_preview': text[:100] + "..." if len(text) > 100 else text
                })
        
        return results
    
    def sentiment_comparison_report(self, results: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Generate sentiment comparison report"""
        
        successful_results = [r for r in results if 'error' not in r]
        
        if not successful_results:
            return {'error': 'No successful sentiment analyses'}
        
        scores = [r['overall_sentiment']['score'] for r in successful_results]
        magnitudes = [r['overall_sentiment']['magnitude'] for r in successful_results]
        
        report = {
            'summary': {
                'total_texts': len(results),
                'successful_analyses': len(successful_results),
                'average_sentiment_score': sum(scores) / len(scores),
                'average_magnitude': sum(magnitudes) / len(magnitudes),
                'most_positive_score': max(scores),
                'most_negative_score': min(scores),
                'highest_magnitude': max(magnitudes),
                'lowest_magnitude': min(magnitudes)
            },
            'distribution': {
                'clearly_positive': 0,
                'positive': 0,
                'neutral': 0,
                'negative': 0,
                'clearly_negative': 0,
                'mixed': 0
            },
            'detailed_results': successful_results
        }
        
        # Count sentiment distributions
        for result in successful_results:
            interpretation = result['overall_sentiment']['interpretation'].lower()
            if 'clearly positive' in interpretation:
                report['distribution']['clearly_positive'] += 1
            elif 'positive' in interpretation:
                report['distribution']['positive'] += 1
            elif 'clearly negative' in interpretation:
                report['distribution']['clearly_negative'] += 1
            elif 'negative' in interpretation:
                report['distribution']['negative'] += 1
            elif 'mixed' in interpretation:
                report['distribution']['mixed'] += 1
            else:
                report['distribution']['neutral'] += 1
        
        return report

def demonstrate_sentiment_analysis():
    """Demonstrate sentiment analysis capabilities"""
    
    analyzer = SentimentAnalyzer()
    
    # Load text files
    text_files = [
        'positive_review.txt',
        'negative_review.txt', 
        'neutral_news.txt',
        'technical_article.txt',
        'business_email.txt'
    ]
    
    texts = []
    file_names = []
    
    for file_name in text_files:
        try:
            with open(file_name, 'r', encoding='utf-8') as f:
                content = f.read()
                texts.append(content)
                file_names.append(file_name)
        except FileNotFoundError:
            print(f"Warning: {file_name} not found, skipping...")
    
    if not texts:
        print("No text files found for analysis")
        return
    
    print("=== Sentiment Analysis Demo ===")
    
    # Analyze individual texts
    for i, (text, file_name) in enumerate(zip(texts, file_names)):
        print(f"\nAnalyzing: {file_name}")
        result = analyzer.analyze_sentiment(text)
        
        print(f"Overall Sentiment: {result['overall_sentiment']['interpretation']}")
        print(f"Score: {result['overall_sentiment']['score']:.3f}")
        print(f"Magnitude: {result['overall_sentiment']['magnitude']:.3f}")
        print(f"Sentences analyzed: {result['total_sentences']}")
    
    # Batch analysis and comparison
    print("\n=== Batch Analysis Results ===")
    batch_results = analyzer.batch_sentiment_analysis(texts)
    
    # Generate comparison report
    comparison_report = analyzer.sentiment_comparison_report(batch_results)
    
    # Save results
    with open('sentiment_analysis_results.json', 'w') as f:
        json.dump({
            'file_names': file_names,
            'individual_results': batch_results,
            'comparison_report': comparison_report
        }, f, indent=2, default=str)
    
    print("Sentiment analysis results saved to: sentiment_analysis_results.json")
    
    # Print summary
    if 'summary' in comparison_report:
        summary = comparison_report['summary']
        print(f"\nOverall Summary:")
        print(f"Average Sentiment Score: {summary['average_sentiment_score']:.3f}")
        print(f"Average Magnitude: {summary['average_magnitude']:.3f}")
        print(f"Most Positive Score: {summary['most_positive_score']:.3f}")
        print(f"Most Negative Score: {summary['most_negative_score']:.3f}")

if __name__ == "__main__":
    demonstrate_sentiment_analysis()
EOF

# Install required dependencies
pip install google-cloud-language

# Run sentiment analysis
python sentiment_analysis.py
```

---

## 🚀 Solution Method 3: Entity Recognition and Classification

### Step 1: Entity Analysis Implementation

```bash
# Create entity recognition script
cat > entity_analysis.py << 'EOF'
from google.cloud import language_v1
import json
from collections import defaultdict, Counter
from typing import Dict, List, Any

class EntityAnalyzer:
    def __init__(self):
        self.client = language_v1.LanguageServiceClient()
    
    def extract_entities(self, text_content: str, language_code: str = "en") -> Dict[str, Any]:
        """Extract entities from text content"""
        
        # Create document object
        document = language_v1.Document(
            content=text_content,
            type_=language_v1.Document.Type.PLAIN_TEXT,
            language=language_code
        )
        
        # Extract entities
        response = self.client.analyze_entities(
            request={
                'document': document,
                'encoding_type': language_v1.EncodingType.UTF8
            }
        )
        
        # Process entities
        entities = []
        entity_types = defaultdict(list)
        
        for entity in response.entities:
            entity_data = {
                'name': entity.name,
                'type': entity.type_.name,
                'salience': entity.salience,
                'mentions': []
            }
            
            # Process mentions
            for mention in entity.mentions:
                mention_data = {
                    'text': mention.text.content,
                    'type': mention.type_.name,
                    'begin_offset': mention.text.begin_offset
                }
                entity_data['mentions'].append(mention_data)
            
            # Add metadata if available
            if hasattr(entity, 'metadata') and entity.metadata:
                entity_data['metadata'] = dict(entity.metadata)
            
            entities.append(entity_data)
            entity_types[entity.type_.name].append(entity_data)
        
        return {
            'entities': entities,
            'entity_types': dict(entity_types),
            'total_entities': len(entities),
            'language': response.language
        }
    
    def classify_text(self, text_content: str) -> Dict[str, Any]:
        """Classify text content into categories"""
        
        document = language_v1.Document(
            content=text_content,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        try:
            response = self.client.classify_text(request={'document': document})
            
            categories = []
            for category in response.categories:
                category_data = {
                    'name': category.name,
                    'confidence': category.confidence
                }
                categories.append(category_data)
            
            return {
                'categories': categories,
                'total_categories': len(categories),
                'top_category': categories[0] if categories else None
            }
        
        except Exception as e:
            return {
                'error': str(e),
                'categories': [],
                'total_categories': 0
            }
    
    def analyze_syntax(self, text_content: str, language_code: str = "en") -> Dict[str, Any]:
        """Perform syntax analysis on text"""
        
        document = language_v1.Document(
            content=text_content,
            type_=language_v1.Document.Type.PLAIN_TEXT,
            language=language_code
        )
        
        response = self.client.analyze_syntax(
            request={
                'document': document,
                'encoding_type': language_v1.EncodingType.UTF8
            }
        )
        
        # Process tokens
        tokens = []
        pos_counts = Counter()
        
        for token in response.tokens:
            token_data = {
                'text': token.text.content,
                'part_of_speech': token.part_of_speech.tag.name,
                'lemma': token.lemma,
                'dependency_edge': {
                    'head_token_index': token.dependency_edge.head_token_index,
                    'label': token.dependency_edge.label.name
                }
            }
            tokens.append(token_data)
            pos_counts[token.part_of_speech.tag.name] += 1
        
        # Process sentences
        sentences = []
        for sentence in response.sentences:
            sentence_data = {
                'text': sentence.text.content,
                'begin_offset': sentence.text.begin_offset
            }
            sentences.append(sentence_data)
        
        return {
            'tokens': tokens,
            'sentences': sentences,
            'pos_distribution': dict(pos_counts),
            'total_tokens': len(tokens),
            'total_sentences': len(sentences),
            'language': response.language
        }
    
    def comprehensive_analysis(self, text_content: str) -> Dict[str, Any]:
        """Perform comprehensive analysis including all features"""
        
        print(f"Analyzing text: {text_content[:100]}...")
        
        results = {
            'text_preview': text_content[:200] + "..." if len(text_content) > 200 else text_content,
            'text_length': len(text_content)
        }
        
        # Entity extraction
        try:
            entity_results = self.extract_entities(text_content)
            results['entities'] = entity_results
        except Exception as e:
            results['entities'] = {'error': str(e)}
        
        # Text classification
        try:
            classification_results = self.classify_text(text_content)
            results['classification'] = classification_results
        except Exception as e:
            results['classification'] = {'error': str(e)}
        
        # Syntax analysis
        try:
            syntax_results = self.analyze_syntax(text_content)
            results['syntax'] = syntax_results
        except Exception as e:
            results['syntax'] = {'error': str(e)}
        
        return results
    
    def create_entity_summary(self, comprehensive_results: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Create summary of entities across all analyzed texts"""
        
        all_entities = []
        entity_type_counts = Counter()
        entity_names = Counter()
        
        for result in comprehensive_results:
            if 'entities' in result and 'error' not in result['entities']:
                entities = result['entities']['entities']
                all_entities.extend(entities)
                
                for entity in entities:
                    entity_type_counts[entity['type']] += 1
                    entity_names[entity['name']] += 1
        
        # Find most salient entities
        sorted_entities = sorted(all_entities, key=lambda x: x['salience'], reverse=True)
        
        summary = {
            'total_entities_found': len(all_entities),
            'unique_entity_names': len(entity_names),
            'entity_type_distribution': dict(entity_type_counts),
            'most_common_entities': entity_names.most_common(10),
            'most_salient_entities': sorted_entities[:10],
            'entity_types_found': list(entity_type_counts.keys())
        }
        
        return summary

def demonstrate_entity_analysis():
    """Demonstrate entity analysis capabilities"""
    
    analyzer = EntityAnalyzer()
    
    # Load text files
    text_files = [
        'positive_review.txt',
        'negative_review.txt', 
        'neutral_news.txt',
        'technical_article.txt',
        'business_email.txt'
    ]
    
    comprehensive_results = []
    
    print("=== Comprehensive Natural Language Analysis ===")
    
    for file_name in text_files:
        try:
            with open(file_name, 'r', encoding='utf-8') as f:
                content = f.read()
            
            print(f"\nAnalyzing file: {file_name}")
            result = analyzer.comprehensive_analysis(content)
            result['source_file'] = file_name
            comprehensive_results.append(result)
            
            # Print key findings
            if 'entities' in result and 'error' not in result['entities']:
                entities = result['entities']['entities']
                print(f"  Entities found: {len(entities)}")
                
                # Show top entities
                top_entities = sorted(entities, key=lambda x: x['salience'], reverse=True)[:3]
                for entity in top_entities:
                    print(f"    - {entity['name']} ({entity['type']}, salience: {entity['salience']:.3f})")
            
            if 'classification' in result and 'error' not in result['classification']:
                categories = result['classification']['categories']
                if categories:
                    top_category = categories[0]
                    print(f"  Top category: {top_category['name']} (confidence: {top_category['confidence']:.3f})")
            
            if 'syntax' in result and 'error' not in result['syntax']:
                syntax = result['syntax']
                print(f"  Tokens: {syntax['total_tokens']}, Sentences: {syntax['total_sentences']}")
        
        except FileNotFoundError:
            print(f"Warning: {file_name} not found, skipping...")
        except Exception as e:
            print(f"Error analyzing {file_name}: {e}")
    
    # Generate entity summary
    if comprehensive_results:
        entity_summary = analyzer.create_entity_summary(comprehensive_results)
        
        # Save all results
        final_results = {
            'comprehensive_analysis': comprehensive_results,
            'entity_summary': entity_summary,
            'analysis_timestamp': str(pd.Timestamp.now()) if 'pd' in globals() else 'unavailable'
        }
        
        with open('comprehensive_language_analysis.json', 'w') as f:
            json.dump(final_results, f, indent=2, default=str)
        
        print("\n=== Entity Summary ===")
        print(f"Total entities found: {entity_summary['total_entities_found']}")
        print(f"Unique entity names: {entity_summary['unique_entity_names']}")
        print(f"Entity types found: {', '.join(entity_summary['entity_types_found'])}")
        
        print("\nMost common entities:")
        for entity_name, count in entity_summary['most_common_entities'][:5]:
            print(f"  - {entity_name}: {count} times")
        
        print("\nComprehensive analysis saved to: comprehensive_language_analysis.json")

if __name__ == "__main__":
    demonstrate_entity_analysis()
EOF

# Run entity analysis
python entity_analysis.py
```

---

## 🚀 Solution Method 4: Advanced Features and Batch Processing

### Step 1: Advanced Analysis Features

```bash
# Create advanced features script
cat > advanced_language_features.py << 'EOF'
from google.cloud import language_v1
from google.cloud import storage
import json
import asyncio
from concurrent.futures import ThreadPoolExecutor
from typing import Dict, List, Any
import time

class AdvancedLanguageAnalyzer:
    def __init__(self, project_id: str, bucket_name: str):
        self.client = language_v1.LanguageServiceClient()
        self.storage_client = storage.Client()
        self.project_id = project_id
        self.bucket_name = bucket_name
    
    def analyze_document_from_gcs(self, gcs_uri: str) -> Dict[str, Any]:
        """Analyze document stored in Google Cloud Storage"""
        
        document = language_v1.Document(
            gcs_content_uri=gcs_uri,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        # Perform all types of analysis
        results = {}
        
        try:
            # Sentiment analysis
            sentiment_response = self.client.analyze_sentiment(
                request={'document': document}
            )
            results['sentiment'] = {
                'score': sentiment_response.document_sentiment.score,
                'magnitude': sentiment_response.document_sentiment.magnitude
            }
        except Exception as e:
            results['sentiment'] = {'error': str(e)}
        
        try:
            # Entity analysis
            entity_response = self.client.analyze_entities(
                request={'document': document}
            )
            results['entities'] = [
                {
                    'name': entity.name,
                    'type': entity.type_.name,
                    'salience': entity.salience
                }
                for entity in entity_response.entities
            ]
        except Exception as e:
            results['entities'] = {'error': str(e)}
        
        try:
            # Classification
            classification_response = self.client.classify_text(
                request={'document': document}
            )
            results['classification'] = [
                {
                    'name': category.name,
                    'confidence': category.confidence
                }
                for category in classification_response.categories
            ]
        except Exception as e:
            results['classification'] = {'error': str(e)}
        
        return results
    
    def multilingual_analysis(self, texts_with_languages: List[tuple]) -> Dict[str, Any]:
        """Analyze texts in multiple languages"""
        
        results = {}
        
        for text, language_code in texts_with_languages:
            try:
                document = language_v1.Document(
                    content=text,
                    type_=language_v1.Document.Type.PLAIN_TEXT,
                    language=language_code
                )
                
                # Sentiment analysis
                sentiment_response = self.client.analyze_sentiment(
                    request={'document': document}
                )
                
                # Entity analysis
                entity_response = self.client.analyze_entities(
                    request={'document': document}
                )
                
                results[language_code] = {
                    'sentiment': {
                        'score': sentiment_response.document_sentiment.score,
                        'magnitude': sentiment_response.document_sentiment.magnitude
                    },
                    'entities': [
                        {
                            'name': entity.name,
                            'type': entity.type_.name,
                            'salience': entity.salience
                        }
                        for entity in entity_response.entities
                    ],
                    'text_preview': text[:100] + "..." if len(text) > 100 else text
                }
                
            except Exception as e:
                results[language_code] = {'error': str(e)}
        
        return results
    
    def batch_analysis_with_threading(self, text_list: List[str], max_workers: int = 5) -> List[Dict[str, Any]]:
        """Perform batch analysis using threading for better performance"""
        
        def analyze_single_text(text_with_index):
            index, text = text_with_index
            
            try:
                document = language_v1.Document(
                    content=text,
                    type_=language_v1.Document.Type.PLAIN_TEXT
                )
                
                # Analyze sentiment
                sentiment_response = self.client.analyze_sentiment(
                    request={'document': document}
                )
                
                # Extract entities
                entity_response = self.client.analyze_entities(
                    request={'document': document}
                )
                
                # Analyze syntax
                syntax_response = self.client.analyze_syntax(
                    request={'document': document}
                )
                
                return {
                    'index': index,
                    'status': 'success',
                    'sentiment': {
                        'score': sentiment_response.document_sentiment.score,
                        'magnitude': sentiment_response.document_sentiment.magnitude
                    },
                    'entities_count': len(entity_response.entities),
                    'tokens_count': len(syntax_response.tokens),
                    'sentences_count': len(syntax_response.sentences),
                    'processing_time': time.time()
                }
                
            except Exception as e:
                return {
                    'index': index,
                    'status': 'error',
                    'error': str(e),
                    'processing_time': time.time()
                }
        
        # Prepare data with indices
        indexed_texts = [(i, text) for i, text in enumerate(text_list)]
        
        # Process in parallel
        results = []
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            start_time = time.time()
            
            futures = [
                executor.submit(analyze_single_text, text_item)
                for text_item in indexed_texts
            ]
            
            for future in futures:
                result = future.result()
                result['processing_time'] = result['processing_time'] - start_time
                results.append(result)
        
        return sorted(results, key=lambda x: x['index'])
    
    def content_moderation_analysis(self, text_content: str) -> Dict[str, Any]:
        """Analyze content for moderation purposes"""
        
        document = language_v1.Document(
            content=text_content,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        # Sentiment analysis for emotional tone
        sentiment_response = self.client.analyze_sentiment(
            request={'document': document}
        )
        
        # Entity analysis to identify mentions
        entity_response = self.client.analyze_entities(
            request={'document': document}
        )
        
        # Classification for content type
        try:
            classification_response = self.client.classify_text(
                request={'document': document}
            )
            categories = [
                {
                    'name': category.name,
                    'confidence': category.confidence
                }
                for category in classification_response.categories
            ]
        except:
            categories = []
        
        # Analyze for potential issues
        moderation_flags = []
        
        # Check for extreme sentiment
        if sentiment_response.document_sentiment.magnitude > 0.8:
            if sentiment_response.document_sentiment.score < -0.5:
                moderation_flags.append("High negative sentiment detected")
            elif sentiment_response.document_sentiment.score > 0.8:
                moderation_flags.append("Extremely positive sentiment (potential spam)")
        
        # Check for person mentions (privacy concern)
        person_entities = [
            entity for entity in entity_response.entities
            if entity.type_.name == 'PERSON'
        ]
        
        if len(person_entities) > 3:
            moderation_flags.append("Multiple person mentions detected")
        
        return {
            'sentiment': {
                'score': sentiment_response.document_sentiment.score,
                'magnitude': sentiment_response.document_sentiment.magnitude
            },
            'entities': {
                'total': len(entity_response.entities),
                'persons': len(person_entities),
                'person_names': [entity.name for entity in person_entities]
            },
            'categories': categories,
            'moderation_flags': moderation_flags,
            'risk_level': 'high' if len(moderation_flags) > 2 else 'medium' if moderation_flags else 'low'
        }
    
    def create_language_insights_dashboard(self, analysis_results: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Create insights dashboard from analysis results"""
        
        dashboard = {
            'overview': {
                'total_documents': len(analysis_results),
                'successful_analyses': len([r for r in analysis_results if r.get('status') == 'success']),
                'average_processing_time': 0,
                'total_processing_time': 0
            },
            'sentiment_insights': {
                'average_sentiment': 0,
                'sentiment_distribution': {'positive': 0, 'neutral': 0, 'negative': 0},
                'highest_magnitude': 0
            },
            'entity_insights': {
                'total_entities': 0,
                'average_entities_per_document': 0,
                'most_common_entity_types': {}
            },
            'content_insights': {
                'average_length': 0,
                'total_tokens': 0,
                'total_sentences': 0
            }
        }
        
        successful_results = [r for r in analysis_results if r.get('status') == 'success']
        
        if not successful_results:
            return dashboard
        
        # Calculate overview metrics
        processing_times = [r.get('processing_time', 0) for r in successful_results]
        dashboard['overview']['average_processing_time'] = sum(processing_times) / len(processing_times)
        dashboard['overview']['total_processing_time'] = sum(processing_times)
        
        # Calculate sentiment insights
        sentiments = [r.get('sentiment', {}) for r in successful_results if 'sentiment' in r]
        if sentiments:
            scores = [s.get('score', 0) for s in sentiments]
            magnitudes = [s.get('magnitude', 0) for s in sentiments]
            
            dashboard['sentiment_insights']['average_sentiment'] = sum(scores) / len(scores)
            dashboard['sentiment_insights']['highest_magnitude'] = max(magnitudes)
            
            # Sentiment distribution
            for score in scores:
                if score > 0.1:
                    dashboard['sentiment_insights']['sentiment_distribution']['positive'] += 1
                elif score < -0.1:
                    dashboard['sentiment_insights']['sentiment_distribution']['negative'] += 1
                else:
                    dashboard['sentiment_insights']['sentiment_distribution']['neutral'] += 1
        
        # Calculate entity insights
        entity_counts = [r.get('entities_count', 0) for r in successful_results if 'entities_count' in r]
        if entity_counts:
            dashboard['entity_insights']['total_entities'] = sum(entity_counts)
            dashboard['entity_insights']['average_entities_per_document'] = sum(entity_counts) / len(entity_counts)
        
        # Calculate content insights
        token_counts = [r.get('tokens_count', 0) for r in successful_results if 'tokens_count' in r]
        sentence_counts = [r.get('sentences_count', 0) for r in successful_results if 'sentences_count' in r]
        
        if token_counts:
            dashboard['content_insights']['total_tokens'] = sum(token_counts)
            dashboard['content_insights']['average_length'] = sum(token_counts) / len(token_counts)
        
        if sentence_counts:
            dashboard['content_insights']['total_sentences'] = sum(sentence_counts)
        
        return dashboard

def demonstrate_advanced_features():
    """Demonstrate advanced Natural Language API features"""
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-natural-language"
    
    analyzer = AdvancedLanguageAnalyzer(project_id, bucket_name)
    
    # Load text files for batch processing
    text_files = [
        'positive_review.txt',
        'negative_review.txt', 
        'neutral_news.txt',
        'technical_article.txt',
        'business_email.txt'
    ]
    
    texts = []
    for file_name in text_files:
        try:
            with open(file_name, 'r', encoding='utf-8') as f:
                texts.append(f.read())
        except FileNotFoundError:
            continue
    
    if not texts:
        print("No text files found for analysis")
        return
    
    print("=== Advanced Natural Language Features Demo ===")
    
    # Batch analysis with threading
    print("\n1. Batch Analysis with Threading...")
    start_time = time.time()
    batch_results = analyzer.batch_analysis_with_threading(texts)
    batch_time = time.time() - start_time
    
    print(f"Batch analysis completed in {batch_time:.2f} seconds")
    print(f"Successfully analyzed: {len([r for r in batch_results if r['status'] == 'success'])}/{len(batch_results)} documents")
    
    # Content moderation analysis
    print("\n2. Content Moderation Analysis...")
    moderation_results = []
    
    for i, text in enumerate(texts[:3]):  # Analyze first 3 texts
        moderation_result = analyzer.content_moderation_analysis(text)
        moderation_result['text_index'] = i
        moderation_results.append(moderation_result)
        
        print(f"Text {i+1}: Risk level - {moderation_result['risk_level']}")
        if moderation_result['moderation_flags']:
            print(f"  Flags: {', '.join(moderation_result['moderation_flags'])}")
    
    # Multilingual analysis (if multilingual texts available)
    print("\n3. Multilingual Analysis...")
    multilingual_texts = [
        ("This product is amazing! I love it so much.", "en"),
        ("Este producto es increíble. Me encanta.", "es"),
        ("Ce produit est fantastique. Je l'adore.", "fr")
    ]
    
    multilingual_results = analyzer.multilingual_analysis(multilingual_texts)
    
    for lang, result in multilingual_results.items():
        if 'error' not in result:
            print(f"Language {lang}: Sentiment score = {result['sentiment']['score']:.3f}")
    
    # Create insights dashboard
    print("\n4. Creating Insights Dashboard...")
    dashboard = analyzer.create_language_insights_dashboard(batch_results)
    
    # Save all results
    final_results = {
        'batch_analysis': batch_results,
        'moderation_analysis': moderation_results,
        'multilingual_analysis': multilingual_results,
        'insights_dashboard': dashboard,
        'performance_metrics': {
            'batch_processing_time': batch_time,
            'documents_processed': len(batch_results)
        }
    }
    
    with open('advanced_language_analysis.json', 'w') as f:
        json.dump(final_results, f, indent=2, default=str)
    
    print("Advanced analysis results saved to: advanced_language_analysis.json")
    
    # Print dashboard summary
    print("\n=== Insights Dashboard ===")
    print(f"Total documents processed: {dashboard['overview']['total_documents']}")
    print(f"Average sentiment score: {dashboard['sentiment_insights']['average_sentiment']:.3f}")
    print(f"Average entities per document: {dashboard['entity_insights']['average_entities_per_document']:.1f}")
    print(f"Average processing time: {dashboard['overview']['average_processing_time']:.3f} seconds")

if __name__ == "__main__":
    demonstrate_advanced_features()
EOF

# Run advanced features demonstration
python advanced_language_features.py
```

---

## ✅ Validation

### Test All Natural Language API Features

```bash
# Create comprehensive validation script
cat > validate_natural_language.py << 'EOF'
from google.cloud import language_v1
import json
import os

def validate_api_access():
    """Validate API access and basic functionality"""
    try:
        client = language_v1.LanguageServiceClient()
        
        # Test with simple text
        test_text = "Google Cloud Natural Language API is powerful."
        document = language_v1.Document(
            content=test_text,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        # Test sentiment analysis
        sentiment_response = client.analyze_sentiment(
            request={'document': document}
        )
        
        print("✓ API access validated successfully")
        print(f"✓ Sentiment analysis working (score: {sentiment_response.document_sentiment.score})")
        
        return True
        
    except Exception as e:
        print(f"✗ API access validation failed: {e}")
        return False

def validate_all_features():
    """Validate all Natural Language API features"""
    
    if not validate_api_access():
        return False
    
    client = language_v1.LanguageServiceClient()
    test_text = "Google Cloud Platform offers machine learning APIs. John Smith works at Google in Mountain View, California."
    
    document = language_v1.Document(
        content=test_text,
        type_=language_v1.Document.Type.PLAIN_TEXT
    )
    
    features_tested = {}
    
    # Test entity analysis
    try:
        entity_response = client.analyze_entities(request={'document': document})
        features_tested['entity_analysis'] = {
            'status': 'success',
            'entities_found': len(entity_response.entities)
        }
        print(f"✓ Entity analysis: {len(entity_response.entities)} entities found")
    except Exception as e:
        features_tested['entity_analysis'] = {'status': 'error', 'error': str(e)}
        print(f"✗ Entity analysis failed: {e}")
    
    # Test syntax analysis
    try:
        syntax_response = client.analyze_syntax(request={'document': document})
        features_tested['syntax_analysis'] = {
            'status': 'success',
            'tokens_found': len(syntax_response.tokens)
        }
        print(f"✓ Syntax analysis: {len(syntax_response.tokens)} tokens analyzed")
    except Exception as e:
        features_tested['syntax_analysis'] = {'status': 'error', 'error': str(e)}
        print(f"✗ Syntax analysis failed: {e}")
    
    # Test classification
    try:
        classification_response = client.classify_text(request={'document': document})
        features_tested['text_classification'] = {
            'status': 'success',
            'categories_found': len(classification_response.categories)
        }
        print(f"✓ Text classification: {len(classification_response.categories)} categories found")
    except Exception as e:
        features_tested['text_classification'] = {'status': 'error', 'error': str(e)}
        print(f"✗ Text classification failed: {e}")
    
    # Save validation results
    with open('api_validation_results.json', 'w') as f:
        json.dump(features_tested, f, indent=2)
    
    print("Validation results saved to: api_validation_results.json")
    
    successful_features = len([f for f in features_tested.values() if f['status'] == 'success'])
    total_features = len(features_tested)
    
    print(f"\nValidation Summary: {successful_features}/{total_features} features working correctly")
    
    return successful_features == total_features

if __name__ == "__main__":
    validate_all_features()
EOF

# Run comprehensive validation
echo "=== Natural Language API Validation ==="

# Check if all required files exist
echo "Checking analysis results..."
ls -la *analysis*.json 2>/dev/null || echo "Some analysis files missing"

# Validate API functionality
python validate_natural_language.py

# Check Cloud Storage integration
echo "Checking Cloud Storage integration..."
gsutil ls gs://$BUCKET_NAME/ || echo "Bucket access issue"

# Verify all analysis scripts ran successfully
echo "Verifying analysis outputs..."
for script in sentiment_analysis.py entity_analysis.py advanced_language_features.py; do
    if [ -f "$script" ]; then
        echo "✓ $script exists"
    else
        echo "✗ $script missing"
    fi
done

echo "=== Validation Complete ==="
```

---

## 🔧 Troubleshooting

**Issue**: API quota exceeded
- Check current quota usage
- Implement rate limiting
- Consider upgrading quota

**Issue**: Language not supported
- Verify language code format
- Check supported languages list
- Use language detection first

**Issue**: Classification returns no results
- Check text length (minimum ~20 words)
- Ensure content is classifiable
- Try with different text samples

---

## 📚 Key Learning Points

- **Sentiment Analysis**: Understanding emotional tone and magnitude
- **Entity Recognition**: Extracting people, places, organizations
- **Text Classification**: Categorizing content automatically
- **Syntax Analysis**: Understanding grammatical structure
- **Multilingual Support**: Processing text in multiple languages
- **Batch Processing**: Efficient analysis of multiple documents

---

## 🏆 Challenge Complete!

You've successfully mastered Google Cloud Natural Language API with:
- ✅ Comprehensive sentiment analysis with magnitude interpretation
- ✅ Advanced entity recognition and extraction
- ✅ Text classification for content categorization
- ✅ Detailed syntax analysis with part-of-speech tagging
- ✅ Batch processing and performance optimization
- ✅ Content moderation and multilingual analysis

<div align="center">

**🎉 Congratulations! You've completed ARC114!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC100%20Data%20Loss%20Prevention-blue?style=for-the-badge)](../14-ARC100-Data-Loss-Prevention-API-Qwik-Start-Challenge-Lab/)

</div>
