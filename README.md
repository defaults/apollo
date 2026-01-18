# Apollo

A minimal Jekyll theme for personal websites and blogs.

## Quick Start

### Prerequisites

1. **Ruby 3.2+** (via [asdf](https://asdf-vm.com/)):
   ```bash
   asdf plugin add ruby
   asdf install
   ```

2. **fswatch** (for live source watching):
   ```bash
   brew install fswatch
   ```

3. **Install dependencies**:
   ```bash
   bundle install
   ```

### Run Locally

```bash
bash scripts/compose.sh serve
```

This will:
- Build the site from `examples/content/`
- Start a server at http://localhost:4000
- Watch source files (`_sass/`, `_layouts/`, etc.) for changes
- Auto-rebuild and refresh browser on save

---

## Use Apollo for Your Site

### 1. Add as subtree

```bash
# In your site repo
git remote add apollo git@github.com:defaults/apollo.git
git fetch apollo
git subtree add --prefix=apollo apollo master --squash
```

### 2. Set up site structure

```bash
bash apollo/scripts/setup-site.sh
```

This creates:
```
your-site/
├── apollo/           # Theme (git subtree)
├── content/          # Your markdown files
├── overrides/        # Optional theme overrides
├── _config.local.yml # Your site config
└── scripts/
    └── compose.sh    # Build script (copied)
```

### 3. Add your content

Edit files in `content/`:
- `content/_essays/` - Blog posts
- `content/home/index.md` - Homepage
- `content/about.md` - About page

### 4. Run locally

```bash
bundle install
bash scripts/compose.sh serve
```

### 5. Customize (optional)

- **Config**: Edit `_config.local.yml` for title, author, etc.
- **Overrides**: Copy any theme file to `overrides/` and modify it

### 6. Update theme later

```bash
git fetch apollo
git subtree pull --prefix=apollo apollo master --squash
```

---

## Project Structure

| Directory | Purpose |
|-----------|---------|
| `_layouts/` | Page templates |
| `_includes/` | Reusable components |
| `_sass/` | Modular SCSS styles |
| `assets/` | CSS, JS, images |
| `examples/content/` | Demo content (template repo only) |

---

## Development

### Commands

| Command | Description |
|---------|-------------|
| `bash scripts/compose.sh serve` | Build and serve with live reload |
| `bash scripts/compose.sh build` | Build only (for CI) |
| `bash scripts/compose.sh clean` | Remove build directory |

### How it works

1. `compose.sh` merges theme + content + overrides into `build/src/`
2. Jekyll builds from `build/src/` to `_site/`
3. `fswatch` monitors source files and triggers rebuild on changes
4. LiveReload refreshes browser automatically

---

## License

MIT
