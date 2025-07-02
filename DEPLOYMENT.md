# Deployment Guide

This document explains how to deploy the Apollo blog to Google Cloud App Engine with automatic GitHub Actions deployment.

## Prerequisites

1. **Google Cloud Account**: You need a Google Cloud account with billing enabled
2. **Google Cloud Project**: Create or use an existing GCP project
3. **GitHub Repository**: Your Apollo blog code should be in a GitHub repository
4. **Google Cloud CLI**: Install the gcloud CLI tool locally

## Setup Instructions

### 1. Install Google Cloud CLI

If you haven't already, install the Google Cloud CLI:

```bash
# macOS (using Homebrew)
brew install google-cloud-sdk

# Or download from: https://cloud.google.com/sdk/docs/install
```

### 2. Run the Setup Script

The setup script will configure everything for you:

```bash
./scripts/setup-gcp.sh
```

This script will:
- Enable required Google Cloud APIs
- Create an App Engine application
- Create a service account for GitHub Actions
- Grant necessary permissions
- Generate a service account key

### 3. Configure GitHub Secrets

After running the setup script, you need to add secrets to your GitHub repository:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add these repository secrets:

   - **Name**: `GCP_PROJECT_ID`
   - **Value**: Your Google Cloud project ID

   - **Name**: `GCP_SERVICE_ACCOUNT_KEY`
   - **Value**: The entire contents of the JSON key file (copy from the setup script output)

### 4. Deploy

Once the secrets are configured, deployment is automatic:

```bash
git add .
git commit -m "Setup Google Cloud deployment"
git push origin master
```

The GitHub Action will:
1. Build the Jekyll site
2. Deploy to Google App Engine
3. Your site will be available at `https://YOUR_PROJECT_ID.appspot.com`

## Manual Deployment

If you want to deploy manually (without GitHub Actions):

```bash
# Build the Jekyll site
bundle exec jekyll build

# Deploy to App Engine
gcloud app deploy
```

## Monitoring Deployments

- **GitHub Actions**: Check the Actions tab in your GitHub repository
- **Google Cloud Console**: Visit the App Engine section in the Google Cloud Console
- **Logs**: View deployment logs in the Cloud Console

## Custom Domain

To use a custom domain:

1. Go to the App Engine settings in Google Cloud Console
2. Navigate to "Custom domains"
3. Follow the instructions to verify and configure your domain

## Troubleshooting

### Common Issues

1. **Build fails**: Check the GitHub Actions logs for Ruby/Jekyll errors
2. **Deployment fails**: Verify your service account has the correct permissions
3. **Site not loading**: Check App Engine logs in the Google Cloud Console

### Useful Commands

```bash
# View App Engine logs
gcloud app logs tail -s default

# Check App Engine instances
gcloud app instances list

# View deployment history
gcloud app versions list
```

## Cost Considerations

- App Engine has a generous free tier
- Static sites typically use minimal resources
- Monitor usage in the Google Cloud Console billing section

## Security Notes

- Service account keys are sensitive - never commit them to git
- Use GitHub secrets to store credentials securely
- Rotate service account keys periodically

## File Structure

- `app.yaml`: App Engine configuration
- `.github/workflows/deploy.yml`: GitHub Actions workflow
- `.gcloudignore`: Files to exclude from deployment
- `scripts/setup-gcp.sh`: Setup automation script 