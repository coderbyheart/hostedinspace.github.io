---
layout: default
---
# gogs

gogs ist ein git-Webdienst ähnlich zu dem was github, oder als Konkurent gitlab, welches man sich ebenfalls zum selbst hosten installieren kann, bietet. Gitlab ist zwar das bekanntere Projekt und hat vielleicht auch mehr Features, ist allerdings typische Ruby-Software und entsprechend lustig zum aufsetzen. Wer es unkomplizierter mag und außerdem vielleicht auch ohne eine gitshell aus kommt, weil es eigentlich nur um ein Webinterface geht, mit der Möglichkeit geht, eigene Projekte mit einer http(s)-url verfügbar zu machen, für den ist gogs auf jeden Fall eine einfache und schicke Lösung.

Die Installation geht relativ einfach von statten und folgt im großen der offiziellen Anleitung. Wichtig war bei mir, nicht das Go zu benutzen, welches installiert ist, auch wenn es eigentlich aktuell genug sein sollte, sondern auch hier, eine neue Version lokal zu installieren.

Die aus den Quellen gebaute Version braucht außerdem MySQL oder PostgreSQL, SQLite funktionierte bei mir nicht. Also erst einmal in den Adminer gehen, und eine neue Datenbank für gogs anlegen. 
Dann nach dem wir die Installation abgeschlossen haben, wollen wir vor dem ausführen noch die Config anpassen.

Mein Ansatz ist, gogs in einem Unterordner meiner Domain laufen zu lassen, also wollen wir das in die Konfiguration schreiben und außerdem brauchen wir noch eine freie Port Nummer. 
Also sollte unser app.ini nun so aussehen:

```
DOMAIN = $EUREURL
HTTP_PORT = $EUERPORT
ROOT_URL = https://$EUREURL/git/
DISABLE_SSH = true
[database]
DB_TYPE = mysql
HOST = 127.0.0.1:3306
NAME = $USERNAME_gogs
USER = $USERNAME
PASSWD = $MYSQLPW
```

und für den port brauchen wir noch in dem Webroot euer Domain im Ordner /git/ eine .htaccess Datei, welche so aussehen sollte:

```
RewriteRule ^(.*) http://localhost:$EUERPORT/$1 [P]
```

Damit passt jetzt alles, und ihr solltet, nachdem ihr gogs mit ./gogs web gestartet hab, euch euren Nutzer anlegen können.

