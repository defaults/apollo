#!/bin/bash

# Apollo Blog Setup Script
# This script helps you configure Apollo for your personal use

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main setup function
main() {
    echo "🚀 Welcome to Apollo Blog Setup!"
    echo "This script will help you configure your personal blog."
    echo ""

    # Step 1: Check prerequisites
    print_step "Checking prerequisites..."
    check_prerequisites

    # Step 2: Install dependencies
    print_step "Installing dependencies..."
    install_dependencies

    # Step 3: Content strategy
    print_step "Setting up content strategy..."
    setup_content_strategy

    # Step 4: Site configuration
    print_step "Configuring your site..."
    configure_site

    # Step 5: Google Cloud setup
    print_step "Setting up Google Cloud deployment..."
    setup_google_cloud

    # Step 6: GitHub configuration
    print_step "Configuring GitHub Actions..."
    setup_github_actions

    # Step 7: Test build
    print_step "Testing local build..."
    test_build

    print_success "Setup complete! 🎉"
    show_next_steps
}

check_prerequisites() {
    local missing_deps=()

    # Check for Git
    if ! command_exists git; then
        missing_deps+=("git")
    fi

    # Check for Ruby
    if ! command_exists ruby; then
        missing_deps+=("ruby (version 3.0+)")
    fi

    # Check for Bundler
    if ! command_exists bundle; then
        missing_deps+=("bundler (gem install bundler)")
    fi

    # Check for Node.js
    if ! command_exists node; then
        missing_deps+=("node.js (version 16+)")
    fi

    # Check for Google Cloud CLI
    if ! command_exists gcloud; then
        print_warning "Google Cloud CLI not found. You'll need it for deployment."
        echo "Install from: https://cloud.google.com/sdk/docs/install"
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        echo "Please install missing dependencies and run this script again."
        exit 1
    fi

    print_success "All prerequisites found!"
}

install_dependencies() {
    # Install Ruby gems
    if [ -f "Gemfile" ]; then
        echo "Installing Ruby gems..."
        bundle config set --local path vendor/bundle
        bundle install
        print_success "Ruby gems installed!"
    fi

    # Install Node.js packages
    if [ -f "package.json" ]; then
        echo "Installing Node.js packages..."
        npm install
        print_success "Node.js packages installed!"
    fi
}

setup_content_strategy() {
    echo ""
    echo "Choose your content management strategy:"
    echo "1) Local content (keep content in this repository's content/ folder)"
    echo "2) External content repository (separate repository for content)"
    echo ""
    read -p "Enter your choice (1 or 2): " content_choice

    case $content_choice in
        1)
            setup_local_content
            ;;
        2)
            setup_external_content
            ;;
        *)
            print_error "Invalid choice. Please run setup again."
            exit 1
            ;;
    esac
}

setup_local_content() {
    print_success "Using local content strategy"
    
    # Update config
    sed -i.bak 's/source: ".*"/source: "local"/' _config.yml
    sed -i.bak 's/repository: ".*"/repository: ""/' _config.yml
    
    # Create content structure if it doesn't exist
    mkdir -p content/home content/blog content/essays
    
    # Check if content already exists
    if [ ! -f "content/home/index.md" ]; then
        echo "Creating default content structure..."
        create_default_content
    fi
    
    print_success "Local content setup complete!"
}

setup_external_content() {
    echo ""
    read -p "Enter your content repository URL (e.g., https://github.com/user/my-content.git): " content_repo
    
    if [ -z "$content_repo" ]; then
        print_error "Content repository URL is required."
        exit 1
    fi

    # Update config
    sed -i.bak "s|source: \".*\"|source: \"external\"|" _config.yml
    sed -i.bak "s|repository: \".*\"|repository: \"$content_repo\"|" _config.yml
    
    # Add as submodule
    echo "Adding content repository as submodule..."
    if [ ! -d "content-external" ]; then
        git submodule add "$content_repo" content-external
    fi
    
    print_success "External content repository linked!"
    print_warning "Make sure your content repository follows the required structure:"
    echo "  home/index.md (required)"
    echo "  blog/*.md (blog posts)"
    echo "  about.md (recommended)"
}

create_default_content() {
    # Create home page
    cat > content/home/index.md << 'EOF'
---
layout: home
title: Home
description: Personal website and portfolio
permalink: /
---

{{ site.user.name | default: site.title | default: "Your Name" }} is a [your role/profession], [brief description of your work or expertise].

Previously, [previous experience]. [Additional background information].

[Your educational background or other relevant details].

## Research

{% if site.features.google_scholar.enabled %}
[Google Scholar](https://scholar.google.com/citations?user={{ site.features.google_scholar.user_id }})
{% else %}
[Google Scholar](https://scholar.google.com/citations?user=YOUR_GOOGLE_SCHOLAR_ID)
{% endif %}

## Essays

{% assign essays = site.posts | limit: 5 %}
{% if essays.size > 0 %}
{% for post in essays %}
- [{{ post.title }}]({{ post.url | relative_url }})
{% endfor %}

[View all essays →](/essays/)
{% else %}
No essays published yet.
{% endif %}

## Contact

Subscribe for email alerts about new posts.
EOF

    # Create about page
    cat > content/about.md << 'EOF'
---
layout: default
title: About
description: About this website and its author
permalink: /about/
---

# About

This is a personal website built with Apollo, a flexible Jekyll-based blog system.

## About This Site

This website is powered by:
- Jekyll static site generator
- Apollo blog system
- Markdown content management
- Responsive design

## Contact

Feel free to reach out through the links on the homepage.
EOF

    # Create sample blog post
    local today=$(date +%Y-%m-%d)
    cat > "content/blog/${today}-welcome-to-apollo.md" << 'EOF'
---
layout: post
title: "Welcome to Apollo"
date: 2024-01-15
type: post
description: "Getting started with your new Apollo blog"
---

Welcome to your new Apollo blog! This is your first blog post.

## Getting Started

You can edit this post by modifying the file in `content/blog/`. To create new posts, simply add new markdown files with the naming convention `YYYY-MM-DD-title.md`.

## Features

Apollo includes:
- Clean, minimal design
- Dark/light mode toggle
- Automatic deployment
- Flexible content management

Happy blogging!
EOF

    print_success "Default content created!"
}

configure_site() {
    echo ""
    echo "Let's configure your site settings:"
    
    read -p "Your name: " user_name
    read -p "Your domain (optional, e.g., yourdomain.com): " user_domain
    read -p "Brief description about yourself: " user_description
    
    # Update config file
    sed -i.bak "s/name: \".*\"/name: \"$user_name\"/" _config.yml
    sed -i.bak "s/domain: \".*\"/domain: \"$user_domain\"/" _config.yml
    sed -i.bak "s/description: \".*\"/description: \"$user_description\"/" _config.yml
    
    # Google Scholar (optional)
    echo ""
    read -p "Enable Google Scholar integration? (y/n): " enable_scholar
    if [[ $enable_scholar =~ ^[Yy]$ ]]; then
        read -p "Your Google Scholar user ID: " scholar_id
        sed -i.bak "s/enabled: false/enabled: true/" _config.yml
        sed -i.bak "s/user_id: \"\"/user_id: \"$scholar_id\"/" _config.yml
    fi
    
    print_success "Site configuration updated!"
}

setup_google_cloud() {
    if ! command_exists gcloud; then
        print_warning "Google Cloud CLI not found. Skipping Google Cloud setup."
        print_warning "You can run './scripts/setup-gcp.sh' later to configure deployment."
        return
    fi
    
    echo ""
    read -p "Set up Google Cloud deployment now? (y/n): " setup_gcp
    if [[ $setup_gcp =~ ^[Yy]$ ]]; then
        if [ -f "scripts/setup-gcp.sh" ]; then
            echo "Running Google Cloud setup..."
            chmod +x scripts/setup-gcp.sh
            ./scripts/setup-gcp.sh
        else
            print_warning "setup-gcp.sh not found. You'll need to configure Google Cloud manually."
        fi
    else
        print_warning "Skipping Google Cloud setup. You can run './scripts/setup-gcp.sh' later."
    fi
}

setup_github_actions() {
    echo ""
    echo "GitHub Actions is already configured for automatic deployment."
    echo "Make sure to add these secrets to your GitHub repository:"
    echo "1. GCP_PROJECT_ID - Your Google Cloud project ID"
    echo "2. GCP_SERVICE_ACCOUNT_KEY - Your service account JSON key"
    echo ""
    echo "Go to: GitHub Repository → Settings → Secrets and variables → Actions"
    print_success "GitHub Actions configuration noted!"
}

test_build() {
    echo "Building site to test configuration..."
    
    if bundle exec jekyll build --verbose; then
        print_success "Site builds successfully!"
    else
        print_error "Build failed. Please check the error messages above."
        exit 1
    fi
}

show_next_steps() {
    echo ""
    echo "🎉 Your Apollo blog is ready!"
    echo ""
    echo "Next steps:"
    echo "1. Test locally: bundle exec jekyll serve --livereload"
    echo "2. Visit http://localhost:4000 to preview your site"
    echo "3. Edit your content in the content/ directory"
    echo "4. Commit and push to deploy: git add . && git commit -m 'Initial setup' && git push"
    echo ""
    echo "Your site will be deployed to: https://YOUR_GCP_PROJECT_ID.appspot.com"
    echo ""
    echo "For help, see README.md or visit: https://github.com/your-username/apollo"
}

# Run main function
main "$@" 