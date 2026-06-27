---
layout: essay
title: "Rich Content Demo"
date: 2024-04-05
description: "A single sample essay for testing Apollo's figures, hero images, code blocks, math, and Mermaid diagrams."
math: true
mermaid: true
hero:
  image: /assets/images/essays/welcome-demo.png
  alt: A minimalist abstract composition used as a demo hero
  caption: Hero images can be configured with alt text and Markdown-aware captions.
social_image: /assets/images/og/essays/welcome.png
---

This essay is intentionally practical: it gives the example site one page that touches the rich content helpers Apollo adds on top of regular Markdown.

## Hero and Social Images

The front matter for this page sets both `hero.image` and `social_image`. The essay layout should render the hero image above this content, while SEO/social metadata should use the explicit `social_image` value.

## Figures

Inline figures use the `figure.html` include. The default layout stays within the text measure and lazy-loads the image.

{% include figure.html
  src="/assets/images/essays/welcome-demo.png"
  alt="A minimalist abstract composition inside a standard figure"
  caption="Default figures stay aligned with the article content."
  credit="Demo artwork from the Apollo example assets."
  width="1200"
  height="800"
%}

The same include can opt into a wide layout when an image benefits from more horizontal space.

{% include figure.html
  src="/assets/images/essays/welcome-demo.png"
  alt="A minimalist abstract composition shown in a wide figure"
  caption="Wide figures break out from the text column while keeping captions attached."
  layout="wide"
  width="1200"
  height="800"
%}

## Code Blocks

Language labels and copy buttons are added after render. This TypeScript block should display a `TypeScript` label.

```typescript
type FeatureFlag = {
  key: 'math' | 'mermaid' | 'figures' | 'codeCopy';
  enabled: boolean;
};

const enabled = (features: FeatureFlag[]) => {
  return features.filter((feature) => feature.enabled).map((feature) => feature.key);
};

console.log(enabled([
  { key: 'math', enabled: true },
  { key: 'mermaid', enabled: true },
  { key: 'figures', enabled: true },
  { key: 'codeCopy', enabled: true }
]));
```

Diff fences should highlight inserted and deleted lines.

```diff
- image: /assets/images/og/essays/welcome.png
+ hero:
+   image: /assets/images/essays/welcome-demo.png
+   alt: A readable description
+ social_image: /assets/images/og/essays/welcome.png
```

## Mermaid

With `mermaid: true`, Mermaid fences are converted from highlighted code into a diagram container and rendered by the client-side Mermaid bundle.

```mermaid
flowchart LR
  Content[Markdown Content] --> Render[Jekyll Render]
  Render --> Enhance[Content Enhancements]
  Enhance --> Browser[Browser Scripts]
  Browser --> Reader[Reader Experience]
```

## Math

With `math: true`, MathJax renders inline expressions like $a^2 + b^2 = c^2$ and display equations:

$$
\operatorname{score}(page) = \frac{readability + media + metadata}{3}
$$

## Expected Result

When this page is built locally, it should show a hero image with a caption, two captioned figures, copyable code blocks with labels, highlighted diff lines, a rendered Mermaid diagram, and rendered math.
