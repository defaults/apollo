---
layout: essay
title: "Code Highlighting Example"
description: "Demonstrating syntax highlighting for various languages."
date: 2023-10-27
---

This post demonstrates the syntax highlighting capabilities of the Apollo theme. We use a custom Flexoki-based color scheme.

## Python

```python
def fibonacci(n):
    if n <= 1:
        return n
    else:
        return fibonacci(n-1) + fibonacci(n-2)

print([fibonacci(i) for i in range(10)])
```

## JavaScript

```javascript
const greet = (name) => {
  console.log(`Hello, ${name}!`);
};

greet('Apollo');

class User {
  constructor(name) {
    this.name = name;
  }
}
```

## CSS

```css
body {
  font-family: 'Inter', sans-serif;
  background-color: var(--color-bg-primary);
  color: var(--color-tx-normal);
}

.highlight {
  border-radius: 4px;
}
```

## HTML

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Document</title>
</head>
<body>
  <h1>Hello World</h1>
</body>
</html>
```

## JSON

```json
{
  "name": "Apollo",
  "version": "1.0.0",
  "features": [
    "Minimalist",
    "Fast",
    "Dark Mode"
  ]
}
```

## Shell

```bash
# Install dependencies
bundle install

# Build the site
bundle exec jekyll build
```
