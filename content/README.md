# Content Directory

This directory contains all the user-replaceable content for your Jekyll website. You can easily replace any of these files with your own content.

## Directory Structure

- `_posts/`: Blog posts, formatted in Markdown with YAML front matter
- `_publications/`: Publications, formatted in Markdown with YAML front matter
- `pages/`: Static pages like About, Contact, Blog listing, etc.

## How to Use

1. You can directly edit these files to update your site content
2. You can replace the entire content directory by pulling from another repository
3. You can use the content repository integration specified in `_config.yml`

## Front Matter Requirements

Each file should include the proper front matter. Here are examples:

### Blog Post

```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD
description: "A brief description of your post"
categories: [category1, category2]
---
```

### Publication

```yaml
---
layout: publication
title: "Publication Title"
date: YYYY-MM-DD
authors: ["Author 1", "Author 2"]
venue: "Conference or Journal"
description: "Brief description"
pdf: "https://example.com/your-paper.pdf"
code: "https://github.com/yourusername/project"
---
```

### Page

```yaml
---
layout: default
title: "Page Title"
permalink: /your-page-url/
---
``` 