---
layout: default
---
# Shout

Da [Shout](http://shout-irc.com/) einen eigenen Port benötigt, muss dieser zunächst freigeschaltet werden:

{% highlight bash %}
space-mod-ports open
{% endhighlight %}

Den angezeigten Port merken.

Zuerst muss NPM korrekt konfiguriert werden:

{% highlight bash %}
cat > ~/.npmrc <<__EOF__
prefix = $HOME/.local
umask = 077
__EOF__
{% endhighlight %}

Danach kann Shout installiert werden:

{% highlight bash %}
npm install -g shout
{% endhighlight %}

Nun muss Shout konfiguriert werden:

{% highlight bash %}
shout config
{% endhighlight %}

Wenn nur der Client genutzt werden soll:

{% highlight bash %}
public: false
{% endhighlight %}

Hier $PORTNUMMER durch den eben geöffneten Port ersetzen:

{% highlight bash %}
port: $PORTNUMMER
{% endhighlight %}

Hier Standardkanäle und Nicknamen anpassen:

{% highlight bash %}
defaults:
{% endhighlight %}

Falls Shout so konfiguriert wurde, dass nur hinzugefügte Benutzer Zugriff haben, müssen diese noch hinzugefügt werden:

{% highlight bash %}
shout add <name>
{% endhighlight %}

Soll Shout nicht über seinen eigenen Port, sondern über eine "normale" Domain erreichbar sein, muss noch folgende .htaccess-Datei in den entsprechenden Ordner in $HOME/domains gelegt werden:

{% highlight bash %}
RewriteEngine On
RewriteRule ^(.*) http://localhost:$PORTNUMMER/$1 [P]
{% endhighlight %}

Damit Shout nach einem Serverneustart von alleine startet, muss noch der Dienst eingerichtet werden:

{% highlight bash %}
space-setup-service shout-irc shout
{% endhighlight %}
