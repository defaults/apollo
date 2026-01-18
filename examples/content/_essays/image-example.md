---
layout: essay
title: "Image Handling Example"
description: "Demonstrating image styles, captions, and responsive behavior."
date: 2023-10-28
image: /assets/images/icon.svg
---

This post demonstrates how images are handled in Apollo. The image above is a "Hero Image" defined in the front matter.

## Standard Image

Here is a standard image embedded in the content:

![Apollo Icon](/assets/images/icon.svg)

## Image with Caption

We use the `<figure>` and `<figcaption>` elements for semantic captions.

<figure>
  <img src="/assets/images/icon.svg" alt="Apollo Icon" width="200">
  <figcaption>Figure 1: The Apollo Icon, a symbol of simplicity.</figcaption>
</figure>

## Wide Image

You can add the `.wide` class to make an image break out of the content column (on larger screens).

<div class="wide">
  <img src="/assets/images/icon.svg" alt="Wide Image">
</div>

## Image Grid

You can use the `.grid` utility to create image layouts.

<div class="grid grid-columns gap1">
  <img src="/assets/images/favicon-128.png" alt="Icon 1" class="ra">
  <img src="/assets/images/favicon-128.png" alt="Icon 2" class="ra">
  <img src="/assets/images/favicon-128.png" alt="Icon 3" class="ra">
</div>
