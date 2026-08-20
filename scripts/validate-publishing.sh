#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(pwd)"
BUILD_SRC="$ROOT_DIR/build/src"
BUILD_SITE="$ROOT_DIR/build/site"

if [[ -f "$THEME_DIR/Gemfile" ]]; then
  GEMFILE_PATH="$THEME_DIR/Gemfile"
else
  GEMFILE_PATH="$ROOT_DIR/Gemfile"
fi

bash "$THEME_DIR/scripts/compose.sh" build

CONFIGS="$BUILD_SRC/_config.yml"
if [[ -f "$BUILD_SRC/_config.local.yml" ]]; then
  CONFIGS="$CONFIGS,$BUILD_SRC/_config.local.yml"
fi

if ! command -v bundle >/dev/null 2>&1; then
  echo "Error: Bundler is required for publishing validation." >&2
  exit 1
fi

if grep -q 'jekyll-og-image' "$GEMFILE_PATH" && ! command -v vips >/dev/null 2>&1; then
  echo "Error: libvips is required by jekyll-og-image. Install it with: brew install vips" >&2
  exit 1
fi

BUNDLE_GEMFILE="$GEMFILE_PATH" bundle exec jekyll build \
  --source "$BUILD_SRC" \
  --config "$CONFIGS" \
  --destination "$BUILD_SITE"

ruby "$THEME_DIR/scripts/validate-publishing-output.rb" "$BUILD_SITE"
