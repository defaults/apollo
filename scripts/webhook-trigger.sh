#!/bin/bash

# Apollo Webhook Trigger Script
# Add this to your content repository to trigger Apollo deployments

set -e

# Configuration - Update these variables
APOLLO_REPO_OWNER="your-username"        # Your GitHub username
APOLLO_REPO_NAME="apollo"                # Your Apollo repository name
GITHUB_TOKEN="${GITHUB_TOKEN}"           # GitHub Personal Access Token

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check configuration
check_config() {
    if [ "$APOLLO_REPO_OWNER" = "your-username" ]; then
        print_error "Please update APOLLO_REPO_OWNER in this script"
        exit 1
    fi
    
    if [ -z "$GITHUB_TOKEN" ]; then
        print_error "GITHUB_TOKEN environment variable not set"
        echo "Create a personal access token at: https://github.com/settings/tokens"
        echo "Required scopes: repo, workflow"
        exit 1
    fi
}

# Trigger deployment
trigger_deployment() {
    local event_type="content-updated"
    local api_url="https://api.github.com/repos/${APOLLO_REPO_OWNER}/${APOLLO_REPO_NAME}/dispatches"
    
    print_info "Triggering Apollo deployment..."
    print_info "Repository: ${APOLLO_REPO_OWNER}/${APOLLO_REPO_NAME}"
    
    # Get current commit info
    local commit_sha=$(git rev-parse HEAD)
    local commit_message=$(git log -1 --pretty=format:"%s")
    local author_name=$(git log -1 --pretty=format:"%an")
    
    # Create payload
    local payload=$(cat <<EOF
{
  "event_type": "$event_type",
  "client_payload": {
    "content_repo": "$(git config --get remote.origin.url)",
    "commit_sha": "$commit_sha",
    "commit_message": "$commit_message",
    "author": "$author_name",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF
)
    
    # Send webhook
    local response=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$api_url")
    
    # Check response
    if echo "$response" | grep -q "Not Found"; then
        print_error "Repository not found or token lacks permissions"
        echo "Make sure:"
        echo "1. Repository ${APOLLO_REPO_OWNER}/${APOLLO_REPO_NAME} exists"
        echo "2. GitHub token has 'repo' and 'workflow' scopes"
        echo "3. Token belongs to user with push access"
        exit 1
    elif echo "$response" | grep -q "message"; then
        print_error "GitHub API error:"
        echo "$response"
        exit 1
    else
        print_success "Deployment triggered successfully!"
        echo ""
        echo "📊 Content Update Details:"
        echo "  Commit: $commit_sha"
        echo "  Message: $commit_message"
        echo "  Author: $author_name"
        echo ""
        echo "🔗 Monitor deployment:"
        echo "  https://github.com/${APOLLO_REPO_OWNER}/${APOLLO_REPO_NAME}/actions"
    fi
}

# Show setup instructions
show_setup() {
    echo "🚀 Apollo Webhook Setup"
    echo "══════════════════════════════════════════"
    echo ""
    echo "To use this script in your content repository:"
    echo ""
    echo "1. Update configuration in this script:"
    echo "   - APOLLO_REPO_OWNER: Your GitHub username"
    echo "   - APOLLO_REPO_NAME: Your Apollo repository name"
    echo ""
    echo "2. Create GitHub Personal Access Token:"
    echo "   - Go to: https://github.com/settings/tokens"
    echo "   - Click 'Generate new token (classic)'"
    echo "   - Select scopes: 'repo', 'workflow'"
    echo "   - Copy the token"
    echo ""
    echo "3. Set environment variable:"
    echo "   export GITHUB_TOKEN='your_token_here'"
    echo ""
    echo "4. Add to your content repository's git hooks:"
    echo "   # Add to .git/hooks/post-commit:"
    echo "   #!/bin/bash"
    echo "   ./webhook-trigger.sh"
    echo ""
    echo "5. Or run manually after content changes:"
    echo "   ./webhook-trigger.sh"
    echo ""
    echo "6. Or add to GitHub Actions in your content repo:"
    echo "   - name: Trigger Apollo deployment"
    echo "     run: ./webhook-trigger.sh"
    echo "     env:"
    echo "       GITHUB_TOKEN: \${{ secrets.APOLLO_WEBHOOK_TOKEN }}"
}

# Main function
main() {
    if [ "$1" = "--setup" ] || [ "$1" = "setup" ]; then
        show_setup
        return
    fi
    
    check_config
    trigger_deployment
}

# Run main function
main "$@" 