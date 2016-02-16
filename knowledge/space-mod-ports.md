---
layout: default
---
# Ports verwalten

## Beschreibung
Mit _space-mod-ports_ kann ein/e Benutzer*in auch ohne root-Rechte Ports öffnen.
Das Script beginnt dabei bei Port 61009 und inkremetiert dann. Man kann also keinen
speziellen auswählen, sondern es wird immer der nächst Beste geöffnet.
Der erste Aufruf öffnet 61009, der zweite 61010, etc.

## Parameter
* **help**: Zeigt die Hilfe an
* **open**: Öffnet den nächsten Port
* **rm _port_**: Schließt den übergebenen Port
* **list**: Listet alle offenen Ports auf
