---
layout: default
---
# mosh

> Mosh (mobile shell) ist ein Computerprogramm, welches benutzt wird, um lokal eine entfernte Kommandozeile verfügbar zu machen. Mosh ähnelt SSH, hat aber weitere Funktionalitäten, um die Verwendung für mobile Nutzer zu verbessern. Die Hauptfunktionen sind:
>
> * Mosh hält die Verbindung aufrecht, auch wenn der Benutzer "roamt" und eine andere IP-Adresse erhält, beispielsweise wenn der Benutzer eines WLAN in ein anderes WLAN wechselt oder von WLAN zu UMTS wechselt.
> * Mosh hält die Verbindung offen, wenn ein Benutzer die Internetverbindung verliert oder stellt den Client in einen "Schlafmodus". SSH kann seine Verbindung verlieren, da TCP Pakete verwirft, wenn der Sender nach einer bestimmten Zeit (Timeout) keine Bestätigung erhält.
> * Mosh versucht dem Benutzer sofort zu zeigen, welche Tasten er getippt hat und welche Buchstaben und Wörter er gelöscht hat, um die Latenz auszugleichen.
>
> Die Hauptnachteile von Mosh sind, dass es zusätzliche Anforderungen an den Server stellt und manche Zusatzfunktionen von SSH nicht verwendet werden können.

Quelle: [Wikipedia/Mosh (Software)](https://de.wikipedia.org/wiki/Mosh_%28Software%29)

## Kurzerklärung
mosh baut auf SSH auf und möchte mehr Komfort bieten. Der Verbindungsaufbau wird weiterhin über SSH im Hintergrund erledigt. Dort wird ein Session-Key und ein Port ausgehandelt, danach verbindet sich der mosh-Client auf den Port.

Da SSH verwendet wird, muss auch ein private Key schon in SSH hinterlegt oder das Passwort für den Nutzer bekannt sein.

Ist die Verbindung über mosh aufgebaut, hat man folgende Vorteile:

  * reagiert der Server mal nicht sofort, friert nicht das Fenster ein, sondern alle Eingaben, welche noch nicht übertragen wurden, werden unterstrichen angezeigt und man kann normal weiterschreiben
  * mosh hält die Verbindung oder baut sie wieder auf auch bei zwischenzeitlicher Unterbrechung, z.B. wenn ...
    * ... man seinen Computer für eine Zeit im Standby-Modus hatte
    * ... sich der eigene Uplink oder die IP geändert hat


## Installation
Die Installation übernimmt das Skript *space-setup-mosh*.

Dieses Skript lädt den Source-Code von mosh herunter und kompiliert die ausführbaren Dateien. mosh liegt dann im Ordner ~/.opt/mosh mit den Binaries im Unterordner bin.

Der Vorgang dauert knapp 5 Minuten.

Um mosh nach der Installation zu nutzen zu können, wird noch ein freier Port benötigt. Dies wird erledigt mit *[space-mod-ports open](https://wiki.hostedinspace.de/Skripte/space-mod-ports#space-mod-ports_open)*.

## Nutzung
mosh wird genauso genutzt wir mosh. Der Verbindung unterscheidet sich generell nur dadurch, dass *mosh*, statt *ssh* als Befehl genutzt wird. Um mosh zu zwingen den vorher geöffneten Port zu verwenden, wird noch *-p PORTNUMMER* an den Befehl angefügt:

{% highlight bash %}
mosh -p PORTNUMMER NUTZER@andromeda.hostedinspace.de
{% endhighlight %}
