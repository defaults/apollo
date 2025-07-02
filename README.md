# Apollo Blog 🚀

A simple, flexible Jekyll-based personal website generator with file-structure-based routing.

## Features ✨

- **File-based Content Structure**: URLs match your file organization
- **Single Configuration**: All settings in one `_config.yml` file
- **Flexible Content Sources**: Local content directory or external Git repository
- **Clean Design**: Minimal, readable design with dark/light mode support
- **Auto-deployment**: GitHub Actions for automatic deployment

## Quick Start 🏃‍♂️

### 1. Clone and Setup

```bash
git clone https://github.com/your-username/apollo.git
cd apollo
bundle install
```

### 2. Add Your Content

All content goes in the `content/` directory with URLs matching file structure:

```
content/
├── home/
│   └── index.md          # Homepage (/)
├── blog/
│   ├── post1.md          # Blog posts (/essays/post1)
│   └── post2.md          # Blog posts (/essays/post2)
├── about.md              # About page (/about/)
├── 404.md                # 404 page
└── essays/
    └── index.md          # Essays listing (/essays/)
```

### 3. Configure Your Site

Edit `_config.yml`:
```yaml
# Site Settings  
user:
  name: "Your Name"
  domain: "yourdomain.com"
  description: "Your description"

# Content Settings
content:
  source: "local"           # "local" or "external"
  repository: ""            # Git URL if external

# Optional Features
features:
  google_scholar:
    enabled: true
    user_id: "your-scholar-id"
```

### 4. Build and Run

```bash
# Build the site
bundle exec jekyll build

# Serve locally
bundle exec jekyll serve --livereload
```

## Content Management 📝

### File Structure = URL Structure

- `content/home/index.md` → `/` (homepage)
- `content/about.md` → `/about/`
- `content/blog/my-post.md` → `/essays/my-post/` (blog posts)
- `content/projects/index.md` → `/projects/`
- `content/contact.md` → `/contact/`

### Blog Posts

Files in `content/blog/` automatically become blog posts under `/essays/`:

```markdown
---
layout: post
title: "My First Post"
date: 2024-01-15
description: "Post description"
---

Your blog content here...
```

### External Content Repository

To use external content (great for collaboration or multiple devices):

1. **Set up external repo**:
   ```yaml
   content:
     source: "external"
     repository: "https://github.com/username/my-content.git"
   ```

2. **External repo structure**:
   ```
   my-content-repo/
   ├── home/index.md
   ├── blog/
   │   ├── post1.md
   │   └── post2.md
   └── about.md
   ```

3. **Deploy**: GitHub Actions automatically syncs and builds

## Deployment 🚀

### GitHub Pages (Automatic)

1. **Enable GitHub Pages** in repository settings
2. **Set source** to "GitHub Actions"  
3. **Push changes** - automatic deployment!

The included workflow:
- Syncs external content (if configured)
- Builds with Jekyll
- Deploys to GitHub Pages

### Local Development

```bash
# Watch for changes with live reload
bundle exec jekyll serve --livereload

# Build for production
bundle exec jekyll build
```

## Configuration Options 🔧

### Basic Settings

```yaml
user:
  name: "Your Name"        # Appears in header
  domain: "example.com"    # Your domain
  description: "Bio text"  # Site description
```

### Content Source

```yaml
content:
  source: "local"          # or "external"
  repository: ""           # Git URL for external content
```

### Optional Features

```yaml
features:
  google_scholar:
    enabled: true
    user_id: "your-scholar-id"
```

## Project Structure 📁

```
apollo/
├── content/              # All your content (markdown files)
├── _layouts/             # Jekyll templates
├── _includes/            # Reusable components
├── _plugins/             # Content loading logic
├── assets/               # CSS, JS, images
├── _config.yml           # Site configuration
└── .github/workflows/    # Auto-deployment
```

## Customization 🎨

### Styling

Modify `assets/css/styles.css` and Tailwind configuration in `tailwind.config.js`.

### Layouts

Edit templates in `_layouts/` and `_includes/` directories.

### Content Loading

The content loader (`_plugins/content_loader.rb`) handles file-to-URL mapping.

## Examples 💡

### Adding a Projects Page

1. Create `content/projects/index.md`:
   ```markdown
   ---
   layout: default
   title: Projects
   permalink: /projects/
   ---
   
   # My Projects
   
   Here are some projects I've worked on...
   ```

2. Accessible at `/projects/`

### Adding Nested Content

1. Create `content/projects/web-apps/apollo.md`:
   ```markdown
   ---
   layout: default
   title: Apollo Blog
   ---
   
   # Apollo Blog Project
   
   Details about the Apollo blog system...
   ```

2. Accessible at `/projects/web-apps/apollo/`

## Contributing 🤝

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## License 📄

MIT License - see LICENSE file for details.

---

**Happy blogging!** 🎉

For questions or support, please [open an issue](https://github.com/your-username/apollo/issues).
