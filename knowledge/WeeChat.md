---
layout: default
---
# Weechat

>WeeChat (**W**ee **E**nhanced **E**nvironment for **Chat**) ist ein freier IRC-Client ohne grafische Benutzeroberfläche, stattdessen wird eine auf curses basierende zeichenorientierte Benutzerschnittstelle verwendet. Die erste Version (0.0.1) erschien am 27. September 2003.
>
>Aufgrund des modularen Aufbaus ist WeeChat durch Skripte und zahlreich verfügbare Plugins in seiner Funktionalität erweiterbar

Quelle: [Wikipedia/WeeChat](https://de.wikipedia.org/wiki/WeeChat)

## Installation

### Ein SSL Relay anlegen

#### Im Terminal

Das Verzeichnis _.weechat/ssl_ angelegt werden:

`mkdir .weechat/ssl`

SSL Schlüssel erzeugen:

`openssl req -nodes -newkey rsa:4096 -keyout relay.pem -x509 -days 365 -out ~/.weechat/ssl/relay.pem`

Mit [[space-mod-ports|Anleitungen/Ports-verwalten]] einen Port öffnen, der geöffnete Port wird nach dem Aufruf ausgegeben.

`space-mod-ports open`

#### In weechat

Relay SSL-Schlüssel setzten. Mit folgendem Befehl such weechat automatisch im Verzeichnißs *ssl* nach der Datei *relay.pem* und lädt diese.

`/relay sslcertkey`

Abschließen mit dem freigegebenen Port ein Relay anlegen. Wichtig ist das ssl.-Prefix, sonst kommt später keien Verbindung zu stande.

`/relay add ssl.weechat PORTNUMMER`


Wenn keine Verbindung zu stande kommt und man in der *relay.list* Einträge wie die folgenden sieht, hat man das *ssl.*  vergessen:

```
[connected           ] 5/weechat/2001:bf7:540:0:c844:fdfd:b629:af0e, received: 78 bytes, sent: 0 bytes
                       started on: Fri, 31 Jul 2015 22:10:56, ended on: - 
[connected           ] 4/weechat/2001:bf7:540:0:c844:fdfd:b629:af0e, received: 184 bytes, sent: 0 bytes
                       started on: Fri, 31 Jul 2015 22:10:27, ended on: -  
[connected           ] 3/weechat/2001:bf7:540:0:c844:fdfd:b629:af0e, received: 184 bytes, sent: 0 bytes
```

# Tipps und Tricks

## Backlog beim Start in Buffer laden
Standardmäßig werden 20 Zeilen des Backlogs beim Start von weechat in die Buffer geladen. Die Einstellung `backlog` findet man in der `logger.conf` im Ordner `.weechat`.  
Der Maximalwert ist `2147483647`.

## Weechat automatisch starten
Dazu kann man einfach einen cronjob anlegen. Man öffnet den User-Crontag mit `crontab -e` und fügt folgenden Eintrag hinzu.

```
@reboot screen -d -m /usr/bin/weechat
```
