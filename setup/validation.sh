#!/bin/bash

# Validation script for GCP Identity Configuration

# Check if required APIs are enabled
echo "Checking enabled APIs..."
gcloud services list --enabled --filter="name:(
  cloudresourcemanager.googleapis.com OR
  iam.googleapis.com OR
  iamcredentials.googleapis.com OR
  sts.googleapis.com
)" --project=admin-coaching2100

# Verify Workload Identity Pool
echo "\nVerifying Workload Identity Pool..."
gcloud iam workload-identity-pools describe "github-pool" \
  --project=admin-coaching2100 \
  --location="global"

# Verify GitHub provider
echo "\nVerifying GitHub provider..."
gcloud iam workload-identity-pools providers describe "github-provider" \
  --project=admin-coaching2100 \
  --location="global" \
  --workload-identity-pool="github-pool"

# Verify service account
echo "\nVerifying service account..."
gcloud iam service-accounts describe "github-actions-sa@admin-coaching2100.iam.gserviceaccount.com" \
  --project=admin-coaching2100