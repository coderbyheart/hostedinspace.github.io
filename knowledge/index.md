---
layout: default
title: "Anleitungen"
---
# Anleitungen

<ul>
{% for p in site.pages %}
{% assign path_parts = p.url | split: '/' %}
{% if path_parts[1] == 'knowledge' and path_parts[2] %}
  <li><a href="{{ p.url }}">{{ p.url | replace:'/knowledge/','' | replace:'/','' }}</li>
{% endif %}
{% endfor %}
</ul>
