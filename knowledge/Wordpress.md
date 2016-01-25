---
layout: default
---
## Wordpress

## MySQL

## Installation

Die Installation findet exemplarisch unter der Benutzerdomain statt:

{% highlight bash %}
$ cd $HOME/domains/default
{% endhighlight %}

Dann muss Wordpress heruntergeladen und entpackt werden:

{% highlight bash %}
$ curl http://de.wordpress.org/latest-de_DE.tar.gz | tar -xzf -
{% endhighlight %}

Als nächstes muss der Installationswizard im Browser besucht werden, welcher unter http://$BENUTZERNAME.$HOST.hostedinspace.de/wordpress/ erreichbar ist.

Im Wizard muss nun Wordpress mitgeteilt werden welche MySQL-Daten es verwenden soll:

* Name der Datenbank: Hier muss der Namen der oben erstellten Datenbank hin
* Name des Datenbankbenutzers: Hier muss dein Benutzername hin
* Passwort: Das Passwort findest du in der .my.cnf in deinem Homeverzeichnis
* Datenbank-Host: localhost
* Tabellen-Präfix: wp_

Wenn das geklappt hat, muss man Blogtitel und Zugangsdaten für den Administratorbenutzer wählen.

