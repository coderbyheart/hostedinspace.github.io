---
layout: default
---
# ngircd

{% highlight bash %}
$ toast arm ngircd
{% endhighlight %}

## Einstellungen
Nun richten wie die Konfiguratinsdateien ein.

{% highlight bash %}
$ ln -s ~/.toast/pkg/ngircd/v19.1/1/root/etc ~/ngircd
$ cd ngircd
$ cp ngircd.conf ngircd.org.conf
$ chmod 444 ngircd.org.conf
{% endhighlight %}

Dies erstellt einen symbolischen Link ngircd in euer Homeverzeichnis und erstellt eine nicht beschreibbare Kopie der Standardkonfigurationsdatei. Nun müsst ihr an der eigentlichen Konfigurationsdatei noch einige Einstellungen vornehmen. Benutzt dafür einen Terminaleditor euerer Wahl wie zum Beispiel vim oder nano.

{% highlight bash %}
$ nano ngircd.conf

[Global]
    Name = irc.{username}.{server}.ubserspace.de
    Info = Info Text
    # Globales Serverpasswort. Das ; am Anfang entfernen um es zu aktivieren
    ;Password = {password}

    # Information about the server and the administrator, used by the
    # ADMIN command. Not required by server but by RFC!
    AdminInfo1 = Description
    AdminInfo2 = Location
    AdminEMail = admin@irc.server

    # Bitte einen anderen als den Standard '6667' verwenden
    Ports = {port}

    MotdFile = /home/{username}/ngircd/ngircd.motd

    ServerUID = {username}
    ServerGID = {username}

[Operator]
    Name = {name}
    Password = {password}
Ihr müsst die Werte in den geschweiften Klammern natürlich mit euren Werten ersetzen (ohne Klammern dann). Wenn ihr wollt könnt ihr dann noch einige permanente Channels einrichten. Die Konfiguration dafür sieht so aus:

# ein passwortgeschützter Channel
[Channel]
    Name = #protected
    Topic = a closed channel
    Modes = tnPk
    Key = password

# ein offener Channel
[Channel]
    Name = #open
    Topic = an open channel
    Modes = tnP
{% endhighlight %}

Aus nano kommt ihr mit ^x wieder raus, dann zum speichern bestätigen und fertig.

Jetzt noch eine "Message of the Day" Datei anlegen

{% highlight bash %}
$ echo "Willkommen auf meinem IRC Server!" > ngircd.motd
{% endhighlight %}

## Test
Jetzt testen wir die Konfiguration. Das geht mit

{% highlight bash %}
$ ngircd -t
{% endhighlight %}
Dabei sollten keine Fehler auftreten, wenn doch, nochmal genau die Konfigdatei anschauen! Jetzt testen wir ob der Server überhaupt funktioniert und starten ihn dafür im Vordergrund:

## Einen Service aufsetzen
Damit der Server auch nach einem crash oder einer downtime wieder automatisch angeht, verwenden wir ihn als Service. Uberspace.de hat dafür deamontools installiert. Falls noch nicht geschehen einfach ein eigenes ~/service Verzeichnis mit dem mitgelieferten Skript erstellen

{% highlight bash %}
$ space-setup-svscan
{% endhighlight %}

und dann einen einen ngircd Service einrichten

{% highlight bash %}
$ space-setup-service ngircd "ngircd -n"
{% endhighlight %}

Nun müsst ihr noch ein Portforwarding bei den Leuten von uberspace.de beantragen und fertig :)

