#!/bin/bash

# Full GCP Identity Configuration
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  --project=admin-coaching2100

# Create Workload Identity Pool
gcloud iam workload-identity-pools create "github-pool" \
  --project=admin-coaching2100 \
  --location="global" \
  --display-name="GitHub Actions Pool"