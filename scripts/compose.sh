#!/usr/bin/env bash
set -euo pipefail

# Compose a buildable Jekyll source tree from a vendored theme
# Usage (from site repo root):
#   bash apollo/scripts/compose.sh init     # seed content from theme examples (if empty)
#   bash apollo/scripts/compose.sh build    # create build/src from theme + content + overrides
#   bash apollo/scripts/compose.sh serve    # build then serve with livereload
#   bash apollo/scripts/compose.sh clean    # remove build/src
#
# In the template repository itself, you can build the demo site:
#   bash scripts/compose.sh demo

ROOT_DIR="$(pwd)"

# If running in a consumer site, prefer ./apollo (new default), fallback to ./theme; otherwise in this repo it is .
if [[ -d "apollo" ]]; then
  THEME_DIR="apollo"
elif [[ -d "theme" ]]; then
  THEME_DIR="theme"
else
  THEME_DIR="."
fi

BUILD_DIR="${ROOT_DIR}/build/src"
EXAMPLES_CONTENT_DIR="${THEME_DIR}/examples/content"

has_cmd() { command -v "$1" >/dev/null 2>&1; }

copy_dir() {
  local src="$1" dst="$2"
  [[ ! -d "$src" ]] && return 0
  mkdir -p "$dst"
  if has_cmd rsync; then
    rsync -a --delete "$src"/ "$dst"/
  else
    # Fallback to cp -R (no delete)
    cp -R "$src"/. "$dst"/
  fi
}

copy_file() {
  local src="$1" dst="$2"
  [[ ! -f "$src" ]] && return 0
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

promote_root_content_pages() {
  # Promote common top-level content pages to Jekyll root
  local content_dir="$1" out_dir="$2"
  [[ ! -d "$content_dir" ]] && return 0

  # 1) Top-level markdown files under content/ (about.md, 404.md, essays.md, etc.)
  shopt -s nullglob
  for f in "$content_dir"/*.md; do
    local base
    base="$(basename "$f")"
    cp "$f" "$out_dir/$base"
  done

  # 2) Home page: content/home/index.md -> index.md
  if [[ -f "$content_dir/home/index.md" ]]; then
    cp "$content_dir/home/index.md" "$out_dir/index.md"
  fi
  shopt -u nullglob
}

# Remove duplicates that would conflict with promoted pages
cleanup_promoted_content_pages() {
  local content_dir="$1"
  [[ ! -d "$content_dir" ]] && return 0
  # Remove top-level markdown files we promoted (about.md, 404.md, essays.md, etc.)
  rm -f "$content_dir"/*.md 2>/dev/null || true
  # Remove home index to avoid duplicate index.html
  rm -f "$content_dir/home/index.md" 2>/dev/null || true
}

compose_build() {
  local use_examples="${1:-0}"
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR"

  # Base config and theme assets
  # Choose config: demo uses theme/_config.yml; site builds prefer repo _config.yml
  if [[ "$use_examples" == "1" ]]; then
    copy_file "$THEME_DIR/_config.yml" "$BUILD_DIR/_config.yml"
  else
    if [[ -f "${ROOT_DIR}/_config.yml" ]]; then
      copy_file "${ROOT_DIR}/_config.yml" "$BUILD_DIR/_config.yml"
    elif [[ -f "$THEME_DIR/templates/site/_config.yml.example" ]]; then
      copy_file "$THEME_DIR/templates/site/_config.yml.example" "$BUILD_DIR/_config.yml"
    else
      copy_file "$THEME_DIR/_config.yml" "$BUILD_DIR/_config.yml"
    fi
  fi
  copy_dir "$THEME_DIR/_layouts" "$BUILD_DIR/_layouts"
  copy_dir "$THEME_DIR/_includes" "$BUILD_DIR/_includes"
  copy_dir "$THEME_DIR/_plugins" "$BUILD_DIR/_plugins"
  copy_dir "$THEME_DIR/assets" "$BUILD_DIR/assets"
  # Common root-level static files from theme
  for f in robots.txt favicon.ico apple-touch-icon.png; do
    copy_file "$THEME_DIR/$f" "$BUILD_DIR/$f"
  done

  # Content: examples for demo, otherwise site content/
  if [[ "$use_examples" == "1" ]]; then
    copy_dir "$EXAMPLES_CONTENT_DIR" "$BUILD_DIR/content"
    promote_root_content_pages "$EXAMPLES_CONTENT_DIR" "$BUILD_DIR"
    cleanup_promoted_content_pages "$BUILD_DIR/content"
  else
    copy_dir "${ROOT_DIR}/content" "$BUILD_DIR/content"
    promote_root_content_pages "${ROOT_DIR}/content" "$BUILD_DIR"
    cleanup_promoted_content_pages "$BUILD_DIR/content"
  fi

  # Overrides from site repo overlay the theme
  copy_dir "${ROOT_DIR}/overrides" "$BUILD_DIR"

  # Single config model: no secondary config file
}

compose_serve() {
  compose_build "${1:-0}"
  local cfgs=("$BUILD_DIR/_config.yml")
  # Serve using the theme Gemfile when vendored; otherwise local Gemfile
  local gemfile_path
  if [[ -f "$THEME_DIR/Gemfile" ]]; then gemfile_path="$THEME_DIR/Gemfile"; else gemfile_path="Gemfile"; fi
  BUNDLE_GEMFILE="$gemfile_path" bundle exec jekyll serve \
    --source "$BUILD_DIR" \
    --config "${cfgs[*]}" \
    --livereload
}

usage() {
  cat <<EOF
Compose a Jekyll build from theme + site content/overrides

Commands:
  init     Seed content/ from theme examples (if empty)
  build    Compose build/src for CI/local builds
  serve    Compose and serve locally (uses theme Gemfile)
  demo     Compose using theme examples (for template repo demo)
  clean    Remove build/src

Environment:
  THEME_DIR   Path to theme directory (default: ./apollo if present, else ./theme, else .)
EOF
}

cmd="${1:-}"; shift || true
case "$cmd" in
  init)
    if [[ -d "$ROOT_DIR/content" ]] && [[ -n "$(ls -A "$ROOT_DIR/content" 2>/dev/null || true)" ]]; then
      echo "content/ already exists and is not empty; skipping init."
      exit 0
    fi
    if [[ -d "$EXAMPLES_CONTENT_DIR" ]]; then
      mkdir -p "$ROOT_DIR/content"
      copy_dir "$EXAMPLES_CONTENT_DIR" "$ROOT_DIR/content"
      echo "Seeded content/ from theme examples."
    else
      echo "No examples found at $EXAMPLES_CONTENT_DIR"
    fi
    ;;
  build)
    compose_build 0
    echo "Built $BUILD_DIR"
    ;;
  serve)
    compose_serve 0
    ;;
  demo)
    compose_build 1
    echo "Built demo at $BUILD_DIR"
    ;;
  clean)
    rm -rf "$BUILD_DIR"
    echo "Removed $BUILD_DIR"
    ;;
  *)
    usage
    [[ -n "$cmd" ]] && exit 1 || exit 0
    ;;
esac
