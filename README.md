# Apollo Blog 🚀

A flexible Jekyll-based personal website generator with automated deployment to Google Cloud App Engine. Supports both local content management and external content repositories.

## Features ✨

- **File-based Content Structure**: URLs match your file organization
- **Flexible Content Sources**: Local `content/` directory or external Git repository
- **Auto-deployment**: Deploys on changes to main repo OR content changes
- **Clean Design**: Minimal, readable design with dark/light mode support
- **Google Cloud Integration**: Automated deployment to App Engine
- **Easy Updates**: Pull theme updates without losing your content

## Quick Start 🏃‍♂️

### 1. Fork and Clone

```bash
# Fork this repository on GitHub first, then:
git clone https://github.com/YOUR_USERNAME/apollo.git
cd apollo
```

### 2. Choose Your Content Strategy

You have two options for managing your content:

#### Option A: Local Content (Simpler)
Keep your content in the `content/` directory of this repository.

#### Option B: External Content Repository (Recommended for collaboration)
Create a separate repository for your content and link it as a submodule.

### 3. Content Format Requirements

Your content must follow this structure (whether local or external):

```
content/                  # or your-content-repo/
├── home/
│   └── index.md         # Homepage content (required)
├── blog/                # Blog posts directory
│   ├── 2024-01-15-my-first-post.md
│   ├── 2024-02-01-another-post.md
│   └── ...
├── about.md             # About page (recommended)
├── 404.md               # 404 error page (recommended)
└── essays/              # Optional: custom collections
    └── index.md
```

#### Blog Post Format
```markdown
---
layout: post
title: "Your Post Title"
date: 2024-01-15
type: post
description: "Brief description of your post"
---

Your content here using Markdown...
```

#### Page Format
```markdown
---
layout: default
title: "Page Title"
description: "Page description"
permalink: /your-url/
---

Your page content here...
```

### 4. Setup and Configuration

Run the setup script:

```bash
./scripts/setup.sh
```

This script will:
- Install dependencies (Ruby, Jekyll, Node.js packages)
- Guide you through content setup (local vs external)
- Configure Google Cloud deployment
- Set up GitHub Actions secrets

### 5. Local Development

```bash
# Start local development server
bundle exec jekyll serve --livereload

# Visit http://localhost:4000 to preview your site
```

### 6. Deploy to Google Cloud

After setup, deployment is automatic:

```bash
git add .
git commit -m "Initial setup"
git push origin master
```

Your site will be deployed to: `https://YOUR_GCP_PROJECT_ID.appspot.com`

## Content Management Options 📝

### Option A: Local Content Management

Keep all content in the `content/` directory:

1. **Add new blog posts**: Create files in `content/blog/` with format `YYYY-MM-DD-title.md`
2. **Edit pages**: Modify files in `content/` directly
3. **Deploy**: Push changes to trigger automatic deployment

### Option B: External Content Repository

Perfect for separating content from theme:

1. **Create content repository**:
   ```bash
   # Create a new repository for your content
   git clone https://github.com/YOUR_USERNAME/my-blog-content.git
   cd my-blog-content
   
   # Copy the required structure
   mkdir -p home blog
   # Add your content files following the format above
   ```

2. **Link to Apollo**:
   ```bash
   # In your Apollo repository
   git submodule add https://github.com/YOUR_USERNAME/my-blog-content.git content-external
   
   # Update _config.yml
   # content:
   #   source: "external"
   #   repository: "https://github.com/YOUR_USERNAME/my-blog-content.git"
   ```

3. **Deploy on content changes**: The GitHub Actions workflow will automatically deploy when either repository changes.

## Configuration ⚙️

Edit `_config.yml` to customize your site:

```yaml
# Site Settings  
user:
  name: "Your Name"
  domain: "yourdomain.com"
  description: "Your bio or description"

# Content Settings
content:
  source: "local"           # "local" or "external"
  repository: ""            # Git URL if external (e.g., "https://github.com/user/content.git")

# See content/home/index.md to customize research links
# Example: [Google Scholar](URL){:target="_blank"}
```

## Deployment 🚀

### Automatic Deployment Triggers

The site deploys automatically when:

1. **Main repository changes** (theme updates, configuration changes)
2. **Content changes** (either in `content/` folder or external content repository)

### Manual Deployment

```bash
# Build locally
bundle exec jekyll build

# Deploy to Google Cloud
gcloud app deploy
```

### Monitoring Deployments

- **GitHub Actions**: Check the Actions tab in your GitHub repository
- **Google Cloud Console**: Visit App Engine section for logs and metrics
- **Site Status**: Visit your deployed URL

## Updating Apollo Theme 🔄

To get theme updates without losing your content:

### For Local Content Users

```bash
# Add this repo as upstream (one-time setup)
git remote add upstream https://github.com/ORIGINAL_AUTHOR/apollo.git

# Get updates
git fetch upstream
git merge upstream/master

# Your content in content/ directory is preserved
# Resolve any conflicts if needed
git push origin master
```

### For External Content Users

```bash
# Simply pull updates - your content is safe in external repo
git pull upstream master
git push origin master
```

## Project Structure 📁

```
apollo/
├── content/              # Local content (or empty if using external)
├── content-external/     # External content submodule (if used)
├── _layouts/             # Jekyll templates
├── _includes/            # Reusable components  
├── _plugins/             # Content loading logic
├── assets/               # CSS, JS, images
├── scripts/              # Setup and utility scripts
├── .github/workflows/    # Auto-deployment workflows
├── _config.yml           # Site configuration
├── app.yaml              # Google Cloud App Engine config
└── DEPLOYMENT.md         # Detailed deployment guide
```

## Troubleshooting 🔧

### Common Issues

**Build fails locally:**
```bash
bundle install
npm install
bundle exec jekyll build --verbose
```

**Content not showing:**
- Check file format matches requirements
- Verify front matter syntax
- Ensure dates are in YYYY-MM-DD format for blog posts

**Deployment fails:**
- Check GitHub Actions logs
- Verify Google Cloud secrets are set correctly
- Run `./scripts/setup.sh` again if needed

**External content not syncing:**
- Verify submodule is properly configured
- Check content repository URL in `_config.yml`
- Ensure content repository follows required structure

### Useful Commands

```bash
# Check site locally
bundle exec jekyll serve --livereload

# Build for production
bundle exec jekyll build

# Update external content
git submodule update --remote

# View deployment logs
gcloud app logs tail -s default
```

## Security & Best Practices 🔒

- **Never commit sensitive keys**: Use GitHub secrets for deployment credentials
- **Regular updates**: Keep dependencies updated with `bundle update`
- **Content backup**: External content repos provide natural backup
- **Test locally**: Always test changes locally before pushing

## Support & Contributing 🤝

- **Issues**: [GitHub Issues](https://github.com/your-username/apollo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/apollo/discussions)
- **Contributing**: Fork, create feature branch, submit PR

## License 📄

MIT License - see [LICENSE](LICENSE) file for details.

---

**Happy blogging!** 🎉

For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).
# Site is now working ✅
