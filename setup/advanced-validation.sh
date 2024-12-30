#!/bin/bash

# Advanced Validation Suite for GCP Identity Configuration

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error counter
errors=0
warnings=0

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
        ((errors++))
    fi
}

# Function to check warnings
check_warning() {
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}! $1${NC}"
        ((warnings++))
    fi
}

echo "Starting comprehensive validation..."

# 1. Critical API Validation
echo "\n=== Validating Required APIs ==="
for api in cloudresourcemanager.googleapis.com iam.googleapis.com iamcredentials.googleapis.com sts.googleapis.com; do
    gcloud services list --enabled --filter="name:$api" --format="get(name)" --project=admin-coaching2100 | grep -q $api
    check_status "API $api enabled"
done

# 2. Workload Identity Pool Validation
echo "\n=== Validating Workload Identity Pool ==="
pool_info=$(gcloud iam workload-identity-pools describe "github-pool" \
    --project=admin-coaching2100 \
    --location="global" --format="json")
echo "$pool_info" | grep -q '"state": "ACTIVE"'
check_status "Workload Identity Pool is active"

# 3. Security Configuration Validation
echo "\n=== Validating Security Configuration ==="
provider_info=$(gcloud iam workload-identity-pools providers describe "github-provider" \
    --project=admin-coaching2100 \
    --location="global" \
    --workload-identity-pool="github-pool" --format="json")

# Check attribute mapping
echo "$provider_info" | grep -q '"google.subject":"assertion.sub"'
check_status "Subject attribute mapping configured"

echo "$provider_info" | grep -q 'token.actions.githubusercontent.com'
check_status "GitHub Actions issuer URI configured"

# 4. Service Account Validation
echo "\n=== Validating Service Account ==="
sa_email="github-actions-sa@admin-coaching2100.iam.gserviceaccount.com"
sa_info=$(gcloud iam service-accounts describe "$sa_email" \
    --project=admin-coaching2100 --format="json")
check_status "Service account exists"

# Check IAM bindings
iam_binding=$(gcloud iam service-accounts get-iam-policy "$sa_email" \
    --project=admin-coaching2100 --format="json")
echo "$iam_binding" | grep -q 'roles/iam.workloadIdentityUser'
check_status "Workload Identity User role binding exists"

# 5. Permission Validation
echo "\n=== Validating Permissions ==="
gcloud iam service-accounts get-iam-policy "$sa_email" \
    --project=admin-coaching2100 --format="json" | grep -q "principalSet://iam.googleapis.com/projects/admin-coaching2100/locations/global/workloadIdentityPools/github-pool"
check_status "Pool to Service Account binding exists"

# Final Report
echo "\n=== Validation Complete ==="
if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}All validations passed successfully!${NC}"
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}Validation completed with $warnings warnings${NC}"
else
    echo -e "${RED}Validation failed with $errors errors and $warnings warnings${NC}"
    exit 1
fi