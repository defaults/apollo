# Apollo

Jekyll theme for personal websites.

## Prerequisites

This project uses [asdf](https://asdf-vm.com/) for version management. Install asdf first, then:

```bash
# Install Ruby plugin and version
asdf plugin add ruby
asdf install

# Verify Ruby version
ruby --version  # Should show 3.3.6
```

> **Note:** If `ruby --version` shows a different version, ensure asdf is properly configured in your shell. Add this to your `~/.zshrc` or `~/.bashrc`:
> ```bash
> . "$HOME/.asdf/asdf.sh"
> ```

## Develop the Theme

```bash
# Install dependencies
bundle install

# Serve locally with live reload
bundle exec jekyll serve --livereload
```

Or use the compose script:
```bash
bash scripts/compose.sh demo    # Build and serve examples
bash scripts/compose.sh serve   # Build and serve your content
```

Edit files in `_layouts/`, `_includes/`, `_plugins/`, `assets/`, and `examples/content/`.

## Use as Your Site

In your site repo:

```bash
# Add Apollo as subtree (once)
git remote add apollo git@github.com:defaults/apollo.git
git fetch apollo
git subtree add --prefix=apollo apollo master --squash

# Setup site structure
bash apollo/setup.sh

# Install dependencies
BUNDLE_GEMFILE=apollo/Gemfile bundle install

# Run locally
bash scripts/compose.sh serve
```

Edit your site:
- `_config.local.yml` — title, description, author
- `content/` — your markdown files
- `overrides/` — optional theme overrides

Update theme later:

```bash
git fetch apollo
git subtree pull --prefix=apollo apollo master --squash
```
