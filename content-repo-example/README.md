# Content Repository for Apollo

This is an example content repository for use with the Apollo personal website generator. This repository contains all the content for your personal website, including blog posts, publications, and static pages.

## Repository Structure

```
content-repo/
├── _posts/            # Blog posts
│   ├── 2023-01-01-welcome-to-apollo.md
│   ├── 2023-02-15-my-research-interests.md
│   └── 2023-03-30-conference-presentation.md
├── _publications/     # Publications
│   ├── 2023-apollo-paper.md
│   ├── 2022-research-findings.md
│   └── 2021-literature-review.md
├── pages/             # Static pages
│   ├── about.md
│   ├── contact.md
│   └── projects.md
└── assets/            # Content-specific assets
    ├── images/
    │   ├── profile.jpg
    │   └── project-screenshot.png
    └── pdfs/
        └── apollo-paper.pdf
```

## Content Guidelines

### Blog Posts

Blog posts should be placed in the `_posts` directory with filenames following the format `YYYY-MM-DD-title.md`. Each post should include front matter with the following fields:

```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD
author: "Your Name"
description: "A brief description of your post"
---
```

### Publications

Publications should be placed in the `_publications` directory with filenames following the format `YYYY-title.md`. Each publication should include front matter with the following fields:

```yaml
---
layout: publication
title: "Publication Title"
date: YYYY-MM-DD
authors: ["Author 1", "Author 2"]
description: "A brief description of your publication"
doi: "10.1234/example.doi"
pdf: "/assets/pdfs/publication.pdf"
code: "https://github.com/username/repo"
---
```

### Static Pages

Static pages should be placed in the `pages` directory. Each page should include front matter with the following fields:

```yaml
---
layout: default
title: "Page Title"
description: "A brief description of your page"
---
```

## Using This Repository

1. Clone this repository
2. Replace the example content with your own
3. Update the `content_repo` field in your Apollo `_config.yml` file with the URL of this repository
4. Push changes to this repository to trigger a build and deployment of your website

## How Content is Merged

When you push changes to this repository:
1. The GitHub Actions workflow clones this repository
2. Content is organized into the Apollo site's `content` directory:
   - `_posts` → `content/_posts`
   - `_publications` → `content/_publications`
   - `pages` → `content/pages`
   - `assets` → `content/assets`
3. Jekyll builds the site using this organized content
4. The site is deployed to App Engine

## Customization

You can customize the content of your website by modifying the markdown files in this repository. The Apollo template will automatically generate the HTML for your website based on these files. 