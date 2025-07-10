---
layout: home
title: Home
description: Personal website and portfolio
permalink: /
---

{{ site.user.name | default: site.title | default: "Your Name" }} is a [your role/profession], [brief description of your work or expertise].

Previously, [previous experience]. [Additional background information].

[Your educational background or other relevant details].


## Research

[Google Scholar](https://scholar.google.com/citations?user=YOUR_GOOGLE_SCHOLAR_ID){:target="_blank"}


{% assign essays = site.posts | limit: 5 %}
{% if essays.size > 0 %}
## Essays

{% for post in essays %}
- [{{ post.title }}]({{ post.url | relative_url }})

{% endfor %}

[View all essays →](/essays/)
{% endif %}
