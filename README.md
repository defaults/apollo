# Apollo Blog 🚀

A flexible Jekyll-based personal website generator with automated deployment to Google Cloud App Engine. Supports both local content management and external content repositories.

## Features ✨

- **File-based Content Structure**: URLs match your file organization
- **Flexible Content Sources**: Local `content/` directory or external Git repository
- **Auto-deployment**: Deploys on changes to main repo OR content changes
- **Clean Design**: Minimal, readable design with dark/light mode support
- **Google Cloud Integration**: Automated deployment to App Engine
- **Easy Updates**: Pull theme updates without losing your content

## Vendored Theme (git subtree)

Recommended for personal sites. Keep your content separate and pull theme updates safely.

Site structure:

```
├─ apollo/                 # subtree of this repo
├─ content/                # your markdown only
├─ overrides/              # optional overrides (mirrors theme paths)
├─ _config.yml             # site identity + settings (single file)
└─ .github/workflows/deploy.yml   # site’s own CI
```

Bootstrap your site (run in your site repo):

```bash
git remote add apollo git@github.com:defaults/apollo.git
git fetch apollo
git subtree add --prefix=apollo apollo master --squash

# Create content/, overrides/, site CI, and app.yaml
bash apollo/scripts/setup-site.sh

# Local preview (Ruby 3 users may need: bundle add webrick)
bash apollo/scripts/compose.sh serve
```

To reset scaffolding later, delete the generated files you want to regenerate
and re-run `bash apollo/scripts/setup-site.sh`. For example, to reset your
workflow:

```bash
rm -f .github/workflows/deploy.yml
bash apollo/scripts/setup-site.sh
```

CI builds (generated workflow uses this under the hood):

```bash
bash apollo/scripts/compose.sh build
BUNDLE_GEMFILE=apollo/Gemfile bundle exec jekyll build \
  --source build/src \
  --config build/src/_config.yml \
  --destination _site
```

Update theme later:

```bash
git fetch apollo
git subtree pull --prefix=apollo apollo master --squash
```

## GCP Setup (required for deploys)

In your site repo on GitHub, add a secret used by the deploy workflow:

1) Create a service account and key (one time)
- Roles: App Engine Admin, Service Account User, Storage Admin
- Create JSON key; copy its full contents

2) Add repository secret
- GitHub → Settings → Secrets and variables → Actions → New repository secret
- Name: `GCP_SERVICE_ACCOUNT_KEY`
- Value: paste the JSON from step 1

Now pushes to `master` will build and deploy via the generated workflow.

## Local Demo (this repo)

```bash
bash scripts/compose.sh demo
bundle exec jekyll build --source build/src --config build/src/_config.yml --destination _site
bundle exec jekyll serve --source build/src --config build/src/_config.yml --destination _site --livereload
```

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

### Updating Theme in your site repo

```bash
git fetch apollo
git subtree pull --prefix=apollo apollo master --squash
```

## Project Structure 📁

```
apollo/                   # vendored theme subtree
content/                  # your markdown content
overrides/                # optional template overrides
.github/workflows/deploy.yml  # generated site workflow
_config.yml               # site identity (title, url, analytics)
app.yaml                  # App Engine config
main.py                   # App Engine fallback (unused for static)
.gcloudignore             # exclude dev files from deploy
.gitignore                # ignore local artifacts
```

## Troubleshooting 🔧

### Common Issues

**Build fails locally:**
```bash
bundle install
bundle exec jekyll build --verbose
```

**Content not showing:**
- Check file format matches requirements
- Verify front matter syntax
- Ensure dates are in YYYY-MM-DD format for blog posts

**Deployment fails:**
- Check GitHub Actions logs
- Verify Google Cloud secrets are set correctly


**Pages conflicting (multiple sources):**
- If you see build conflicts for 404/about/index, run: `bash apollo/scripts/compose.sh build` (it removes duplicates after promotion)

### Useful Commands

```bash
# Check site locally
bundle exec jekyll serve --livereload

# Build for production
bundle exec jekyll build

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
## Use as a vendored theme (recommended for blogs)

In your site repo (not here):

```bash
git remote add apollo git@github.com:defaults/apollo.git
git fetch apollo
git subtree add --prefix=apollo apollo master --squash
```

Keep your content in content/, optional overrides in overrides/, and per-site config in _config.yml. To pull template updates:

```bash
git fetch apollo
git subtree pull --prefix=apollo apollo master --squash
```

In CI, build with the theme Gemfile:

```bash
BUNDLE_GEMFILE=apollo/Gemfile bundle exec jekyll build --source build/src --config build/src/_config.yml --destination _site
```
