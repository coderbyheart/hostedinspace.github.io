---
layout: default
---
# biboumi

> Biboumi is an XMPP gateway that connects to IRC servers and translates between the two protocols. It can be used to access IRC channels using any XMPP client as if these channels were XMPP MUCs.

Quelle: [biboumi Website](http://biboumi.louiz.org/)

## Voraussetzung
Installierter XMPP-Server, wie zum Beispiel [Prosody](/Anleitungen/Prosody).

## Installation
Wechsel in den Ordner *~/.opt*, klone das biboumi git-Repository von der Website und übersetzt es:

{% highlight bash %}
$ git clone git://git.louiz.org/biboumi.git
$ cmake .
$ make
$ ./biboumi
{% endhighlight %}

## Konfiguration
biboumi erwartet seine Konfiguration in *~/.config/biboumi/biboumi.cfg*.
Dort werden die Daten hinterlegt, mit welchen sich biboumi mit Prosody oder einem anderen lokalen XMPP-Server verbindet. Diese Daten müssen auch in der config des XMPP-Servers hinterlegt werden.

Erstelle die Datei und setze für `hostname` die Domain über die biboumi später angesprochen werden soll, für `password` irgendeinem Passwort und für `port` einen mit [`space-mod-ports open`](/Skripte/space-mod-ports#open) für dich geöffneten Port:

{% highlight bash %}
$ cat > ~/.config/biboumi/biboumi.cfg <<__EOF__
hostname=irc.deinedomain.tld
password=deinpasswort
port=deinport
__EOF__
{% endhighlight %}

Damit Prosody die Verbindungsdaten akzeptiert und auf dem richtigen Port lauscht, müssen diese Werte noch in die Prosody config eingepflegt werden: `~/.var/lib/prosody/data/prosody.cfg.lua`

Füge über der ersten VHost-Sektion Folgendes, mit deinem Port ein:
```
component_ports = { deinport }
```
und am Ende der Config füge Folgendes, natürlich auch angepasst, hinzu:
```
Component "irc.deinedomain.tld"
         component_secret = "deinpasswort"
```

Starte Prosody jetzt neu, damit die config neu eingelesen wird.

Um biboumi als Service einzurichten, lasse folgenden Befehl laufen:

{% highlight bash %}
space-setup-service biboumi ~/.opt/biboumi/biboumi
{% endhighlight %}
