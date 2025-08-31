#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a personal site repo that vendors this theme via git subtree.
# Run from YOUR SITE REPO root:
#   bash theme/scripts/setup-site.sh

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(pwd)"

echo "Theme directory: $THEME_DIR"
echo "Site root:       $ROOT_DIR"

has_cmd() { command -v "$1" >/dev/null 2>&1; }

copy_dir() {
  local src="$1" dst="$2"
  [[ ! -d "$src" ]] && return 0
  mkdir -p "$dst"
  if has_cmd rsync; then
    rsync -a "$src"/ "$dst"/
  else
    cp -R "$src"/. "$dst"/
  fi
}

copy_file() {
  local src="$1" dst="$2"
  [[ ! -f "$src" ]] && return 0
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

# 1) Ensure basic structure
mkdir -p "$ROOT_DIR/content" "$ROOT_DIR/overrides" "$ROOT_DIR/.github/workflows"

# 2) Seed example content if content/ is empty and examples exist
if [[ -z "$(ls -A "$ROOT_DIR/content" 2>/dev/null || true)" ]] && [[ -d "$THEME_DIR/examples/content" ]]; then
  echo "Seeding content/ from theme examples..."
  copy_dir "$THEME_DIR/examples/content" "$ROOT_DIR/content"
fi

# 3) Create site-local config if missing (copy from theme template)
CFG_LOCAL="$ROOT_DIR/_config.local.yml"
if [[ ! -f "$CFG_LOCAL" ]]; then
  if [[ -f "$THEME_DIR/templates/site/_config.local.yml" ]]; then
    cp "$THEME_DIR/templates/site/_config.local.yml" "$CFG_LOCAL"
  else
    echo "Warning: theme templates missing; writing default _config.local.yml"
    cat > "$CFG_LOCAL" <<'YAML'
# Site identity and per-site settings
title: "Your Site Title"
description: "Short description of your site"

# Domain settings (optional)
url: ""        # e.g., https://example.com
baseurl: ""    # e.g., /blog

# Author and social
author:
  name: "Your Name"
  twitter: "your_twitter"

twitter:
  username: "your_twitter"

# Analytics (optional)
google_analytics: ""  # e.g., G-XXXXXXXXXX

# Optional: let the bundled loader import pages from content/
content:
  loader_enabled: false
YAML
  fi
  echo "Created _config.local.yml"
fi

# 4) Create site deploy workflow if missing (copy from theme template)
SITE_WF="$ROOT_DIR/.github/workflows/deploy.yml"
if [[ ! -f "$SITE_WF" ]]; then
  if [[ -f "$THEME_DIR/templates/site/workflows/deploy.yml" ]]; then
    mkdir -p "$ROOT_DIR/.github/workflows"
    cp "$THEME_DIR/templates/site/workflows/deploy.yml" "$SITE_WF"
  else
    echo "Warning: theme templates missing; writing default workflow"
    cat > "$SITE_WF" <<'YML'
name: Build and Deploy Site

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true

      - name: Compose build
        run: bash theme/scripts/compose.sh build

      - name: Build Jekyll
        run: |
          BUNDLE_GEMFILE=theme/Gemfile bundle exec jekyll build \
            --source build/src \
            --config build/src/_config.yml,build/src/_config.local.yml \
            --destination _site

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SERVICE_ACCOUNT_KEY }}

      - name: Setup gcloud CLI
        uses: google-github-actions/setup-gcloud@v2

      - name: Deploy to App Engine
        run: gcloud app deploy --quiet --promote
YML
  fi
  echo "Created .github/workflows/deploy.yml"
fi

# 5) Create app.yaml if missing (for App Engine static hosting)
if [[ ! -f "$ROOT_DIR/app.yaml" ]]; then
  copy_file "$THEME_DIR/app.yaml" "$ROOT_DIR/app.yaml"
  echo "Created app.yaml"
fi

cat <<'NEXT'

Done. Next steps:
- Add content under content/ and optional HTML overrides under overrides/
- Edit _config.local.yml for site identity, analytics, and social handles
- Try local preview:
    bash theme/scripts/compose.sh serve
  (If Ruby 3: run `bundle add webrick` in your site repo if serve errors)
- Commit and push to trigger deployment

- In GitHub → Settings → Secrets and variables → Actions, add:
    GCP_SERVICE_ACCOUNT_KEY (JSON from your GCP service account)

Update theme later:
  git fetch apollo-tpl
  git subtree pull --prefix=theme apollo-tpl master --squash

NEXT
