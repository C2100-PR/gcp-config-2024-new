#!/bin/bash

# Setup monitoring and alerts for GCP Identity Configuration

# Create custom dashboard
gcloud monitoring dashboards create \
  --project=admin-coaching2100 \
  --config-from-file=- << EOF
{
  "displayName": "Workload Identity Monitoring",
  "gridLayout": {
    "columns": "2",
    "widgets": [
      {
        "title": "Identity Pool Authentication Attempts",
        "xyChart": {
          "dataSets": [{
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "resource.type=\"workload_pool\" metric.type=\"iam.googleapis.com/workload_identity_pool/auth_attempts\""
              }
            }
          }]
        }
      },
      {
        "title": "Auth Failures",
        "xyChart": {
          "dataSets": [{
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "resource.type=\"workload_pool\" metric.type=\"iam.googleapis.com/workload_identity_pool/auth_failures\""
              }
            }
          }]
        }
      }
    ]
  }
}
EOF

# Create alert policies
gcloud alpha monitoring policies create \
  --project=admin-coaching2100 \
  --policy-from-file=- << EOF
{
  "displayName": "Workload Identity Authentication Failures",
  "documentation": {
    "content": "Alert triggered when there are multiple authentication failures from the Workload Identity Pool",
    "mimeType": "text/markdown"
  },
  "conditions": [{
    "displayName": "High Auth Failure Rate",
    "conditionThreshold": {
      "filter": "resource.type=\"workload_pool\" AND metric.type=\"iam.googleapis.com/workload_identity_pool/auth_failures\"",
      "comparison": "COMPARISON_GT",
      "thresholdValue": 5,
      "duration": "300s"
    }
  }],
  "alertStrategy": {
    "autoClose": "1800s"
  },
  "combiner": "OR",
  "enabled": true
}
EOF