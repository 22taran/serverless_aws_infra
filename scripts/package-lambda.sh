#!/bin/bash

# Script to package Lambda functions for deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../app/backend"

echo "📦 Packaging Lambda functions..."

cd "$BACKEND_DIR"

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install
fi

# Package each function
for func in getTasks createTask updateTask deleteTask; do
  echo "Packaging $func..."
  
  # Remove old zip if exists
  rm -f "$func.zip"
  
  # Create zip with function and node_modules
  zip -j "$func.zip" "$func.js"
  zip -r "$func.zip" node_modules/ -x "*.git*" "*.DS_Store*"
  
  echo "✅ $func packaged successfully"
done

echo "✅ All Lambda functions packaged!"

