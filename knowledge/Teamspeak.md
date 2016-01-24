---
layout: default
---
# Teamspeak Server

## Ports

## Installation

Herunterladen des Archivs:
```
wget http://dl.4players.de/ts/releases/3.0.10/teamspeak3-server_linux-amd64-3.0.10.tar.gz
```

Entpacken des Archivs:
```
tar xvfz teamspeak3-server_linux-amd64-3.0.10.tar.gz
```

Ein Teamspeak Server benötigt eine Lizenz, welche ihr kostenfrei bekommt, wenn ihr eine E-Mail-Adresse mit der gleichen Domain wie eure Webseite besitzt. Die Webseite muss nicht-kommerziell sein, darf weder Werbung noch Spendenbutton besitzen. Nachdem ihr diese unter http://npl.teamspeakusa.com/ts3npl.php beantragt habt, kommt diese in der Regel nach ca. einem Tag via E-Mail.

Die Lizenzdatei, die einem per E-Mail zugeschickt wurde muss in den Order des Teamspeak Servers.

Nun wird der Server das erste Mal gestartet und spuckt dabei einige Daten aus:
```
./ts3server_minimal_runscript.sh
```

In der Ausgabe findet sich das Passwort des Adminbenutzers und der Token. Diese sorgsam wegspeichern, da sie später gebraucht werden.

Da keine Standardports verwendet werden können, sondern die oben freigeschalteten, müssen diese noch konfiguriert werden:

Hierfür müssen wir die Datei ts3server.ini bearbeiten. Da diese standardmäßig nicht existiert, müssen wir sie zunächst erstellen:
```
./ts3server_linux_amd64 createinifile=1
```

Danach muss diese Datei mit einem Editor bearbeitet werden:
```
$EDITOR ts3server.ini
```

Hier müssen nun die Optionen default_voice_port, filetransfer_port und query_port angepasst werden.

Nun kann der Server gestartet werden:
```
./ts3server_startscript.sh start inifile=ts3server.ini
```

Nun muss noch vom Standardserver der Port angepasst werden. Hierfür verbindet man sich per Telnet mit dem query_port:
```
telnet localhost $PORTNUMMER
```

Login mit den oben gemerkten Daten:
```
login serveradmin PASSWORT
```

Und ändert den Port:
```
use sid=1
serveredit virtualserver_port=UDP PORT
serverstop sid=1
serverstart sid=1
```

Um im Client Adminrechte zu erhalten, verwendet man den oben ebenfalls gemerkten Token.

