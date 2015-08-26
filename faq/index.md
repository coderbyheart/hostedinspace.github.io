---
layout: default
title: Häufig gestellte Fragen
---
# {{ page.title }}

{% for faq in site.data.faq %}
{% if lastsection != faq.section %}
## {{ faq.section }}
{% endif %}
### {{ faq.q }}
{{ faq.a|markdownify }}
{% assign lastsection = faq.section %}
{% endfor %}
