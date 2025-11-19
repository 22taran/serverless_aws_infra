#!/bin/bash

# Script to build and deploy frontend to S3

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$SCRIPT_DIR/../app/frontend"

# Get S3 bucket name from Terraform output (if available)
if [ -z "$S3_BUCKET" ]; then
  echo "❌ Error: S3_BUCKET environment variable not set"
  echo "Usage: S3_BUCKET=your-bucket-name ./scripts/deploy-frontend.sh"
  exit 1
fi

echo "🏗️  Building frontend..."

cd "$FRONTEND_DIR"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

# Build the application
npm run build

echo "📤 Deploying to S3 bucket: $S3_BUCKET"

# Sync to S3
aws s3 sync dist/ "s3://$S3_BUCKET/" --delete

echo "✅ Frontend deployed successfully!"

# Invalidate CloudFront if distribution ID is provided
if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
  echo "🔄 Invalidating CloudFront cache..."
  aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" \
    --paths "/*"
  echo "✅ CloudFront cache invalidated!"
fi

