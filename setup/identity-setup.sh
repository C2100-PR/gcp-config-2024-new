#!/bin/bash

# Full GCP Identity Configuration

# Enable required APIs
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

# Create GitHub provider
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project=admin-coaching2100 \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# Create service account
gcloud iam service-accounts create "github-actions-sa" \
  --project=admin-coaching2100 \
  --description="Service account for GitHub Actions" \
  --display-name="GitHub Actions Service Account"

# Add IAM policy binding
gcloud iam service-accounts add-iam-policy-binding "github-actions-sa@admin-coaching2100.iam.gserviceaccount.com" \
  --project=admin-coaching2100 \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/admin-coaching2100/locations/global/workloadIdentityPools/github-pool/*"