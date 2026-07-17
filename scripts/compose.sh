#!/usr/bin/env bash
set -euo pipefail

# Build and serve Jekyll sites using the Apollo theme.
#
# Template repo:
#   bash scripts/compose.sh serve
#
# Consumer repo (after running apollo/setup.sh):
#   bash scripts/compose.sh serve

ROOT_DIR="$(pwd)"

# Detect theme directory
if [[ -d "apollo" ]]; then
  THEME_DIR="apollo"
elif [[ -d "theme" ]]; then
  THEME_DIR="theme"
else
  THEME_DIR="."
fi

BUILD_DIR="${ROOT_DIR}/build/src"
EXAMPLES_DIR="${THEME_DIR}/examples/content"

# Resolve Gemfile path
if [[ -f "$THEME_DIR/Gemfile" ]]; then
  GEMFILE_PATH="$THEME_DIR/Gemfile"
else
  GEMFILE_PATH="Gemfile"
fi

has_cmd() { command -v "$1" >/dev/null 2>&1; }

copy_dir() {
  local src="$1" dst="$2" mode="${3:-sync}"
  [[ ! -d "$src" ]] && return 0
  mkdir -p "$dst"
  if has_cmd rsync; then
    if [[ "$mode" == "overlay" ]]; then
      rsync -a "$src"/ "$dst"/
    else
      rsync -a --delete "$src"/ "$dst"/
    fi
  else
    if [[ "$mode" == "overlay" ]]; then
      cp -R "$src"/. "$dst"/
    else
      rm -rf "$dst" && mkdir -p "$dst"
      cp -R "$src"/. "$dst"/
    fi
  fi
}

copy_file() {
  local src="$1" dst="$2"
  [[ ! -f "$src" ]] && return 0
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

promote_pages() {
  local content_dir="$1" out_dir="$2"
  [[ ! -d "$content_dir" ]] && return 0
  shopt -s nullglob
  for f in "$content_dir"/*.md; do cp "$f" "$out_dir/$(basename "$f")"; done
  [[ -f "$content_dir/home/index.md" ]] && cp "$content_dir/home/index.md" "$out_dir/index.md"
  shopt -u nullglob
}

cleanup_promoted() {
  local content_dir="$1"
  [[ ! -d "$content_dir" ]] && return 0
  rm -f "$content_dir"/*.md 2>/dev/null || true
  rm -f "$content_dir/home/index.md" 2>/dev/null || true
}

do_build() {
  local use_examples="${1:-0}"
  local skip_generation="${2:-0}"  # Skip OG/favicon generation on watch rebuilds
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR"

  # Config
  if [[ "$use_examples" == "1" ]]; then
    copy_file "$THEME_DIR/_config.yml" "$BUILD_DIR/_config.yml"
  else
    copy_file "$THEME_DIR/_config.yml" "$BUILD_DIR/_config.yml"
    [[ -f "${ROOT_DIR}/_config.local.yml" ]] && copy_file "${ROOT_DIR}/_config.local.yml" "$BUILD_DIR/_config.local.yml"
  fi

  # Theme assets
  copy_dir "$THEME_DIR/_layouts" "$BUILD_DIR/_layouts"
  copy_dir "$THEME_DIR/_includes" "$BUILD_DIR/_includes"
  copy_dir "$THEME_DIR/_plugins" "$BUILD_DIR/_plugins"
  copy_dir "$THEME_DIR/_sass" "$BUILD_DIR/_sass"
  copy_dir "$THEME_DIR/assets" "$BUILD_DIR/assets"
  for f in robots.txt humans.txt favicon.ico apple-touch-icon.png feed.xslt.xml; do
    copy_file "$THEME_DIR/$f" "$BUILD_DIR/$f"
  done
  copy_file "$THEME_DIR/feed.xml" "$BUILD_DIR/feed.xml"

  # Content
  local content_src
  if [[ "$use_examples" == "1" ]]; then
    content_src="$EXAMPLES_DIR"
  else
    content_src="${ROOT_DIR}/content"
  fi
  copy_dir "$content_src" "$BUILD_DIR/content"
  promote_pages "$content_src" "$BUILD_DIR"
  cleanup_promoted "$BUILD_DIR/content"

  # Overrides
  if [[ "$use_examples" == "0" ]] && [[ -d "${ROOT_DIR}/overrides" ]]; then
    cp -r "${ROOT_DIR}/overrides/"* "$BUILD_DIR/" 2>/dev/null || true
  fi

  # Generate OG images and favicon (only on initial build, not on watch rebuilds)
  if [[ "$skip_generation" == "0" ]]; then
    # Generate dynamic favicon with author name
    if [[ -f "$THEME_DIR/scripts/generate-favicon.rb" ]]; then
      local author_name="Apollo"
      # Try local config first
      if [[ -f "$BUILD_DIR/_config.local.yml" ]]; then
        local extracted=$(grep -A1 "^author:" "$BUILD_DIR/_config.local.yml" | grep "name:" | sed -E 's/.*name:[[:space:]]*"?([^"]+)"?.*/\1/' | head -1 | xargs)
        [[ -n "$extracted" ]] && author_name="$extracted"
      fi
      # Fallback to theme config
      if [[ "$author_name" == "Apollo" && -f "$BUILD_DIR/_config.yml" ]]; then
        local extracted=$(grep -A1 "^author:" "$BUILD_DIR/_config.yml" | grep "name:" | sed -E 's/.*name:[[:space:]]*"?([^"]+)"?.*/\1/' | head -1 | xargs)
        [[ -n "$extracted" ]] && author_name="$extracted"
      fi
      
      ruby "$THEME_DIR/scripts/generate-favicon.rb" "$author_name" 2>/dev/null || true
    fi
  fi

  echo "Built $BUILD_DIR/src"
}

do_serve() {
  local use_examples="${1:-0}"
  do_build "$use_examples"

  local cfgs="$BUILD_DIR/_config.yml"
  [[ -f "$BUILD_DIR/_config.local.yml" ]] && cfgs="$cfgs,$BUILD_DIR/_config.local.yml"

  echo "Starting Jekyll server..."
  export BUNDLE_GEMFILE="$GEMFILE_PATH"

  # Determine which directories to watch for source changes
  local watch_dirs=("$THEME_DIR/_layouts" "$THEME_DIR/_includes" "$THEME_DIR/_sass" "$THEME_DIR/assets" "$THEME_DIR/_plugins")
  if [[ "$use_examples" == "1" ]]; then
    watch_dirs+=("$EXAMPLES_DIR")
  else
    watch_dirs+=("${ROOT_DIR}/content" "${ROOT_DIR}/overrides")
  fi

  # Start Jekyll in background
  bundle exec jekyll serve \
    --source "$BUILD_DIR" \
    --config "$cfgs" \
    --livereload &
  local jekyll_pid=$!

  # If fswatch is available, watch source directories for changes
  if has_cmd fswatch; then
    echo ""
    echo "Watching source files for changes..."
    echo "  Edit files in: ${watch_dirs[*]}"
    echo "  Press Ctrl+C to stop."
    echo ""

    # Watch for changes and rebuild
    fswatch -o "${watch_dirs[@]}" 2>/dev/null | while read -r _; do
      echo ""
      echo "Source files changed, rebuilding..."
      do_build "$use_examples" 1  # Skip OG/favicon generation on watch rebuilds
      echo "Rebuild complete. Browser will refresh."
    done &
    local fswatch_pid=$!

    # Wait for Jekyll to exit, then cleanup
    trap "kill $jekyll_pid $fswatch_pid 2>/dev/null; exit 0" INT TERM
    wait $jekyll_pid
    kill $fswatch_pid 2>/dev/null || true
  else
    echo ""
    echo "Note: Install 'fswatch' for automatic source file watching."
    echo "  brew install fswatch"
    echo ""
    echo "Without fswatch, restart the server after editing source files."
    echo ""
    wait $jekyll_pid
  fi
}

# Determine if we're in the template repo or a consumer site
is_template_repo() {
  [[ "$THEME_DIR" == "." ]]
}

case "${1:-}" in
  serve)
    if is_template_repo; then
      do_serve 1  # use examples
    else
      do_serve 0  # use site content
    fi
    ;;
  build)
    if is_template_repo; then
      do_build 1
    else
      do_build 0
    fi
    echo "Built $BUILD_DIR"
    ;;
  clean)
    rm -rf "$BUILD_DIR"
    echo "Removed $BUILD_DIR"
    ;;
  *)
    cat <<EOF
Usage: bash scripts/compose.sh <command>

Commands:
  serve   Build and serve locally with live reload
  build   Build site (for CI or manual jekyll commands)
  clean   Remove build directory

Prerequisites:
  - Ruby 3.2+
  - Run 'bundle install' once before first use

Template repo uses examples/content; consumer repos use content/ + overrides/
EOF
    [[ -n "${1:-}" ]] && exit 1
    ;;
esac
