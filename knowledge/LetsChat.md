---
layout: default
---
# Let's Chat
[Let's Chat](http://sdelements.github.io/lets-chat/) ist eine [Slack Alternative](https://slack.com/).

## MongoDB installieren
Let's Chat benötigt eine MongoDB Instanz.
Bevor das möglich ist, muss einmal folgendes laufen, damit die Dienste vorbereitet sind:
`space-setup-svscan`

Die MongoDB-Instanz erstellt man nun mit:
`space-setup-mongodb`

Die Ausgabe sollte wie folgt aussehen:

{% highlight bash %}
$ space-setup-mongodb
Creating the ~/mongodb database directory
Creating the ~/etc/run-mongodb/run service run script
Creating the ~/etc/run-mongodb/log/run logging run script 
Symlinking ~/etc/run-mongodb to ~/service/mongodb to start the service
Waiting for the service to start ... 1 2 3 4 started!
Creating administrative user

Congratulations - You can now reach your dedicated MongoDB installation!
Please note that your MongoDB uses the NON-standard port number 21080.
This allows running multiple instances of MongoDB on the same machine for different users.

Hostname: localhost
Portnum#: 21080
Username: username_mongoadmin
Password: iatAnyikDa
{% endhighlight %}

Wichtig ist, sich die letzten vier Zeilen abzuschreiben und aufzubewahren.

Als nächstes muss die aktuelle Let's Chat Version von GitHub runtergeladen werden:  

{% highlight bash %}
mkdir ~/.opt
cd ~/.opt
git clone https://github.com/sdelements/lets-chat.git
cd lets-chat
{% endhighlight %}

Nun müssen zusätzliche Node Pakete installiert werden. Hierzu einfach
`npm install`
eingeben, der Rest passiert von alleine.

Als nächstes muss die Konfigurationsdatei erzeugt und anpasst werden: `cp settings.yml.sample settings.yml`

## Ports öffnen
Bevor die Konfigurationsdatei bearbeitet werden kann, wird noch ein bzw. zwei Ports auf der/denen die App laufen kann benötigt. Einer wird definitiv für die Webanwendung benötigt, der zweite nur, falls XMPP (Jabber) benutzt werden soll.

Hierzu führt man das folgende Kommando aus und merkt sich den Port:
`space-mod-ports open`

Wollt ihr nun ebenfalls XMPP benutzen, braucht ihr noch einen weiteren Port - also nochmal ausführen und wieder merken.

## Konfiguration anpassen
Nun kann die Konfiguration angepasst werden. Dazu mit einem Editor der Wahl die settings.yml öffnen und folgende Zeilen anpassen ($PORTNUMMER1 durch den ersten freigeschalteten Port und $PORTNUMMER2 durch den zweiten ersetzen):

{% highlight bash %}
http:
    enable: true
    host: 'localhost'
    port: $PORTNUMMER1

xmpp:
    enable: true
    port: $PORTNUMMER2
    domain: $DOMAIN
    roomCreation: false
{% endhighlight %}

Zudem muss noch die MongoDB-Verbindung eingerichtet werden.
Hierzu werden die Daten benötigt, die bei der Einrichtung der MongoDB-Instanz angezeigt wurden (Alles was mit $ anfängt, muss ersetzt werden):

{% highlight bash %}
database:
    uri: mongodb://$USERNAME:$PASSWORT@localhost:$PORT/letschat?authSource=admin
{% endhighlight %}

## Installation testen
Nun kann die Installation getestet werden:

{% highlight bash %}
unset NODE_PATH
npm start
{% endhighlight %}

Wenn ihr folgendes seht, hat alles geklappt:

{% highlight bash %}
> lets-chat@0.4.2 prestart /home/simjost/.opt/lets-chat
> migroose


> lets-chat@0.4.2 start /home/simjost/.opt/lets-chat
> node app.js


██╗     ███████╗████████╗███████╗     ██████╗██╗  ██╗ █████╗ ████████╗
██║     ██╔════╝╚══██╔══╝██╔════╝    ██╔════╝██║  ██║██╔══██╗╚══██╔══╝
██║     █████╗     ██║   ███████╗    ██║     ███████║███████║   ██║
██║     ██╔══╝     ██║   ╚════██║    ██║     ██╔══██║██╔══██║   ██║
███████╗███████╗   ██║   ███████║    ╚██████╗██║  ██║██║  ██║   ██║
╚══════╝╚══════╝   ╚═╝   ╚══════╝     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝

Release 0.4.2
{% endhighlight %}

Nun mit Strg+C die App beenden und die Erreichbarkeit aus dem Internet einrichten.

## Als Dienst einrichten
Die App muss als Dienst eingerichtet werden, damit diese automatisch startet.

Dies zuerst:

{% highlight bash %}
space-setup-service letschat npm start ~/.opt/lets-chat 2>&1
{% endhighlight %}

Das Ergebnis sollte wie folgt aussehen:

{% highlight bash %}
Creating the ~/.config/etc/run-letschat/run service run script
Creating the ~/.config/etc/run-letschat/log/run logging run script
Symlinking ~/.config/etc/run-letschat to ~/.config/service/letschat to start the service
Waiting for the service to start ... 1 2 started!

Congratulations - the ~/.config/service/letschat service is now ready to use!
To control your service you'll need the svc command (hint: svc = service control):

To start the service (hint: u = up):
  svc -u ~/.config/service/letschat
To stop the service (hint: d = down):
  svc -d ~/.config/service/letschat
To reload the service (hint: h = HUP):
  svc -h ~/.config/service/letschat
To restart the service (hint: du = down, up):
  svc -du ~/.config/service/letschat

To remove the service:
  cd ~/.config/service/letschat
  rm ~/.config/service/letschat
  svc -dx . log
  rm -rf ~/.config/etc/run-letschat
{% endhighlight %}

Dann weiter:

{% highlight bash %}
$ cat > $HOME/.config/etc/run-letschat/run <<__EOF__
#! /usr/bin/env bash

# These environment variables are sometimes needed by the running daemons
export USER=$USER
export HOME=/home/$USER

. /etc/profile.d/node_version.sh

unset NODE_PATH

# Now let's go!
exec npm start \$HOME/.opt/lets-chat 2>&1
__EOF__
{% endhighlight %}

Damit läuft Let's Chat als Dienst und muss nicht mehr manuell gestartet werden.

## Anbindung an den Webserver
Um Let's Chat auf der Standarddomain zu installieren, musst du im folgenden $PORTNUMMER1 durch den ersten freigeschalteten Port ersetzen:

{% highlight bash %}
$ cat <<__EOF__ >> ~/domains/default/.htaccess
RewriteEngine On
RewriteBase /
RewriteRule ^(.*) http://localhost:$PORTNUMMER1/\$1 [P]
__EOF__
{% endhighlight %}

## Verschlüsselung für XMPP
Zum lets-chat Verzeichnis wechseln:

{% highlight bash %}
$ cd ~/.opt/lets-chat
{% endhighlight %}

Lege den SSL-Key und das SSL-Zertifikat hier ab.

settings.yml mit einem Editor öffnen und der Bereich xmpp um den Unterpunkt tls, wie folgt, erweitern:

{% highlight bash %}
xmpp:
  tls:
    enable: true
    key: server.key
    cert: server.crt
{% endhighlight %}
