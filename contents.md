---
title: Inhalt
layout: default
permalink: /contents/
nav: true
order: 2
---

# Inhalt

{% assign content_pages = site.pages | sort:"order" %}
{% for my_page in content_pages %}
  {% if my_page.contents %}
  {{my_page.order}}. [{{ my_page.title }}]({{ my_page.url | prepend: site.github.url }})
  {% endif %}
{% endfor %}
