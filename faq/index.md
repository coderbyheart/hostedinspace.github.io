---
layout: default
title: Häufig gestellte Fragen
description: Hier finden Sie Antworten zu häufig gestellten Fragen zu Fintura
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

## Haben Sie eine individuelle Frage?

[Kontaktieren Sie uns einfach …](/kontakt/)
