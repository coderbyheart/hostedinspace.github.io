---
layout: default
---
# Tor
Das einfachste ist Tor mithilfe von toast zu installieren. Vorher die Versionsnummer unter https://www.torproject.org/download/download.html.en herausfinden (bei Source Code) steht so etwas wie "The current stable version of Tor is 0.2.6.10.". Also wie immer $VERSIONSNUMMER durch die aktuelle Nummer ersetzen:

{% highlight bash %}
toast arm https://www.torproject.org/dist/tor-$VERSIONSNUMMER.tar.gz
{% endhighlight %}

## Port öffnen
Der Port wird wie immer geöffnet mit [space-mod-ports](Anleitungen/Ports-verwalten):
{% highlight bash %}
space-mod-ports open
{% endhighlight %}

Port merken, wird gleich gebraucht.

## Ordner anlegen

{% highlight bash %}
mkdir -p $HOME/.var/lib/tor $HOME/.var/log
{% endhighlight %}

## Konfiguration von Tor

Nun muss eine Konfigurationsdatei angelegt werden:

{% highlight bash %}
cat > $HOME/.torrc <<__EOF__
SocksPort 0
Log notice file $HOME/.var/log/tor.log
DataDirectory $HOME/.var/lib/tor
ControlPort 9051
CookieAuthentication 1
ORPort 61058
Nickname Debianer
RelayBandwidthRate 100 KB
RelayBandwidthBurst 200 KB
AccountingMax 10 GB
AccountingStart month 1 02:00
ContactInfo Mail 
DirPort 64671
ExitPolicy reject *:*
DisableDebuggerAttachment 0
AvoidDiskWrites 1
__EOF__
{% endhighlight %}

## Tor-Relay testen
Zum testen, kann man Tor manuell starten:

{% highlight bash %}
tor -f .torrc
{% endhighlight %}

## Service unter den Daemontools
Am sinnvollsten ist es Tor mithilfe von Daemontools laufen zu lassen, da Tor dann neugestartet wird, falls es sich unerwartet beendet.

Zunächst wird getestet, ob die Daemontools für dich schon eingerichtet sind und holen das sonst nach:
{% highlight bash %}
test -d $HOME/.config/service || space-setup-svscan
{% endhighlight %}

Nun das Verzeichnis für den Dienst anlegen:

{% highlight bash %}
mkdir -p $HOME/.config/etc/run-tor
{% endhighlight %}

Nun wird das Script erstellt, welches Tor startet:

{% highlight bash %}
cat <<__EOF__ > $HOME/.config/etc/run-tor/run
#! /usr/bin/env bash

# These environment variables are sometimes needed by the running daemons
export USER=$USER
export HOME=/home/$USER

exec \$HOME/.toast/armed/bin/tor -f \$HOME/.torrc 2>&1
__EOF__
{% endhighlight %}

Das Script ausführbar machen:

{% highlight bash %}
chmod +x $HOME/.config/etc/run-tor/run
{% endhighlight %}

Und zu guter Letzt dafür sorgen, dass Daemontools den Dienst auch kennt:

{% highlight bash %}
ln -s $HOME/.config/etc/run-tor $HOME/.config/service/tor
{% endhighlight %}

## Updaten von Tor (Service unter den Daemontools)

Zunächst Tor stoppen:
{% highlight bash %}
svc -d $HOME/.config/service/tor
{% endhighlight %}

Dann die neue Version installieren (wie immer $VERSIONSNUMMER durch die aktuelle Versionsnummer ersetzen:

{% highlight bash %}
toast arm https://www.torproject.org/dist/tor-$VERSIONSNUMMER.tar.gz
{% endhighlight %}

Dann kann Tor wieder gestartet werden:

{% highlight bash %}
svc -u $HOME/.config/service/tor
{% endhighlight %}

## Tor-Arm zur Überwachung des Tor-Relays

{% highlight bash %}
cd .var/tmp
wget --no-check-certificate http://www.atagar.com/arm/resources/static/arm-1.4.5.0.tar.bz2
tar xfv arm-1.4.5.0.tar.bz2
cd arm
mkdir -p $HOME/.opt/tor-arm
cp -R src/* $HOME/.opt/tor-arm/
cp arm $HOME/.local/bin/
cd ~
rm -rf $HOME/.var/tmp/torarm
rm $HOME/.opt/tor-arm/uninstall
{% endhighlight %}

In der Datei $HOME/.local/bin/arm muss noch der Pfad zu den Programmdateien angepasst werden:

{% highlight bash %}
$ nano $HOME/.local/bin/arm

if [ "$0" = /home/$USER/.local/bin/arm ]; then
  arm_base=/home/$USER/.opt/tor-arm/
{% endhighlight %}
