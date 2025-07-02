#!/bin/bash

# Setup script for Google Cloud App Engine deployment
# Run this script to configure your GCP project and create necessary service account

set -e

echo "🚀 Setting up Google Cloud App Engine deployment for Apollo blog"
echo "============================================================"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud CLI is not installed."
    echo "Please install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Prompt for project ID
read -p "Enter your Google Cloud Project ID: " PROJECT_ID
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Project ID cannot be empty"
    exit 1
fi

echo "📝 Setting up project: $PROJECT_ID"

# Set the project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable appengine.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Create App Engine app (if it doesn't exist)
echo "🏗️  Creating App Engine application..."
if ! gcloud app describe &> /dev/null; then
    echo "Choose a region for your App Engine app:"
    echo "1) us-central (Iowa)"
    echo "2) us-east1 (South Carolina)"
    echo "3) us-west2 (Los Angeles)"
    echo "4) europe-west1 (Belgium)"
    echo "5) asia-northeast1 (Tokyo)"
    read -p "Enter choice [1-5]: " REGION_CHOICE
    
    case $REGION_CHOICE in
        1) REGION="us-central" ;;
        2) REGION="us-east1" ;;
        3) REGION="us-west2" ;;
        4) REGION="europe-west1" ;;
        5) REGION="asia-northeast1" ;;
        *) REGION="us-central" ;;
    esac
    
    gcloud app create --region=$REGION
else
    echo "✅ App Engine application already exists"
fi

# Create service account for GitHub Actions
SERVICE_ACCOUNT_NAME="github-actions-deploy"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "👤 Creating service account for GitHub Actions..."
if ! gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL &> /dev/null; then
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --description="Service account for GitHub Actions deployment" \
        --display-name="GitHub Actions Deploy"
else
    echo "✅ Service account already exists"
fi

# Grant necessary permissions
echo "🔐 Granting permissions to service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/appengine.deployer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/appengine.serviceAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/cloudbuild.builds.editor"

# Create and download service account key
echo "🔑 Creating service account key..."
KEY_FILE="apollo-deploy-key.json"
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

echo ""
echo "✅ Setup complete!"
echo "============================================================"
echo ""
echo "Next steps:"
echo "1. Go to your GitHub repository settings"
echo "2. Navigate to Settings > Secrets and variables > Actions"
echo "3. Add these repository secrets:"
echo ""
echo "   Name: GCP_PROJECT_ID"
echo "   Value: $PROJECT_ID"
echo ""
echo "   Name: GCP_SERVICE_ACCOUNT_KEY"
echo "   Value: (copy the entire contents of $KEY_FILE)"
echo ""
echo "4. Copy the contents of $KEY_FILE:"
echo ""
cat $KEY_FILE
echo ""
echo "5. Delete the key file after copying: rm $KEY_FILE"
echo ""
echo "🚀 After setting up the secrets, push to master branch to trigger deployment!"
echo "   Your site will be available at: https://$PROJECT_ID.appspot.com" 