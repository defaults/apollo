# Apollo Blog 🚀

A powerful, flexible Jekyll-based personal website and blog generator that adapts to your content workflow.

## Features ✨

- **Flexible Content Management**: Use local markdown files or external Git repositories
- **Dynamic Configuration**: Personalize without modifying core code
- **Auto-deployment**: Automatic rebuilds when content changes
- **Clean Design**: Minimal, readable design with dark/light mode support
- **Optional Integrations**: Google Scholar, email subscriptions, social links
- **Conflict-free Updates**: Pull updates without losing your configuration

## Quick Start 🏃‍♂️

### 1. Clone and Setup

```bash
git clone https://github.com/your-username/apollo.git
cd apollo
bundle install
chmod +x setup.sh
./setup.sh
```

### 2. Configure Your Blog

The setup script will ask you about:
- **Personal Information**: Name, domain, description
- **Content Source**: Local folder or external Git repository
- **Optional Features**: Google Scholar, email subscriptions, social links

### 3. Build and Run

```bash
# Build your site
./build.sh

# Serve locally for development
bundle exec jekyll serve --config _site-config.yml
```

## Content Management 📝

### Option 1: Local Content (Recommended for Getting Started)

When you choose local content, Apollo creates a `content/` directory:

```
content/
├── posts/          # Your blog posts
├── pages/          # Static pages (about, etc.)
└── assets/
    └── images/     # Images for your posts
```

- Write posts in `content/posts/` using Jekyll's naming convention: `YYYY-MM-DD-title.md`
- Add pages like About in `content/pages/`
- The setup script initializes this with example content

### Option 2: External Git Repository

Perfect for:
- Separating content from code
- Writing on multiple devices
- Collaborating with editors
- Version controlling content separately

1. Create a separate repository for your content
2. Choose "External Git repository" during setup
3. Push content changes to trigger automatic rebuilds

**External Repository Structure:**
```
your-content-repo/
├── posts/
│   ├── 2024-01-15-my-first-post.md
│   └── 2024-02-01-another-post.md
├── pages/
│   ├── about.md
│   └── contact.md
└── assets/
    └── images/
```

## Configuration 🔧

### User Configuration (`user-config.yml`)

This file contains your personal settings and won't be overwritten by updates:

```yaml
user:
  name: "Your Name"
  domain: "yourdomain.com"
  description: "Brief description about yourself"

content:
  source: "local"  # or "external"
  repository: ""   # Git URL if external

features:
  google_scholar:
    enabled: true
    user_id: "your-google-scholar-id"
  
  subscription:
    enabled: true
    service: "mailchimp"  # mailchimp, convertkit, custom
    url: "your-form-url"
  
  social:
    enabled: true
    twitter: "yourusername"
    linkedin: "https://linkedin.com/in/yourusername"
    github: "yourusername"

build:
  auto_rebuild: true
  include_drafts: false
```

## Deployment 🚀

### GitHub Pages (Recommended)

1. **Enable GitHub Pages** in your repository settings
2. **Set source** to "GitHub Actions"
3. **Push your changes** - the included workflow handles everything!

The deployment process:
- Checks for user configuration
- Syncs external content (if configured)
- Merges configurations
- Builds and deploys to GitHub Pages

### External Content Auto-Deployment

For external content repositories:

1. **Deploy the webhook handler** (optional, for instant updates):
   ```bash
   # Deploy webhook-handler.js to your preferred platform
   # Set environment variables:
   # - GITHUB_TOKEN
   # - WEBHOOK_SECRET
   # - BLOG_REPO_OWNER
   # - BLOG_REPO_NAME
   ```

2. **Add webhook** to your content repository:
   - Go to Settings > Webhooks
   - Add webhook URL: `https://your-handler.com/webhook/content-update`
   - Set content type to `application/json`
   - Add your webhook secret

## Writing Content ✍️

### Blog Posts

Create files in `content/posts/` (or your external repo):

```markdown
---
layout: post
title: "My Awesome Post"
date: 2024-01-15
description: "A brief description of the post"
---

Your content here...
```

### Pages

Create files in `content/pages/`:

```markdown
---
layout: default
title: "About"
permalink: /about/
---

About me...
```

## Development 💻

### Local Development

```bash
# Install dependencies
bundle install

# Run setup if not done
./setup.sh

# Build the site
./build.sh

# Serve locally with live reload
bundle exec jekyll serve --config _site-config.yml --livereload
```

### Testing External Content

```bash
# If using external content, sync it
./sync-content.sh

# Then build
./build.sh
```

## Customization 🎨

### Styling

The theme uses Tailwind CSS. Modify styles in:
- `assets/css/styles.css` - Main styles
- `_layouts/` - HTML templates
- `_includes/` - Reusable components

### Adding Features

1. **Modify `user-config.yml`** to add new configuration options
2. **Update layouts** in `_layouts/` and `_includes/` to use new features
3. **Test locally** before deploying

## Troubleshooting 🔧

### Common Issues

**Build fails with missing user-config.yml:**
```bash
./setup.sh  # Run setup again
```

**External content not syncing:**
```bash
./sync-content.sh  # Manual sync
```

**Local development not working:**
```bash
bundle install
bundle exec jekyll serve --config _site-config.yml
```

**Styles not loading:**
- Check if Tailwind CSS is properly configured
- Verify `assets/css/styles.css` is included in layouts

### Getting Help

1. Check the [Issues](https://github.com/your-username/apollo/issues) page
2. Review the deployment logs in GitHub Actions
3. Verify your `user-config.yml` syntax

## Updating Apollo 🔄

Apollo is designed for conflict-free updates:

```bash
git pull origin main
# Your user-config.yml and content/ are preserved
./build.sh  # Rebuild with updates
```

## Contributing 🤝

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License 📄

[Add your license here]

## Roadmap 🗺️

- [ ] Theme customization UI
- [ ] More subscription service integrations
- [ ] Content scheduling
- [ ] SEO optimization tools
- [ ] Multi-author support

---

**Happy blogging!** 🎉

For questions or support, please [open an issue](https://github.com/your-username/apollo/issues).
