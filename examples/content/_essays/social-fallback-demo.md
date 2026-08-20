---
layout: essay
title: "Social Fallback Demo"
date: 2024-04-06
description: "A sample essay that relies on Apollo's social image fallback chain instead of explicit social_image front matter."
hero:
  image: /assets/images/essays/welcome-demo.png
  alt: A minimalist abstract composition used to demonstrate social metadata fallback
  caption: This hero image should also become the social preview image.
---

This page intentionally omits `social_image`. Apollo should use `hero.image` for Open Graph and Twitter metadata.

For production posts, prefer an explicit `social_image` when the hero image is not already cropped for social cards. The recommended size is `1200x630`.
