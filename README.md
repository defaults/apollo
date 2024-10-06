# Apollo

Apollo is a personal website builder template leveraging Jekyll, Tailwind CSS, and Google App Engine with Go 1.22. It provides a flexible and customizable platform for creating and maintaining your personal website, blog, and publications.

## Features

- **Jekyll Templating**: Write content in Markdown for easy management.
- **Tailwind CSS**: Utilize utility-first CSS for rapid UI development.
- **Google App Engine Deployment**: Host your website on Google's reliable infrastructure.
- **Customizable Overrides**: Easily override headers, footers, styles, and scripts.
- **Blog Functionality**: Manage blog posts in Markdown, automatically generating HTML pages.
- **Optimized Build Process**: Compile and minify CSS, JS, and HTML for efficient deployment.

## Project Structure
Apollo/
├── override/
│   ├── header.html
│   ├── footer.html
│   ├── styles.css
│   └── main.js
├── assets/
│   ├── css/
│   │   └── tailwind.css
│   ├── js/
│   │   └── main.js
│   └── images/
│       ├── profile.jpg
│       └── icons/
│           └── … (your icon files)
├── build/
│   ├── css/
│   │   └── styles.min.css
│   ├── js/
│   │   └── main.min.js
│   ├── images/
│   │   └── … (optimized images)
│   └── … (generated HTML files)
├── _config.yml
├── package.json
├── tailwind.config.js
├── postcss.config.js
├── htmlnano.config.js
├── go.mod
├── go.sum
├── app.yaml
├── main.go
├── .gitignore
└── README.md

## Getting Started

### 1. Clone the Repository

Users can clone the Apollo repository and set it up as their own personal website.

```bash
git clone https://github.com/yourusername/apollo.git my-personal-website
cd my-personal-website
