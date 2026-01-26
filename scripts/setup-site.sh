#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a personal site repo that vendors this theme via git subtree.
# Run from YOUR SITE REPO root (after adding this repo under apollo/):
#   bash apollo/scripts/setup-site.sh
# or simply:
#   bash apollo/setup.sh

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(pwd)"

echo "Theme directory: $THEME_DIR"
echo "Site root:       $ROOT_DIR"

if [[ "$THEME_DIR" == "$ROOT_DIR" ]]; then
  cat <<'ERR' >&2
Error: setup script must be run from your site repository root with this theme vendored (expected apollo/ directory).
Run from the parent repo, e.g.:
  bash apollo/setup.sh
ERR
  exit 1
fi

REL_THEME_SUBPATH="${THEME_DIR#$ROOT_DIR/}"
if [[ "$REL_THEME_SUBPATH" == "$THEME_DIR" || -z "$REL_THEME_SUBPATH" ]]; then
  REL_THEME_SUBPATH="."
fi

if [[ "$REL_THEME_SUBPATH" == "." ]]; then
  cat <<'ERR' >&2
Error: could not determine theme subdirectory relative to site root.
Ensure the theme is vendored inside your site repo (e.g. site/apollo).
ERR
  exit 1
fi

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
mkdir -p "$ROOT_DIR/content" "$ROOT_DIR/overrides" "$ROOT_DIR/.github/workflows" "$ROOT_DIR/scripts"

# 2) Seed example content if content/ is empty and examples exist
if [[ -z "$(ls -A "$ROOT_DIR/content" 2>/dev/null || true)" ]] && [[ -d "$THEME_DIR/examples/content" ]]; then
  echo "Seeding content/ from theme examples..."
  copy_dir "$THEME_DIR/examples/content" "$ROOT_DIR/content"
fi

# 3) Ensure per-site config (_config.local.yml)
CFG_LOCAL="$ROOT_DIR/_config.local.yml"
if [[ ! -f "$CFG_LOCAL" ]]; then
  if [[ -f "$ROOT_DIR/_config.yml" && "$ROOT_DIR/_config.yml" != "$THEME_DIR/_config.yml" ]]; then
    mv "$ROOT_DIR/_config.yml" "$CFG_LOCAL"
    echo "Renamed _config.yml -> _config.local.yml"
  elif [[ -f "$THEME_DIR/templates/site/_config.yml.example" ]]; then
    cp "$THEME_DIR/templates/site/_config.yml.example" "$CFG_LOCAL"
    echo "Created _config.local.yml from template"
  else
    cat > "$CFG_LOCAL" <<'YAML'
title: "Your Site Title"
description: "Short description of your site"
url: ""
baseurl: ""
author:
  name: "Your Name"
plugins:
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-sitemap
collections_dir: content
collections:
  essays:
    output: true
    permalink: /essays/:slug/
defaults:
  - scope: { path: "", type: "essays" }
    values:
      layout: "essay"
      excerpt_separator: "<!--more-->"
  - scope: { path: "" }
    values:
      layout: "default"
YAML
    echo "Wrote minimal _config.local.yml"
  fi
fi

# 4) Create/Update compose wrapper
COMPOSE_WRAPPER="$ROOT_DIR/scripts/compose.sh"
# Always overwrite to ensure latest logic
cat > "$COMPOSE_WRAPPER" <<SH
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
THEME_COMPOSE="\$SCRIPT_DIR/../${REL_THEME_SUBPATH}/scripts/compose.sh"
if [[ ! -f "\$THEME_COMPOSE" ]]; then
  echo "Error: theme compose script not found at \$THEME_COMPOSE" >&2
  exit 1
fi
exec bash "\$THEME_COMPOSE" "\$@"
SH
chmod +x "$COMPOSE_WRAPPER"
echo "Updated scripts/compose.sh wrapper"

# 5) Create/Update site deploy workflow
SITE_WF="$ROOT_DIR/.github/workflows/deploy.yml"
# Always overwrite to ensure CI/CD fixes (like libvips) are applied
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
    env:
      BUNDLE_GEMFILE: apollo/Gemfile
    steps:
      - uses: actions/checkout@v4

      - name: Install libvips
        run: |
          sudo apt-get update
          sudo apt-get install -y libvips-dev

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true

      - name: Compose build
        run: bash scripts/compose.sh build

      - name: Build Jekyll
        run: |
          bundle exec jekyll build \
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
echo "Updated .github/workflows/deploy.yml"

# 6) Copy deployment/runtime scaffolding if missing
if [[ ! -f "$ROOT_DIR/app.yaml" ]]; then
  copy_file "$THEME_DIR/app.yaml" "$ROOT_DIR/app.yaml"
  echo "Created app.yaml"
fi

if [[ ! -f "$ROOT_DIR/main.py" ]]; then
  copy_file "$THEME_DIR/main.py" "$ROOT_DIR/main.py"
  echo "Created main.py"
fi

if [[ ! -f "$ROOT_DIR/.gcloudignore" ]]; then
  copy_file "$THEME_DIR/.gcloudignore" "$ROOT_DIR/.gcloudignore"
  echo "Created .gcloudignore"
fi

# Ensure apollo/ is ignored in .gcloudignore
if grep -q "apollo/" "$ROOT_DIR/.gcloudignore"; then
  :
else
  echo "" >> "$ROOT_DIR/.gcloudignore"
  echo "apollo/" >> "$ROOT_DIR/.gcloudignore"
  echo "Added apollo/ to .gcloudignore"
fi

if [[ ! -f "$ROOT_DIR/.gitignore" ]]; then
  copy_file "$THEME_DIR/.gitignore" "$ROOT_DIR/.gitignore"
  echo "Created .gitignore"
fi

# 7) Create .tool-versions for asdf (if using asdf)
if [[ ! -f "$ROOT_DIR/.tool-versions" ]]; then
  if [[ -f "$THEME_DIR/.tool-versions" ]]; then
    copy_file "$THEME_DIR/.tool-versions" "$ROOT_DIR/.tool-versions"
    echo "Created .tool-versions (asdf)"
  fi
fi

cat <<'NEXT'

Done. Next steps:
- Add content under content/ and optional HTML overrides under overrides/
- Edit _config.local.yml for site identity, analytics, and social handles
- Install Ruby deps for local preview (once):
    BUNDLE_GEMFILE=apollo/Gemfile bundle install
- Commit _config.local.yml so CI/CD picks it up
- Try local preview:
    bash scripts/compose.sh serve
  (If Ruby 3: run `bundle add webrick` in your site repo if serve errors)
- Commit and push to trigger deployment

- In GitHub → Settings → Secrets and variables → Actions, add:
    GCP_SERVICE_ACCOUNT_KEY (JSON from your GCP service account)

Update theme later:
  git fetch apollo
  git subtree pull --prefix=apollo apollo master --squash

NEXT
