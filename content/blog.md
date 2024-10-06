---
layout: default
title: "Blog"
permalink: /blog/
---

<section class="container mx-auto p-6">
  <h2 class="text-3xl font-bold mb-6">Blog</h2>
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    {% for post in site.posts %}
      <div class="border rounded-lg p-4 hover:shadow-lg transition-shadow">
        <h3 class="text-2xl font-semibold">
          <a href="{{ post.url }}" class="text-blue-600 hover:underline">{{ post.title }}</a>
        </h3>
        <p class="mt-2 text-gray-700">{{ post.excerpt }}</p>
        <a href="{{ post.url }}" class="text-blue-500 hover:underline mt-2 inline-block">Read More</a>
      </div>
    {% endfor %}
  </div>
</section>