#!/bin/bash

# Apollo Content Sync Script
# Helps manage external content repositories and trigger deployments

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

# Check if we're in the right directory
check_directory() {
    if [ ! -f "_config.yml" ] || [ ! -f "app.yaml" ]; then
        print_error "This script must be run from the Apollo blog root directory."
        exit 1
    fi
}

# Get content source from config
get_content_source() {
    grep -o 'source: "[^"]*"' _config.yml | cut -d'"' -f2
}

# Get content repository URL from config
get_content_repo() {
    grep -o 'repository: "[^"]*"' _config.yml | cut -d'"' -f2
}

# Show usage information
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  sync          Sync content from external repository"
    echo "  status        Show content repository status"
    echo "  switch        Switch between local and external content"
    echo "  deploy        Trigger manual deployment"
    echo "  update        Update Apollo theme from upstream"
    echo "  help          Show this help message"
    echo ""
    echo "Options:"
    echo "  --force       Force operation even if no changes detected"
    echo "  --test        Test build locally before deploying"
    echo ""
    echo "Examples:"
    echo "  $0 sync                    # Sync external content"
    echo "  $0 status                  # Check content status"
    echo "  $0 switch external         # Switch to external content"
    echo "  $0 deploy --test           # Test build then deploy"
}

# Show content repository status
show_status() {
    local content_source=$(get_content_source)
    local content_repo=$(get_content_repo)
    
    echo "📊 Apollo Content Status"
    echo "════════════════════════════════"
    echo "Content source: $content_source"
    
    if [ "$content_source" = "external" ]; then
        echo "Content repository: $content_repo"
        
        if [ -d "content-external" ]; then
            echo ""
            echo "📁 External content directory:"
            cd content-external
            echo "  Current branch: $(git branch --show-current)"
            echo "  Last commit: $(git log -1 --pretty=format:'%h - %s (%cr)')"
            
            # Check for updates
            git fetch origin > /dev/null 2>&1
            LOCAL_COMMIT=$(git rev-parse HEAD)
            REMOTE_COMMIT=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)
            
            if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
                print_warning "Content updates available! Run 'sync' to update."
            else
                print_success "Content is up to date."
            fi
            cd ..
        else
            print_warning "External content directory not found. Run setup again."
        fi
        
        if [ -d "content" ]; then
            echo ""
            echo "📂 Synced content:"
            echo "  Files: $(find content -name "*.md" | wc -l) markdown files"
            echo "  Last sync: $(stat -c %y content 2>/dev/null || stat -f %Sm content 2>/dev/null || echo 'Unknown')"
        fi
    else
        echo ""
        echo "📁 Local content directory:"
        if [ -d "content" ]; then
            echo "  Files: $(find content -name "*.md" | wc -l) markdown files"
            echo "  Essays: $(find content/_essays -name "*.md" 2>/dev/null | wc -l || echo 0)"
        else
            print_warning "Local content directory not found!"
        fi
    fi
    
    echo ""
    echo "🏗️ Last build: $(stat -c %y _site 2>/dev/null || stat -f %Sm _site 2>/dev/null || echo 'Never built')"
}

# Sync external content
sync_content() {
    local force_sync=false
    if [ "$1" = "--force" ]; then
        force_sync=true
    fi
    
    local content_source=$(get_content_source)
    local content_repo=$(get_content_repo)
    
    if [ "$content_source" != "external" ]; then
        print_error "Content source is set to 'local'. Use 'switch external' first."
        exit 1
    fi
    
    if [ -z "$content_repo" ]; then
        print_error "External content repository not configured in _config.yml"
        exit 1
    fi
    
    print_step "Syncing external content..."
    
    # Update submodule
    if [ -d "content-external" ]; then
        echo "Updating existing content repository..."
        cd content-external
        
        # Check for local changes
        if ! git diff --quiet && [ "$force_sync" = false ]; then
            print_warning "Local changes detected in content repository."
            read -p "Overwrite local changes? (y/n): " overwrite
            if [[ ! $overwrite =~ ^[Yy]$ ]]; then
                echo "Sync cancelled."
                exit 1
            fi
            git reset --hard HEAD
        fi
        
        git pull origin main || git pull origin master
        cd ..
    else
        echo "Cloning content repository..."
        git submodule add "$content_repo" content-external
        cd content-external
        git checkout main || git checkout master
        cd ..
    fi
    
    # Copy content
    print_step "Copying content files..."
    rm -rf content
    mkdir -p content
    cp -r content-external/* content/
    
    # Verify required structure
    if [ ! -f "content/home/index.md" ]; then
        print_warning "Required home/index.md not found in content repository!"
    fi
    
    print_success "Content synced successfully!"
    echo "📊 Synced files:"
    find content -name "*.md" | wc -l | xargs echo "  Markdown files:"
    
    # Test build
    print_step "Testing build with new content..."
    if bundle exec jekyll build --quiet; then
        print_success "Build test passed!"
    else
        print_error "Build test failed. Check your content format."
        exit 1
    fi
}

# Switch content strategy
switch_content() {
    local target_mode="$1"
    
    if [ -z "$target_mode" ]; then
        echo "Current content source: $(get_content_source)"
        echo ""
        echo "Available modes:"
        echo "  local     - Use content/ directory in this repository"
        echo "  external  - Use external Git repository"
        echo ""
        read -p "Switch to (local/external): " target_mode
    fi
    
    case $target_mode in
        local)
            print_step "Switching to local content..."
            
            # Update config
            sed -i.bak 's/source: ".*"/source: "local"/' _config.yml
            sed -i.bak 's/repository: ".*"/repository: ""/' _config.yml
            
            # Ensure content directory exists
            if [ ! -d "content" ]; then
                mkdir -p content/home content/_essays
                print_warning "Created empty content directory. Add your content files."
            fi
            
            print_success "Switched to local content mode!"
            ;;
            
        external)
            print_step "Switching to external content..."
            
            read -p "Enter external content repository URL: " repo_url
            if [ -z "$repo_url" ]; then
                print_error "Repository URL is required."
                exit 1
            fi
            
            # Update config
            sed -i.bak 's/source: ".*"/source: "external"/' _config.yml
            sed -i.bak "s|repository: \".*\"|repository: \"$repo_url\"|" _config.yml
            
            # Set up submodule
            if [ ! -d "content-external" ]; then
                git submodule add "$repo_url" content-external
            fi
            
            # Sync content
            sync_content
            
            print_success "Switched to external content mode!"
            ;;
            
        *)
            print_error "Invalid mode. Use 'local' or 'external'."
            exit 1
            ;;
    esac
}

# Trigger deployment
trigger_deploy() {
    local test_build=false
    if [ "$1" = "--test" ]; then
        test_build=true
    fi
    
    if [ "$test_build" = true ]; then
        print_step "Testing build before deployment..."
        if ! bundle exec jekyll build --verbose; then
            print_error "Build failed. Fix errors before deploying."
            exit 1
        fi
        print_success "Build test passed!"
    fi
    
    print_step "Triggering deployment..."
    
    # Check if there are uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_warning "You have uncommitted changes."
        git status --porcelain
        echo ""
        read -p "Commit and deploy these changes? (y/n): " commit_changes
        
        if [[ $commit_changes =~ ^[Yy]$ ]]; then
            read -p "Commit message: " commit_msg
            if [ -z "$commit_msg" ]; then
                commit_msg="Update content and deploy"
            fi
            
            git add .
            git commit -m "$commit_msg"
        else
            echo "Deployment cancelled."
            exit 1
        fi
    fi
    
    # Push to trigger deployment
    git push origin master
    
    print_success "Deployment triggered!"
    echo ""
    echo "🔗 Monitor deployment:"
    echo "  GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
    echo "  App Engine: https://console.cloud.google.com/appengine"
}

# Update Apollo theme
update_theme() {
    print_step "Updating Apollo theme..."
    
    # Check if upstream is configured
    if ! git remote | grep -q upstream; then
        print_warning "Upstream remote not configured. Adding..."
        read -p "Enter upstream repository URL (original Apollo repo): " upstream_url
        if [ -z "$upstream_url" ]; then
            print_error "Upstream URL is required."
            exit 1
        fi
        git remote add upstream "$upstream_url"
    fi
    
    # Backup current content
    local content_source=$(get_content_source)
    if [ "$content_source" = "local" ] && [ -d "content" ]; then
        print_step "Backing up local content..."
        cp -r content content-backup-$(date +%Y%m%d%H%M%S)
    fi
    
    # Fetch and merge updates
    git fetch upstream
    
    print_warning "This will merge theme updates. Conflicts may need manual resolution."
    read -p "Continue? (y/n): " continue_update
    
    if [[ $continue_update =~ ^[Yy]$ ]]; then
        if git merge upstream/master; then
            print_success "Theme updated successfully!"
            
            # Restore content if needed
            if [ "$content_source" = "external" ]; then
                sync_content
            fi
            
            # Test build
            print_step "Testing updated theme..."
            if bundle exec jekyll build --quiet; then
                print_success "Theme update complete!"
            else
                print_warning "Build test failed. Check for compatibility issues."
            fi
        else
            print_error "Merge conflicts detected. Resolve manually and commit."
        fi
    else
        echo "Update cancelled."
    fi
}

# Main script logic
main() {
    check_directory
    
    local command="$1"
    local option="$2"
    
    case $command in
        sync)
            sync_content "$option"
            ;;
        status)
            show_status
            ;;
        switch)
            switch_content "$option"
            ;;
        deploy)
            trigger_deploy "$option"
            ;;
        update)
            update_theme
            ;;
        help|--help|-h)
            show_usage
            ;;
        "")
            show_status
            echo ""
            echo "Run '$0 help' for available commands."
            ;;
        *)
            print_error "Unknown command: $command"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 