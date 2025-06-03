# Apollo - Personal Website Generator

Apollo is a simple and flexible personal website generator built with Jekyll. It allows you to create beautiful personal websites with minimal configuration and easy customization. The content can be stored in a separate repository, making it easy to manage and update.

## Features

- Jekyll-based templating and markdown processing
- Separate content repository for easy content management
- Mobile-first and responsive design using Tailwind CSS
- Easy customization through config files
- Support for blog posts (`content/_posts`) and publications (`content/_publications`) collections
- Content pages stored in `content/pages` for easy replacement
- Customizable templates
- Automated build and deployment to Google App Engine with GitHub Actions

## Getting Started

1.  **Clone this repository:**
    ```bash
    git clone https://github.com/yourusername/apollo.git
    cd apollo
    ```

2.  **Install dependencies:**
    ```bash
    # Install Ruby & Jekyll dependencies
    gem install bundler
    bundle install

    # Install Node.js & Tailwind dependencies
    # Ensure you have Node.js and npm installed
    npm install
    ```

3.  **Create a content repository:**
    *   Create a new GitHub repository for your content.
    *   Structure it as shown in `content-repo-example/README.md` (e.g., with `_posts`, `_publications`, `pages`, `assets` directories).
    *   Update the `content_repo` field in `_config.yml` with your repository URL.

4.  **Customize your site:**
    *   Edit `_config.yml` to change site settings.
    *   Add your content locally in the `content/` directory or push to your content repository.
    *   Customize templates in the `_layouts` and `_includes` directories.
    *   Modify Tailwind styles in `assets/css/input.css`.

5.  **Build and serve locally:**
    ```bash
    # Build CSS
    npm run build:css

    # Build Jekyll site and serve
    bundle exec jekyll serve --livereload
    ```
    Your site will be available at `http://localhost:4000`.

## Directory Structure

```
apollo/
├── content/               # All user-replaceable content
│   ├── _posts/            # Blog posts
│   ├── _publications/     # Publications
│   ├── pages/             # Content pages (about, contact, etc.)
│   └── README.md          # Content directory documentation
├── _layouts/              # Jekyll layout templates
├── _includes/             # Jekyll include files
├── assets/                # Static assets (CSS input/output, JS, images)
│   ├── css/
│   └── js/
├── content-repo-example/  # Example structure for external content repo
├── _config.yml            # Jekyll & Site configuration
├── app.yaml               # Google App Engine configuration
├── Gemfile                # Ruby dependencies (Jekyll)
├── package.json           # Node.js dependencies (Tailwind)
├── tailwind.config.js     # Tailwind CSS configuration
├── index.html             # Site homepage
├── README.md              # This file
└── .github/workflows/     # GitHub Actions workflow
```

## Content Repository

The content repository should follow the structure outlined in `content-repo-example/README.md`. This allows for separation of concerns between the site template and the actual content.

## Automated Build and Deployment

Apollo uses GitHub Actions (`.github/workflows/build-and-deploy.yml`) to automate the build and deployment process:

1.  When changes are pushed to the `main` branch of this repository, or when manually triggered with a content repository URL:
    *   The Apollo repository is checked out.
    *   Ruby/Jekyll dependencies are installed.
    *   Node.js dependencies are installed.
    *   Tailwind CSS is built (`npm run build:css`).
    *   The specified content repository is cloned.
    *   Content is copied into the `apollo/content/` directory.
    *   Jekyll builds the site into the `_site` directory.
    *   The site is deployed to Google App Engine using `gcloud app deploy`.

To set up automated deployment:

1.  Create a Google Cloud project.
2.  Enable the App Engine Admin API.
3.  Create a service account with the `App Engine Deployer` and `Storage Object Viewer` roles.
4.  Generate a JSON key for the service account.
5.  Add the following secrets to your Apollo GitHub repository settings:
    *   `GCP_PROJECT_ID`: Your Google Cloud project ID.
    *   `GCP_SA_KEY`: The content of the service account JSON key file.

## Customization

### Configuration

Edit `_config.yml` to customize:
*   Site title and description
*   Navigation menu
*   Footer links
*   Profile image
*   Theme settings
*   Content repository URL

### Templates

Templates are located in the `_layouts` and `_includes` directories. You can modify existing templates or create new ones.

### Styles

Customize styles by editing `assets/css/input.css` and the `tailwind.config.js` file. Run `npm run build:css` to regenerate the final `assets/css/main.css`.

### Content

Add your content in Markdown format in your content repository (or the local `content/` directory):
* Blog posts in `content/_posts/`
* Publications in `content/_publications/`
* Pages in `content/pages/`
* Assets (images, PDFs) in `assets/`

This structure allows users to easily replace all content by copying or syncing the `content` directory from another repository.

## License

MIT License - feel free to use this template for your personal website.
