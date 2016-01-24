---
layout: default
---
# Bitlbee

> BitlBee ist ein Instant-Messaging-Client. Anders als herkömmliche Clients ist BitlBee jedoch ein Netzwerk-Gateway, der sich dem Benutzer als IRC-Server ausgibt und die Protokolle AIM, ICQ, Yahoo! Messenger, XMPP und MSN kennt. Nach außen hin verhält sich BitlBee wie jeder andere Instant Messenger, doch die Bedienung ist entscheidend anders: Der Benutzer nutzt für die Kommunikation einen gewöhnlichen IRC-Client. Über den BitlBee-Server kann er zu den diversen Instant-Messaging-Netzwerken verbinden. Das Benutzerprofil kann auf dem Server permanent gespeichert werden. Der Vorteil dieses Modells ist, dass jeder beliebige IRC-Client für Instant Messaging genutzt werden kann.

Quelle: [Wikipedia](https://de.wikipedia.org/wiki/BitlBee)

## Installation

Um Bitlbee zu verwenden sind mehrere Schritte notwendig.

### Vorarbeiten

#### OpenSSL kompilieren

Damit der Client eine aktuelle OpenSSL-Bibliothek benutzt, bauen wir diese mit toast:

{% highlight bash %}
toast arm https://www.openssl.org/source/openssl-1.0.1p.tar.gz
{% endhighlight %}

#### OTR unterstüzung mit libpurple

Man kann Bitlbee mit den integrierten Plugins für die verschiedenen Netzwerke benutzen, aber die Plugins von Pidgin funktionieren besser. Deshalb sollte libpurple verwendet werden, die nun mit folgendem Befehl kompiliert werden kann.

{% highlight bash %}
toast --makeappend="-C libpurple" --confappend="--disable-gnutls --enable-cyrus-sasl --disable-nls --disable-gtkui --disable-consoleui --disable-screensaver --disable-sm --disable-startup-notification --disable-gtkspell --disable-gestures --disable-schemas-install --disable-gstreamer --disable-gstreamer-interfaces --disable-farstream --disable-vv --disable-meanwhile --disable-avahi --disable-dbus --disable-perl --disable-tcl --disable-tk --without-x --disable-doxygen --with-system-ssl-certs=/etc/ssl/certs" arm http://downloads.sourceforge.net/project/pidgin/Pidgin/2.10.11/pidgin-2.10.11.tar.bz2
{% endhighlight %}

Außerdem brauchen wir noch die libotr. Zunächst kompilieren wie die Abhängigkeiten, um anschließend libotr zu kompilieren.

##### libgpg-error

{% highlight bash %}
wget ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.19.tar.bz2
toast arm libgpg-error-1.19.tar.bz2
{% endhighlight %}

##### libgcrypt

{% highlight bash %}
wget ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.3.tar.bz2
toast arm libgcrypt-1.6.3.tar.bz2
{% endhighlight %}

##### libotr

{% highlight bash %}
toast arm https://otr.cypherpunks.ca/libotr-4.1.0.tar.gz
{% endhighlight %}

### Bitlbee installieren

Nun kann bitlbee mit folgendem Befehl installiert werden.

{% highlight bash %}
toast --confappend="--asan=1 --purple=1 --otr=1 --ssl=openssl" arm http://get.bitlbee.org/src/bitlbee-3.4.1.tar.gz
{% endhighlight %}

## Konfiguration

Damit wir Bitlbee betreiben können muss noch ein wenig Konfiguration erledigt werden. Wir richten eine Portfreigabe und bitlbee als Dienst (Deamon) ein.

### Portfreigabe einrichten

Mit dem space-mod-ports können Ports freigegeben werden. Durch den Aufruf von nachfolgendem Befehl wird der nächstmögliche Port freigeschaltet und ausgegeben. Diesen müssen wir uns merken.

{% highlight bash %}
space-mod-ports open
{% endhighlight %}

## Dienst einrichten

Wir möchten Bitlbee als Dienst (Deamon) betreiben. Dazu nutzen wir den space-setup-service.

{% highlight bash %}
space-setup-service bitlbee $HOME/.toast/armed/bin/bitlbee
{% endhighlight %}

Das generierte run-script müssen wir dann noch anpassen. $PORTNUMMER durch den Port, der im Abschnitt *Portfreigabe einrichten* freigegeben wurde ersetzt werden, z.B. 61010.

{% highlight bash %}
$ cat > $HOME/.config/etc/run-bitlbee/run <<__EOF__
#! /usr/bin/env bash

# These environment variables are sometimes needed by the running daemons
export USER=$USER
export HOME=/home/$USER

. /etc/profile.d/toast_path.sh

# Now let's go!
exec \$HOME/.toast/armed/bin/bitlbee -D -p $PORTNUMMER -n 2>&1
__EOF__
{% endhighlight %}
