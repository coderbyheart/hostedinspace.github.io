---
layout: default
---
# PHP

Bei Hosted in Space ist natürlich PHP verfügbar.

Hierbei wird pro Benutzer ein eigener PHP-Interpreter gestartet, welcher per FastCGI an Apache angebunden ist.

## Pfad zum PHP-Interpreter

Nach der Einrichtung deines Benutzers funktioniert PHP automatisch und arbeitet mit der aktuellsten Version der 5er-Serie.
Die verschiedenen PHP-Interpreter liegen unter */opt*; mit _ls -ld /opt/php-*_ kannst du
nachschauen, welche konkreten Versionen verfügbar sind. So könnte das exemplarisch aussehen:

{% highlight bash %}
benutzername@andromeda ~ % ls -ld ls -ld /opt/php-*
lrwxrwxrwx  1 root root    7 Feb 26 14:29 /opt/php-5 -> php-5.6
lrwxrwxrwx  1 root root   10 Feb 12 13:25 /opt/php-5.5 -> php-5.5.32
drwxr-xr-x 11 root root 4096 Feb 21 20:15 /opt/php-5.5.32
lrwxrwxrwx  1 root root   10 Feb 12 13:25 /opt/php-5.6 -> php-5.6.18
drwxr-xr-x 11 root root 4096 Feb 12 12:48 /opt/php-5.6.18
lrwxrwxrwx  1 root root    7 Feb 26 14:29 /opt/php-7 -> php-7.0
lrwxrwxrwx  1 root root    9 Feb 12 13:25 /opt/php-7.0 -> php-7.0.3
drwxr-xr-x 11 root root 4096 Feb 26 14:29 /opt/php-7.0.3
{% endhighlight %}

Was du hier siehst, ist ein mehrstufiges System von Symlinks.
Die physischen Verzeichnisse tragen jeweils die vollständige Versionsnummer der PHP-Installation.
Mit Symlinks sind dann generischere Versionsangaben zurückgebaut.

Konkret bedeutet das: *php-5* ist die jeweils aktuellste Version in der aktuellsten Kompilierung der PHP-5-Serie.
*php-5.6* ist das aktuellste PHP 5.6 und wird auch immer eins bleiben.
*php-5.6.16* bleibt immer PHP 5.6.16, auch wenn auf 5.6.17 oder 5.6.20 geupgradet wird.

Hintergrund ist, dass es zwischen PHP-Versionen oft - manchmal nur minimale - Inkompatibilitäten gibt,
die dafür sorgen, dass manche Dinge nicht richtig funktionieren. So gibt es auch heute noch einige Applikationen,
die so spezifische Bugs beinhalten, dass sie nur mit PHP 5.5 korrekt ausführbar sind,
während sie unter PHP 5.6 nicht richtig laufen. Mit diesem Schema hast du die Möglichkeit,
unabhängig davon, was gerade aktuell ist, eine ganz bestimmte PHP-Version für deinen Benutzer festzupinnen
und für alle Zeit dabei zu bleiben (auch wenn ohne Frage sinnvoller wäre, keine Software einzusetzen,
die zwangsweise auf älteren PHP-Versionen besteht).

## PHP-Version einstellen

In deinem Homedir (/home/benutzername) gibt es im Ordner .config/etc eine Datei namens *phpversion*,
in der die Variable *PHPVERSION* gesetzt wird:

{% highlight bash %}
benutzername@andromeda ~ % cat ~/.config/etc/phpversion
## 2016-02-26
PHPVERSION=7.0
{% endhighlight %}

Hier kannst du die Versionsnummer deiner Wahl eintragen - wähle einfach eine der Versionen,
die in _/opt/php-*_ vorliegen.

Hierbei ist es empfehlenswert eine Minor-Version zu wählen,
also z.B. *PHPVERSION=5.6*. Das hat den Vorteil, dass du Bugfix-Releases
ohne Zutun bekommst und immer auf dem aktuellen Stand bist.

Nach dieser Änderung musst du deinen Interpreter [neu starten](#php-interpreter-neu-starten). Das war's!

Wenn du den PHP-Interpreter auch direkt auf der Shell benutzt,
musst du dich einmal aus- und wieder einloggen, damit die neue Version aktiv wird.

Damit du den Zusammenhang verstehst: PHP wird über das Script *php-fcgi-starter* gestartet,
welches in deinem Homedir in dem Verzeichnis *fcgi-bin* liegt. Dieses Script bindet die *~/.config/etc/phpversion* ein.
So sieht das aus:

{% highlight bash %}
benutzername@andromeda ~ % cat ~/fcgi-bin/php-fcgi-starter
#! /usr/bin/env sh

export USER=benutzername
export HOME=/home/benutzername
. /etc/profile.d/php_version.sh

PHP_FCGI_CHILDREN=0
export PHP_FCGI_CHILDREN
PHP_FCGI_MAX_REQUESTS=250
export PHP_FCGI_MAX_REQUESTS
exec php-cgi
{% endhighlight %}

Die Zentralisierung der PHP-Version in der separaten Datei hat den Vorteil,
dass diese via */etc/profile.d/php_version.sh* dergestalt eingebunden wird,
dass sie nicht nur für deine Website gilt, sondern auch auf der Shell,
wenn du einfach nur *php* ohne Angabe eines konkreten Pfads aufrufst.


## Eigene php.ini

Die *php.ini* entspricht weitestgehend der *php.ini-recommended* bzw.
*php.ini-production*, die das PHP-Entwicklungsteam vorschlägt,
ergänzt um die Angabe der lokalen Zeitzone, die ab PHP 5.3 erforderlich ist.
Die *php.ini* liegt dabei im Verzeichnis *lib* des von dir gewählten PHP-Interpreters.
Mittels *php --ini* kannst du dir den vollständigen Pfad anzeigen lassen. So sieht das aus:

{% highlight bash %}
benutzername@andromeda ~ % php --ini
phpConfiguration File (php.ini) Path: /opt/php-7.0.3/etc
Loaded Configuration File:         /opt/php-7.0.3/etc/php.ini
Scan for additional .ini files in: /opt/php-7.0.3/etc/conf.d
Additional .ini files parsed:      /opt/php-7.0.3/etc/conf.d/xdebug.ini
{% endhighlight %}

Nach Änderungen musst du deinen PHP-Interpreter [neu starten](#php-interpreter-neu-starten), damit jene übernommen werden.

## PHP-Interpreter neu starten

Dein PHP-Interpreter wird bei einem Webserver-Restart beendet, außerdem nach längerer Inaktivität
(wenn also über längere Zeit kein PHP-Script aufgerufen wird).
Nach Änderungen am *php-fcgi-starter* oder dem Anlegen oder Ändern einer eigenen php.ini
musst du aber eventuell noch laufende PHP-Interpreter beenden, damit beim nächsten Aufruf
einer PHP-Seite die gewünschten Änderungen zum Tragen kommen.
Das geht am einfachsten so:

{% highlight bash %}
benutzername@andromeda ~ % killall php-cgi
{% endhighlight %}

Eine Meldung *php-cgi: Kein Prozess abgebrochen* stellt kein Problem dar: Sie signalisiert einfach nur,
dass ohnehin kein PHP-Prozess unter deiner User-ID läuft, der abgebrochen werden könnte.

Der Neustart deines PHP-Interpreters erfolgt dann automatisch beim nächsten Aufruf einer PHP-Seite.

## Eigene PEAR-Module installieren

Viele größere PHP-Applikationen benötigen eine ganze Reihe an Modulen aus dem PEAR-Repository.

Du kannst dir problemlos eigene PEAR-Module innerhalb deines Benutzers installieren.

Um dir die Benutzung des Kommandozeilentool *pear* zu erleichtern gibt es ein Script namens *space-mod-pear*.

Diese hat die drei Kommandos *add*, *list* und *rm*.

Mit add fügst du Module hinzu, mit rm entfernst du diese und mit list lässt du dir anzeigen, welche
Module installiert sind.

Dies ist mal ein __exemplarischer__ Aufruf am Beispiel des PEAR-Moduls *Mail_Mime*
(du musst diesen Schritt natürlich nicht nachvollziehen, ist ja nur ein Beispiel):

{% highlight bash %}
benutzername@andromeda ~ % space-mod-pear add Mail_Mime
downloading Mail_Mime-1.8.1.tgz ...
Starting to download Mail_Mime-1.8.1.tgz (31,530 bytes)
........done: 31,530 bytes
install ok: channel://pear.php.net/Mail_Mime-1.8.1
{% endhighlight %}

## Eigene PECL-Module installieren

Analog zu *space-mod-pear* gibt es *space-mod-pecl*, welches sich um die De-/Installation von PECL-Modulen kümmmert:

Hier ein Beispiel:

{% highlight bash %}
benutzername@andromeda ~ % space-mod-pecl add intl
downloading intl-3.0.0.tgz ...
Starting to download intl-3.0.0.tgz (248,200 bytes)
.................done: 248,200 bytes
150 source files, building
running: phpize
Configuring for:
PHP Api Version:         20131106
Zend Module Api No:      20131226
Zend Extension Api No:   220131226
...
{% endhighlight %}

## Interpreter nicht vergessen

Vergiss dabei bitte nicht, dass bei Skriptsprachen, wie PHP, Perl oder Python,
der jeweilige Interpreter voranzustellen ist. Skripte sind keine ausführbaren Binaries,
sondern müssen interpretiert werden, Du musst sie daher __immer__ mit Angabe des Interpreters aufrufen,
egal ob auf der Shell oder in einer Crontab.
Das heißt, in einer Crontab müsste der Aufruf zum Beispiel so aussehen:

{% highlight bash %}
*/5 * * * * php /home/benutzername/deinscript.php
{% endhighlight %}

Der Interpreter ist in diesem Fall das Programm *php*.

## Bekannte Probleme mit PHP 7

### imagick

Das PECL-Modul [imagick](https://pecl.php.net/package/imagick) ist in seiner
aktuellen Version 3.3.0 noch nicht mit PHP 7 kompatibel.
Bitte warte mit dem Umstieg auf PHP 7 ab, bis eine stabile Version von *imagick* erschienen ist,
wenn du dieses Modul nutzen willst. Möchtest du unbedingt schon mit der Beta-Version des Moduls arbeiten,
kannst du jene wie folgt installieren:

{% highlight bash %}
benutzername@andromeda ~ % space-mod-pecl add https://pecl.php.net/get/imagick-3.4.0RC2.tgz
{% endhighlight %}

### redis

Das PECL-Modul [redis](https://pecl.php.net/package/redis) ist in seiner
aktuellen Version 2.2.7 noch nicht mit PHP 7 kompatibel. Bitte warte mit dem Umstieg auf PHP 7 ab,
bis eine stabile Version von *redis* erschienen ist, wenn du dieses Modul nutzen willst.
Möchtest du unbedingt schon mit der Beta-Version des Moduls arbeiten,
kannst der
[redis-Installationsanleitung](https://niebegeg.net/post/php7-redis-im-uberspace/) von Dirk Rüdiger folgen,
die via git den *php7*-Branch aus dem Repo des Moduls auscheckt.
