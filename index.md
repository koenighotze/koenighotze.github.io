---
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: home
---

<!-- <div class="blog-header">
  <h1 class="blog-title">{{ site.title | default: site.github.repository_name }}</h1>
  <p class="lead blog-description">Last update {{ "now" | date: "%d.%m.%Y %H:%M" }}</p>
</div>
 -->

This site is just a collection of random stuff about coding, architecture and whatever I find interesting.

{% assign post = site.posts.first %}
{% assign content = post.content %}
{% include single_post.html %}