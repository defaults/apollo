#!/bin/bash

set -e

echo "🚀 Apollo Blog Setup"
echo "=================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration file paths
USER_CONFIG="user-config.yml"
BASE_CONFIG="_config.yml"
CONTENT_DIR="content"

# Check if user-config.yml exists
if [ -f "$USER_CONFIG" ]; then
    echo -e "${YELLOW}Found existing configuration. Would you like to update it? (y/n)${NC}"
    read -r update_config
    if [ "$update_config" != "y" ]; then
        echo -e "${GREEN}Setup cancelled. Using existing configuration.${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}Let's configure your blog!${NC}"
echo ""

# Collect user information
echo "📝 Basic Information"
echo "==================="

read -p "Enter your name: " user_name
read -p "Enter your domain (e.g., yourdomain.com) or leave empty: " user_domain
read -p "Enter a brief description about yourself: " user_description

echo ""
echo "📂 Content Source"
echo "================"
echo "Choose how you want to manage your content:"
echo "1) Local folder (content/ directory in this project)"
echo "2) External Git repository"
read -p "Enter your choice (1 or 2): " content_choice

content_source="local"
content_repo=""
if [ "$content_choice" = "2" ]; then
    content_source="external"
    read -p "Enter the Git repository URL for your content: " content_repo
fi

echo ""
echo "🎯 Optional Features"
echo "==================="

read -p "Do you want Google Scholar link? (y/n): " google_scholar
google_scholar_id=""
if [ "$google_scholar" = "y" ]; then
    read -p "Enter your Google Scholar user ID: " google_scholar_id
fi

read -p "Do you want email subscription option? (y/n): " email_subscription
subscription_service=""
if [ "$email_subscription" = "y" ]; then
    echo "Choose subscription service:"
    echo "1) Mailchimp"
    echo "2) ConvertKit"
    echo "3) Custom"
    read -p "Enter your choice (1-3): " sub_choice
    case $sub_choice in
        1) subscription_service="mailchimp";;
        2) subscription_service="convertkit";;
        3) subscription_service="custom";;
    esac
    read -p "Enter your subscription form URL or ID: " subscription_url
fi

read -p "Do you want social media links? (y/n): " social_links
twitter_handle=""
linkedin_profile=""
github_username=""
if [ "$social_links" = "y" ]; then
    read -p "Twitter handle (without @): " twitter_handle
    read -p "LinkedIn profile URL: " linkedin_profile
    read -p "GitHub username: " github_username
fi

# Create user configuration
echo ""
echo -e "${YELLOW}Creating configuration...${NC}"

cat > "$USER_CONFIG" << EOF
# User Configuration for Apollo Blog
# This file contains your personal blog settings
# It's safe to modify this file - it won't be overwritten by updates

# Basic Information
user:
  name: "$user_name"
  domain: "$user_domain"
  description: "$user_description"

# Content Management
content:
  source: "$content_source"
  repository: "$content_repo"

# Features
features:
  google_scholar:
    enabled: $([ "$google_scholar" = "y" ] && echo "true" || echo "false")
    user_id: "$google_scholar_id"
  
  subscription:
    enabled: $([ "$email_subscription" = "y" ] && echo "true" || echo "false")
    service: "$subscription_service"
    url: "$subscription_url"
  
  social:
    enabled: $([ "$social_links" = "y" ] && echo "true" || echo "false")
    twitter: "$twitter_handle"
    linkedin: "$linkedin_profile"
    github: "$github_username"

# Build settings (you can modify these)
build:
  auto_rebuild: true
  include_drafts: false
EOF

# Initialize content directory if local source is chosen
if [ "$content_choice" = "1" ]; then
    echo -e "${YELLOW}Setting up local content directory...${NC}"
    
    if [ ! -d "$CONTENT_DIR" ]; then
        mkdir -p "$CONTENT_DIR"/{posts,pages,assets/images}
        
        # Copy existing content as examples
        if [ -d "_posts" ]; then
            cp -r _posts/* "$CONTENT_DIR/posts/" 2>/dev/null || true
        fi
        if [ -d "_pages" ]; then
            cp -r _pages/* "$CONTENT_DIR/pages/" 2>/dev/null || true
        fi
        if [ -d "assets/images" ]; then
            cp -r assets/images/* "$CONTENT_DIR/assets/images/" 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✓ Content directory initialized with example content${NC}"
    else
        echo -e "${GREEN}✓ Content directory already exists${NC}"
    fi
fi

# Create .gitignore entry for user-config.yml if it doesn't exist
if ! grep -q "user-config.yml" .gitignore 2>/dev/null; then
    echo "user-config.yml" >> .gitignore
    echo -e "${GREEN}✓ Added user-config.yml to .gitignore${NC}"
fi

# Create build script
echo -e "${YELLOW}Creating build script...${NC}"

cat > "build.sh" << 'EOF'
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
EOF

chmod +x build.sh

# Create sync script for external repos
if [ "$content_choice" = "2" ]; then
    echo -e "${YELLOW}Creating content sync script...${NC}"
    
    cat > "sync-content.sh" << EOF
#!/bin/bash

set -e

CONTENT_REPO="$content_repo"
CONTENT_DIR="content"

echo "🔄 Syncing content from external repository..."

if [ ! -d "\$CONTENT_DIR" ]; then
    echo "📥 Cloning content repository..."
    git clone "\$CONTENT_REPO" "\$CONTENT_DIR"
else
    echo "📥 Updating content repository..."
    cd "\$CONTENT_DIR"
    git pull origin main || git pull origin master
    cd ..
fi

echo "✅ Content sync complete!"

# Trigger rebuild
if [ -f "build.sh" ]; then
    echo "🏗️  Triggering rebuild..."
    ./build.sh
fi
EOF
    
    chmod +x sync-content.sh
    echo -e "${GREEN}✓ Content sync script created${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo ""
echo "Your blog has been configured with the following:"
echo "- User config saved to: $USER_CONFIG"
echo "- Build script created: build.sh"
[ "$content_choice" = "2" ] && echo "- Content sync script: sync-content.sh"
echo ""
echo "Next steps:"
echo "1. Run ./build.sh to build your site"
[ "$content_choice" = "2" ] && echo "2. Run ./sync-content.sh to sync external content"
echo "2. Start writing in the $([ "$content_choice" = "1" ] && echo "content/" || echo "external repo") directory"
echo ""
echo -e "${BLUE}Happy blogging! 🚀${NC}" 