---
layout: default
---
# Shout

Da [[Shout|http://shout-irc.com]] einen eigenen Port benötigt, muss dieser zunächst freigeschaltet werden:
```
space-mod-ports open
```
Den angezeigten Port merken.

Zuerst muss NPM korrekt konfiguriert werden:

```
cat > ~/.npmrc <<__EOF__
prefix = $HOME/.local
umask = 077
__EOF__
```

Danach kann Shout installiert werden:

```
npm install -g shout
```

Nun muss Shout konfiguriert werden:

```
shout config
```

Wenn nur der Client genutzt werden soll:
```
public: false
```

Hier $PORTNUMMER durch den eben geöffneten Port ersetzen:
```
port: $PORTNUMMER
```

Hier Standardkanäle und Nicknamen anpassen:
```
defaults: 
```

Falls Shout so konfiguriert wurde, dass nur hinzugefügte Benutzer Zugriff haben, müssen diese noch hinzugefügt werden:

```
shout add <name>
```

Soll Shout nicht über seinen eigenen Port, sondern über eine "normale" Domain erreichbar sein, muss noch folgende .htaccess-Datei in den entsprechenden Ordner in $HOME/domains gelegt werden:
```
RewriteEngine On
RewriteRule ^(.*) http://localhost:$PORTNUMMER/$1 [P]
```

Damit Shout nach einem Serverneustart von alleine startet, muss noch der Dienst eingerichtet werden:
```
space-setup-service shout-irc shout
```

