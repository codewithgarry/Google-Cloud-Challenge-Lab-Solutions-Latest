# ARC110: Create a Streaming Data Lake on Cloud Storage: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Data Lake](https://img.shields.io/badge/Data%20Lake-34A853?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC110 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll create a streaming data lake using Cloud Storage, Pub/Sub, Dataflow, and BigQuery to handle real-time data ingestion and processing.

## 📋 Challenge Tasks

### Task 1: Create Cloud Storage Data Lake Structure

Create organized bucket structure for data lake.

### Task 2: Set up Pub/Sub for Streaming Data

Configure topics and subscriptions for data ingestion.

### Task 3: Implement Dataflow Pipeline

Create streaming pipeline for data processing.

### Task 4: Configure BigQuery Integration

Set up external tables and views.

### Task 5: Monitor and Optimize Pipeline

Implement monitoring and performance optimization.

---

## 🚀 Solution Method 1: Data Lake Infrastructure Setup

### Step 1: Environment Setup

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1
export BUCKET_NAME=${PROJECT_ID}-data-lake
export PUBSUB_TOPIC=streaming-data
export PUBSUB_SUBSCRIPTION=streaming-data-sub
export DATASET_NAME=streaming_analytics
export TABLE_NAME=realtime_events

# Enable required APIs
gcloud services enable \
    storage.googleapis.com \
    pubsub.googleapis.com \
    dataflow.googleapis.com \
    bigquery.googleapis.com \
    cloudbuild.googleapis.com

# Create service account for Dataflow
gcloud iam service-accounts create dataflow-sa \
    --display-name="Dataflow Service Account"

# Grant necessary permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/dataflow.worker"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/pubsub.subscriber"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dataflow-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"
```

### Step 2: Create Data Lake Storage Structure

```bash
# Create main data lake bucket
gsutil mb -l $REGION gs://$BUCKET_NAME

# Create organized folder structure
gsutil -m cp /dev/null gs://$BUCKET_NAME/raw-data/.keep
gsutil -m cp /dev/null gs://$BUCKET_NAME/processed-data/.keep
gsutil -m cp /dev/null gs://$BUCKET_NAME/archived-data/.keep
gsutil -m cp /dev/null gs://$BUCKET_NAME/temp-data/.keep
gsutil -m cp /dev/null gs://$BUCKET_NAME/staging/.keep

# Create partitioned structure for raw data
gsutil -m cp /dev/null gs://$BUCKET_NAME/raw-data/year=2023/month=01/day=01/.keep
gsutil -m cp /dev/null gs://$BUCKET_NAME/raw-data/year=2023/month=01/day=02/.keep

# Set lifecycle policy for cost optimization
cat > lifecycle.json << 'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "ARCHIVE"},
        "condition": {"age": 365}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"age": 2555}
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME

# Set up versioning for data integrity
gsutil versioning set on gs://$BUCKET_NAME
```

---

## 🚀 Solution Method 2: Pub/Sub Streaming Setup

### Step 1: Create Pub/Sub Resources

```bash
# Create Pub/Sub topic
gcloud pubsub topics create $PUBSUB_TOPIC

# Create subscription
gcloud pubsub subscriptions create $PUBSUB_SUBSCRIPTION \
    --topic=$PUBSUB_TOPIC \
    --ack-deadline=60

# Create dead letter topic for failed messages
gcloud pubsub topics create ${PUBSUB_TOPIC}-deadletter

gcloud pubsub subscriptions create ${PUBSUB_SUBSCRIPTION}-deadletter \
    --topic=${PUBSUB_TOPIC}-deadletter

# Update subscription with dead letter policy
gcloud pubsub subscriptions update $PUBSUB_SUBSCRIPTION \
    --dead-letter-topic=projects/$PROJECT_ID/topics/${PUBSUB_TOPIC}-deadletter \
    --max-delivery-attempts=5
```

### Step 2: Create Data Generator

```bash
# Create data generator script
cat > data_generator.py << 'EOF'
import json
import random
import time
from datetime import datetime
from google.cloud import pubsub_v1
import uuid
import threading

class StreamingDataGenerator:
    def __init__(self, project_id, topic_name):
        self.project_id = project_id
        self.topic_name = topic_name
        self.publisher = pubsub_v1.PublisherClient()
        self.topic_path = self.publisher.topic_path(project_id, topic_name)
        
    def generate_user_event(self):
        """Generate a user interaction event"""
        events = ['page_view', 'click', 'purchase', 'signup', 'logout']
        pages = ['home', 'product', 'checkout', 'profile', 'search']
        devices = ['mobile', 'desktop', 'tablet']
        
        return {
            'event_id': str(uuid.uuid4()),
            'user_id': f"user_{random.randint(1000, 9999)}",
            'event_type': random.choice(events),
            'page': random.choice(pages),
            'device_type': random.choice(devices),
            'timestamp': datetime.utcnow().isoformat(),
            'session_id': str(uuid.uuid4())[:8],
            'value': round(random.uniform(0, 1000), 2) if random.choice(events) == 'purchase' else None,
            'properties': {
                'user_agent': 'Mozilla/5.0',
                'ip_address': f"{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}",
                'country': random.choice(['US', 'CA', 'UK', 'DE', 'FR', 'JP']),
                'referrer': random.choice(['google.com', 'facebook.com', 'direct', 'twitter.com'])
            }
        }
    
    def generate_system_metric(self):
        """Generate system metrics"""
        services = ['web-server', 'database', 'cache', 'queue', 'auth-service']
        
        return {
            'metric_id': str(uuid.uuid4()),
            'service_name': random.choice(services),
            'metric_type': 'system_metric',
            'timestamp': datetime.utcnow().isoformat(),
            'metrics': {
                'cpu_usage': round(random.uniform(0, 100), 2),
                'memory_usage': round(random.uniform(0, 100), 2),
                'disk_usage': round(random.uniform(0, 100), 2),
                'network_in': random.randint(1000, 10000),
                'network_out': random.randint(1000, 10000),
                'response_time': round(random.uniform(50, 500), 2)
            },
            'instance_id': f"instance-{random.randint(1, 10)}"
        }
    
    def generate_iot_sensor_data(self):
        """Generate IoT sensor data"""
        sensors = ['temperature', 'humidity', 'pressure', 'motion', 'light']
        
        return {
            'sensor_id': f"sensor_{random.randint(100, 999)}",
            'sensor_type': random.choice(sensors),
            'data_type': 'iot_sensor',
            'timestamp': datetime.utcnow().isoformat(),
            'location': {
                'latitude': round(random.uniform(-90, 90), 6),
                'longitude': round(random.uniform(-180, 180), 6),
                'building': f"Building-{random.randint(1, 5)}",
                'floor': random.randint(1, 10),
                'room': f"Room-{random.randint(101, 999)}"
            },
            'readings': {
                'value': round(random.uniform(10, 35) if random.choice(sensors) == 'temperature' else random.uniform(0, 100), 2),
                'unit': 'celsius' if random.choice(sensors) == 'temperature' else 'percent',
                'quality': random.choice(['good', 'fair', 'poor']),
                'battery_level': round(random.uniform(0, 100), 1)
            }
        }
    
    def publish_message(self, data):
        """Publish message to Pub/Sub"""
        try:
            message_data = json.dumps(data).encode('utf-8')
            future = self.publisher.publish(self.topic_path, message_data)
            message_id = future.result()
            print(f"Published message ID: {message_id}")
            return message_id
        except Exception as e:
            print(f"Error publishing message: {e}")
            return None
    
    def start_streaming(self, duration_minutes=60, messages_per_second=10):
        """Start streaming data"""
        end_time = time.time() + (duration_minutes * 60)
        
        def stream_data_type(data_generator, name):
            while time.time() < end_time:
                try:
                    data = data_generator()
                    self.publish_message(data)
                    time.sleep(1.0 / messages_per_second)
                except Exception as e:
                    print(f"Error in {name} thread: {e}")
                    time.sleep(1)
        
        # Start multiple threads for different data types
        threads = [
            threading.Thread(target=stream_data_type, args=(self.generate_user_event, "user_events")),
            threading.Thread(target=stream_data_type, args=(self.generate_system_metric, "system_metrics")),
            threading.Thread(target=stream_data_type, args=(self.generate_iot_sensor_data, "iot_sensors"))
        ]
        
        print(f"Starting streaming for {duration_minutes} minutes...")
        for thread in threads:
            thread.start()
        
        for thread in threads:
            thread.join()
        
        print("Streaming completed!")

def main():
    import os
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    topic_name = 'streaming-data'
    
    generator = StreamingDataGenerator(project_id, topic_name)
    
    # Generate sample data for 30 minutes
    generator.start_streaming(duration_minutes=30, messages_per_second=5)

if __name__ == "__main__":
    main()
EOF

# Install dependencies
pip install google-cloud-pubsub

# Start data generation in background
export GOOGLE_CLOUD_PROJECT=$PROJECT_ID
python data_generator.py &
```

---

## 🚀 Solution Method 3: Dataflow Streaming Pipeline

### Step 1: Create Dataflow Pipeline

```bash
# Create Dataflow pipeline script
cat > streaming_pipeline.py << 'EOF'
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, StandardOptions
from apache_beam.transforms.window import FixedWindows
from apache_beam.transforms.trigger import AfterWatermark, AfterCount, Repeatedly
import json
from datetime import datetime
import logging

class ParseJsonMessage(beam.DoFn):
    def process(self, message):
        try:
            data = json.loads(message.decode('utf-8'))
            yield data
        except Exception as e:
            logging.error(f"Error parsing JSON: {e}")
            yield beam.pvalue.TaggedOutput('error', message)

class FilterAndEnrich(beam.DoFn):
    def process(self, element):
        try:
            # Add processing timestamp
            element['processed_timestamp'] = datetime.utcnow().isoformat()
            
            # Add data quality indicators
            element['data_quality'] = {
                'completeness': self.check_completeness(element),
                'validity': self.check_validity(element)
            }
            
            # Route by data type
            data_type = element.get('data_type', element.get('metric_type', 'unknown'))
            
            if data_type == 'iot_sensor':
                yield beam.pvalue.TaggedOutput('iot', element)
            elif data_type == 'system_metric':
                yield beam.pvalue.TaggedOutput('metrics', element)
            elif 'event_type' in element:
                yield beam.pvalue.TaggedOutput('events', element)
            else:
                yield beam.pvalue.TaggedOutput('other', element)
                
        except Exception as e:
            logging.error(f"Error in filtering: {e}")
            yield beam.pvalue.TaggedOutput('error', element)
    
    def check_completeness(self, element):
        required_fields = ['timestamp']
        return all(field in element for field in required_fields)
    
    def check_validity(self, element):
        try:
            datetime.fromisoformat(element['timestamp'].replace('Z', '+00:00'))
            return True
        except:
            return False

class FormatForBigQuery(beam.DoFn):
    def process(self, element):
        try:
            # Flatten nested structures for BigQuery
            flattened = {}
            
            for key, value in element.items():
                if isinstance(value, dict):
                    for sub_key, sub_value in value.items():
                        flattened[f"{key}_{sub_key}"] = str(sub_value)
                else:
                    flattened[key] = str(value) if value is not None else None
            
            yield flattened
        except Exception as e:
            logging.error(f"Error formatting for BigQuery: {e}")

def create_pipeline_options():
    options = PipelineOptions()
    
    # Set Dataflow-specific options
    options.view_as(StandardOptions).streaming = True
    
    return options

def run_pipeline():
    import os
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-data-lake"
    
    # BigQuery table schemas
    events_schema = {
        'fields': [
            {'name': 'event_id', 'type': 'STRING'},
            {'name': 'user_id', 'type': 'STRING'},
            {'name': 'event_type', 'type': 'STRING'},
            {'name': 'page', 'type': 'STRING'},
            {'name': 'device_type', 'type': 'STRING'},
            {'name': 'timestamp', 'type': 'TIMESTAMP'},
            {'name': 'session_id', 'type': 'STRING'},
            {'name': 'value', 'type': 'FLOAT'},
            {'name': 'processed_timestamp', 'type': 'TIMESTAMP'}
        ]
    }
    
    pipeline_options = create_pipeline_options()
    
    with beam.Pipeline(options=pipeline_options) as p:
        # Read from Pub/Sub
        messages = (p 
                   | 'Read from Pub/Sub' >> beam.io.ReadFromPubSub(
                       subscription=f'projects/{project_id}/subscriptions/streaming-data-sub'))
        
        # Parse and process messages
        parsed_messages = (messages 
                          | 'Parse JSON' >> beam.ParDo(ParseJsonMessage()).with_outputs('error', main='main'))
        
        # Filter and enrich data
        processed_data = (parsed_messages.main 
                         | 'Filter and Enrich' >> beam.ParDo(FilterAndEnrich()).with_outputs(
                             'iot', 'metrics', 'events', 'other', 'error'))
        
        # Write events to BigQuery
        events_formatted = (processed_data.events 
                           | 'Format Events for BigQuery' >> beam.ParDo(FormatForBigQuery())
                           | 'Write Events to BigQuery' >> beam.io.WriteToBigQuery(
                               table=f'{project_id}:streaming_analytics.user_events',
                               schema=events_schema,
                               create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                               write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND))
        
        # Write raw data to Cloud Storage with windowing
        windowed_data = (parsed_messages.main 
                        | 'Fixed Window' >> beam.WindowInto(FixedWindows(60)))  # 1-minute windows
        
        (windowed_data 
         | 'Convert to JSON strings' >> beam.Map(lambda x: json.dumps(x))
         | 'Write to Storage' >> beam.io.WriteToText(
             f'gs://{bucket_name}/raw-data/',
             file_name_suffix='.json',
             num_shards=1))
        
        # Write errors to separate location
        (parsed_messages.error 
         | 'Write Errors' >> beam.io.WriteToText(
             f'gs://{bucket_name}/errors/',
             file_name_suffix='.txt'))

if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run_pipeline()
EOF

# Install Apache Beam
pip install apache-beam[gcp]

# Run the pipeline locally (for testing)
export GOOGLE_CLOUD_PROJECT=$PROJECT_ID
python streaming_pipeline.py
```

### Step 2: Deploy to Dataflow

```bash
# Create Dataflow job
gcloud dataflow jobs run streaming-data-lake \
    --gcs-location gs://dataflow-templates-$REGION/latest/PubSub_to_BigQuery \
    --region $REGION \
    --parameters \
inputTopic=projects/$PROJECT_ID/topics/$PUBSUB_TOPIC,\
outputTableSpec=$PROJECT_ID:$DATASET_NAME.$TABLE_NAME

# Or run custom pipeline
python streaming_pipeline.py \
    --project=$PROJECT_ID \
    --region=$REGION \
    --staging_location=gs://$BUCKET_NAME/staging \
    --temp_location=gs://$BUCKET_NAME/temp-data \
    --job_name=streaming-data-lake-$(date +%Y%m%d-%H%M%S) \
    --runner=DataflowRunner \
    --service_account_email=dataflow-sa@$PROJECT_ID.iam.gserviceaccount.com
```

---

## 🚀 Solution Method 4: BigQuery Integration

### Step 1: Create BigQuery Dataset and Tables

```bash
# Create BigQuery dataset
bq mk --location=$REGION $DATASET_NAME

# Create external table for Cloud Storage data
bq mk --external_table_definition=@table_def.json \
    $DATASET_NAME.external_raw_data

# Create table definition for external table
cat > table_def.json << 'EOF'
{
  "sourceFormat": "NEWLINE_DELIMITED_JSON",
  "sourceUris": [
    "gs://PROJECT_ID-data-lake/raw-data/*.json"
  ],
  "schema": {
    "fields": [
      {"name": "event_id", "type": "STRING"},
      {"name": "timestamp", "type": "TIMESTAMP"},
      {"name": "data_type", "type": "STRING"},
      {"name": "raw_data", "type": "STRING"}
    ]
  }
}
EOF

# Replace PROJECT_ID in the file
sed -i "s/PROJECT_ID/$PROJECT_ID/g" table_def.json

# Create the external table
bq mk --external_table_definition=@table_def.json \
    $DATASET_NAME.external_raw_data

# Create materialized views for analytics
bq query --use_legacy_sql=false << 'EOF'
CREATE OR REPLACE VIEW `PROJECT_ID.streaming_analytics.user_events_hourly` AS
SELECT
  DATE_TRUNC(TIMESTAMP(timestamp), HOUR) as hour,
  event_type,
  device_type,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users,
  AVG(SAFE_CAST(value AS FLOAT64)) as avg_value
FROM `PROJECT_ID.streaming_analytics.user_events`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
GROUP BY 1, 2, 3
ORDER BY 1 DESC
EOF

# Replace PROJECT_ID in the query
sed -i "s/PROJECT_ID/$PROJECT_ID/g" <<< "$(cat <<'EOF'
CREATE OR REPLACE VIEW `$PROJECT_ID.streaming_analytics.user_events_hourly` AS
SELECT
  DATE_TRUNC(TIMESTAMP(timestamp), HOUR) as hour,
  event_type,
  device_type,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users,
  AVG(SAFE_CAST(value AS FLOAT64)) as avg_value
FROM `$PROJECT_ID.streaming_analytics.user_events`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
GROUP BY 1, 2, 3
ORDER BY 1 DESC
EOF
)"

bq query --use_legacy_sql=false "$(cat <<EOF
CREATE OR REPLACE VIEW \`$PROJECT_ID.streaming_analytics.user_events_hourly\` AS
SELECT
  DATE_TRUNC(TIMESTAMP(timestamp), HOUR) as hour,
  event_type,
  device_type,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users,
  AVG(SAFE_CAST(value AS FLOAT64)) as avg_value
FROM \`$PROJECT_ID.streaming_analytics.user_events\`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
GROUP BY 1, 2, 3
ORDER BY 1 DESC
EOF
)"
```

---

## 🚀 Solution Method 5: Monitoring and Optimization

### Step 1: Create Monitoring Dashboard

```bash
# Create monitoring script
cat > monitoring.py << 'EOF'
from google.cloud import monitoring_v3
from google.cloud import bigquery
import time

class DataLakeMonitor:
    def __init__(self, project_id):
        self.project_id = project_id
        self.monitoring_client = monitoring_v3.MetricServiceClient()
        self.bq_client = bigquery.Client()
        
    def get_pubsub_metrics(self):
        """Get Pub/Sub metrics"""
        project_name = f"projects/{self.project_id}"
        
        # Query for message count
        interval = monitoring_v3.TimeInterval({
            'end_time': {'seconds': int(time.time())},
            'start_time': {'seconds': int(time.time() - 3600)}
        })
        
        filter = 'metric.type="pubsub.googleapis.com/topic/send_message_operation_count"'
        
        results = self.monitoring_client.list_time_series(
            request={
                "name": project_name,
                "filter": filter,
                "interval": interval,
                "view": monitoring_v3.ListTimeSeriesRequest.TimeSeriesView.FULL
            }
        )
        
        return list(results)
    
    def get_storage_metrics(self):
        """Get Cloud Storage metrics"""
        query = f"""
        SELECT
            TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), HOUR) as check_time,
            COUNT(*) as file_count,
            SUM(size) as total_size_bytes
        FROM `{self.project_id}.region-us.INFORMATION_SCHEMA.OBJECTS_EXTENDED`
        WHERE bucket_name = '{self.project_id}-data-lake'
        """
        
        job = self.bq_client.query(query)
        return list(job.result())
    
    def get_bigquery_metrics(self):
        """Get BigQuery metrics"""
        query = f"""
        SELECT
            table_name,
            row_count,
            size_bytes,
            TIMESTAMP_MILLIS(last_modified_time) as last_modified
        FROM `{self.project_id}.streaming_analytics.INFORMATION_SCHEMA.TABLE_STORAGE`
        """
        
        job = self.bq_client.query(query)
        return list(job.result())
    
    def generate_report(self):
        """Generate monitoring report"""
        print("=== Data Lake Monitoring Report ===")
        
        # Pub/Sub metrics
        print("\n--- Pub/Sub Metrics ---")
        pubsub_metrics = self.get_pubsub_metrics()
        print(f"Message operations in last hour: {len(pubsub_metrics)}")
        
        # Storage metrics
        print("\n--- Storage Metrics ---")
        try:
            storage_metrics = self.get_storage_metrics()
            for row in storage_metrics:
                print(f"Files: {row.file_count}, Total Size: {row.total_size_bytes / (1024*1024):.2f} MB")
        except Exception as e:
            print(f"Could not retrieve storage metrics: {e}")
        
        # BigQuery metrics
        print("\n--- BigQuery Metrics ---")
        try:
            bq_metrics = self.get_bigquery_metrics()
            for row in bq_metrics:
                print(f"Table: {row.table_name}, Rows: {row.row_count}, Size: {row.size_bytes / (1024*1024):.2f} MB")
        except Exception as e:
            print(f"Could not retrieve BigQuery metrics: {e}")

def main():
    import os
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    
    monitor = DataLakeMonitor(project_id)
    monitor.generate_report()

if __name__ == "__main__":
    main()
EOF

# Run monitoring
python monitoring.py
```

---

## ✅ Validation

### Test Complete Pipeline

```bash
# Check Pub/Sub messages
gcloud pubsub topics list
gcloud pubsub subscriptions list

# Check Dataflow jobs
gcloud dataflow jobs list --region=$REGION

# Check Cloud Storage data
gsutil ls -r gs://$BUCKET_NAME/

# Check BigQuery data
bq query --use_legacy_sql=false \
"SELECT COUNT(*) as total_events FROM \`$PROJECT_ID.streaming_analytics.user_events\`"

# Test real-time analytics
bq query --use_legacy_sql=false \
"SELECT * FROM \`$PROJECT_ID.streaming_analytics.user_events_hourly\` LIMIT 10"

# Monitor pipeline health
python monitoring.py
```

---

## 🔧 Troubleshooting

**Issue**: Dataflow job fails
- Check service account permissions
- Verify bucket accessibility
- Review pipeline code for errors

**Issue**: BigQuery writes fail
- Check dataset permissions
- Verify table schema compatibility
- Review quotas and limits

**Issue**: Pub/Sub message backup
- Check subscription configuration
- Verify consumer processing rate
- Review dead letter queue

---

## 📚 Key Learning Points

- **Data Lake Architecture**: Organized storage with lifecycle policies
- **Streaming Processing**: Real-time data processing with Dataflow
- **Integration Patterns**: Pub/Sub → Dataflow → Storage/BigQuery
- **Monitoring**: Comprehensive pipeline monitoring
- **Optimization**: Performance tuning and cost optimization

---

## 🏆 Challenge Complete!

You've successfully created a streaming data lake with:
- ✅ Organized Cloud Storage data lake structure
- ✅ Real-time data ingestion via Pub/Sub
- ✅ Stream processing with Dataflow
- ✅ BigQuery integration for analytics
- ✅ Monitoring and optimization strategies

<div align="center">

**🎉 Congratulations! You've completed ARC110!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC131%20Speech%20API-blue?style=for-the-badge)](../11-ARC131-Google-Cloud-Speech-API-Qwik-Start-Challenge-Lab/)

</div>
