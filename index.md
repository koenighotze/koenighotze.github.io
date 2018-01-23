---
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: home
---

{% assign post = site.posts.first %}
{% assign content = post.content %}
{% include single_post.html %}