---
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: home
---

This site is just a collection of random stuff about coding, architecture and whatever I find interesting.

{% assign post = site.posts.first %}
{% assign content = post.content %}
{% include single_post.html %}