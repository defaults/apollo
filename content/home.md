---
layout: default
title: "Home"
permalink: /home/
---

<section class="flex flex-col items-center justify-center min-h-screen bg-cover bg-center" style="background-image: url('{{ site.baseurl }}/assets/images/background.jpg');">
  <img src="{{ site.baseurl }}{{ site.profile_image }}" alt="Profile Image" class="w-32 h-32 rounded-full shadow-lg">
  <h1 class="text-4xl font-bold mt-6">Hello, I'm Apollo</h1>
  <p class="mt-4 text-lg text-center max-w-2xl">Welcome to my personal website. I share my thoughts, projects, and publications here.</p>
  <div class="mt-8 flex space-x-4">
    <a href="{{ site.baseurl }}/blog/" class="px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700">Visit Blog</a>
    <a href="{{ site.baseurl }}/about/" class="px-6 py-3 bg-gray-600 text-white rounded hover:bg-gray-700">About Me</a>
  </div>
</section>