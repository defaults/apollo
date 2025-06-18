#!/bin/bash

# Apollo Blog Build Script

set -e

USER_CONFIG="user-config.yml"
BASE_CONFIG="_config.yml"
MERGED_CONFIG="_site-config.yml"

echo "🔧 Building Apollo Blog..."

# Check if user config exists
if [ ! -f "$USER_CONFIG" ]; then
    echo "❌ user-config.yml not found. Please run ./setup.sh first."
    exit 1
fi

# Merge configurations
echo "📋 Merging configurations..."

# Create a temporary merged config
cp "$BASE_CONFIG" "$MERGED_CONFIG"

# Add user configuration to the merged config
echo "" >> "$MERGED_CONFIG"
echo "# User Configuration (auto-merged)" >> "$MERGED_CONFIG"
cat "$USER_CONFIG" >> "$MERGED_CONFIG"

# Build with Jekyll
echo "🏗️  Building with Jekyll..."
bundle exec jekyll build --config "$MERGED_CONFIG"

echo "✅ Build complete!" 