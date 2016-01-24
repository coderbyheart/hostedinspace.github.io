# owncloud

[ownCloud](http://owncloud.org/) ist eine freie Software, mit der persönliche Daten wie eigene Dokumente, Kalender- und Kontaktdaten sowie Musik auf einem Server gespeichert und so z.B. mit dem eigenen Rechner, Tablet oder einem Smartphone synchronisiert werden können. Wer all diese Daten nicht Google, Dropbox oder anderen Anbietern mit werbefinanziertem Geschäftsmodell anvertrauen möchte, der kann mit OwnCloud seine eigene kleine Cloud betreiben. 

Im folgenden umreißen wir kurz zwei Installationsmethoden und weitere Möglichkeiten mit Owncloud.

## ownCloud installieren

Du kannst den [[http://owncloud.org/install/#webInstallerModal|ownCloud Web Installer]] verwenden, und zwar exakt so wie dort beschrieben. Du kannst maximal den ersten und den zweiten Schritt noch optimieren, indem Du das auf der Shell direkt in Deinen Uberspace runterlädst, statt den Umweg über Deinen Rechner zu machen.

## ownCloud im DocumentRoot

Am einfachsten ist die Installation in deinen DocumentRoot:

<code bash>
cd /var/www/virtual/$USER/html
wget https://download.owncloud.com/download/community/setup-owncloud.php
</code>

## ownCloud unter einer Subdomain

Du kannst ownCloud auch [[domain:subdomain#extra_ordner|unter einer Subdomain]] betreiben, dafür brauchst Du dann die Config-Direktive ''RewriteBase /'' in der .htaccess-Datei von ownCloud. 

<code bash>
cd /var/www/virtual/$USER/<SubDomain>
echo "RewriteBase /" > .htaccess
wget https://download.owncloud.com/download/community/setup-owncloud.php
</code>

## Einrichten von ownCloud

Um die Einrichtung zu beginnen, rufe ...

<code bash>
https://<username>.<servername>.uberspace.de/setup-owncloud.php
</code>

... (oder eben die entsprechende Subdomain) in deinem Browser auf. Wenn du Owncloud in den DocumentRoot (also nicht unter ''/owncloud'') installieren möchtest, kannst du als Zielordner einfach ''.'' angeben. Mit einem Klick auf ''next'' sollte der Installer dir Bescheid geben, dass die Installation erfolgreich war.

Wenn Du im nächsten Schritt Deinen Admin-Account anlegst, hast Du auch Gelegenheit noch andere Dinge einzurichten, wenn Du auf ''Storage & database'' klickst:

  * Du kannst festlegen wo ownCloud Deine Daten ablegt (es ist eine gute Idee, das aus dem DocumentRoot des Webservers rauszubewegen, etwa nach ''/home/$USER/ocdata/'' oder etwas in der Art).
  * Du kannst festlegen ob ownCloud eine [[database:sqlite|SQLite]]-, [[database:mysql|MySQL]]- oder [[database:postgresql|PostgreSQL]]-Datenbank nutzen soll (es empfiehlt sich wohl MySQL oder PostgreSQL zu nehmen). 

## Updates

<note important>Wie die Erfahrung zeigt, hat ownCloud häufiger Sicherheitslücken und sollte dann zügig mit Updates versorgt werden. Einige User berichten uns, dass ownCloud nicht prominent auf Updates hinweist und empfehlen, sich auf der [[http://mailman.owncloud.org/mailman/listinfo/announcements|Mailingliste für Update-Ankündigungen]] einzutragen. In Deinem eigenen Interesse solltest Du da jetzt an dieser Stelle drüber nachdenken.</note>

Um Probleme zu vermeiden, solltest du Owncloud nur [[https://doc.owncloud.org/server/8.2/admin_manual/maintenance/manual_upgrade.html|manuell im Maintenance Modus]] updaten. Im Falle des Falles hilft unser [[system:backup|tägliches Backup]].

===== externen Storage einbinden =====

Bei uns ist der Speicherplatz auf 10 GB begrenzt und [[:faq#plattenplatz_--_koennt_ihr_mir_nicht_doch_mehr_als_10_gb_geben|daran ist nichts zu rütteln]]. Du kannst mit owncloud aber externen Storage einbinden.

Wechsle dazu in das Apps-Panel von ownCloud und installiere die App ''External Storage Support''. Wechsle anschließend ins Admin-Panel. Dort findest Du nun einen neuen Bereich um die External Storage Support App zu konfigurieren. Wir geben zwei Beispiele, die wir direkt testen konnten:

## SFTP

Um externen Speicher per SFTP einzubinden brauchst Du nichts weiter als Deine SFTP-Zugangsdaten. Bei ''URL'' musst Du den Servernamen eintragen, z.B. ''sftp.example.com'', bei ''Username'' und ''Password'' Deine Zugangsdaten. Der einzige Punkt der ein bißchen kompliziert sein könnte ist die Einstellung ''Root'' -- da haben wir auch erstmal gerätselt was das sein soll. Da soll aber offenbar der Pfad zu dem Verzeichnis angegeben werden, unter dem die Daten abgelegt werden sollen, wir empfehlen einen absoluten Pfad, also z.B. ''/home/nicole/owncloud-ext''.

<note>Wir haben verschiedentlich beobachtet und gehört, dass das Ampel-Symbol das anzeigen soll ob diese Einbindung eines externen Speichers funktioniert bei SFTP bisweilen immer rot bleibt, obwohl der Zugriff funktioniert.</note>

==== ownCloud / WebDAV ====

Du kannst externen Speicher auch per DAV einbinden (darüber kannst Du sogar eine weitere ownCloud-Installation ansprechen). Hier musst Du bei ''URL'' die volle URL zu deiner DAV-Installation angeben (bei ownCloud findest Du ein Beispiel für diese URL in dem Panel für Deine Account-Einstellungen), also z.B. ''https://dav.example.com/nicole/'' oder ''https://dav.example.com/owncloud/remote.php/webdav/''. Bei ''Username'' und ''Password'' musst Du wieder Deine Zugangsdaten angeben. ''Root'' konnten wir hier einfach leer lassen (dann landen die Daten auf der obersten Verzeichnisebene die diese DAV-Installation anbietet), es kann aber je nach Implementation auch sein, dass Du hier wieder eine Pfadangabe brauchst -- oder haben möchtest, damit alles in einem bestimmten Unterordner landet.

Bei WebDAV solltest Du in jedem Fall den Haken bei ''<nowiki>Secure https://</nowiki>'' setzen, sonst würde Deine ownCloud diesen Speicher unverschlüsselt ansprechen -- und damit nicht nur Dein Passwort sondern auch Deine Dateien unverschlüsselt übertragen.

<note tip>Grundsätzlich ist das Einbinden von WebDAV immer etwas frickelig, weil fast jeder WebDAV-Server anders funktioniert. Solltest Du auf Probleme stoßen, probiere es ruhig auch erstmal mit einem reinen WebDAV-Client oder zwei und versuche hierüber darauf zu schließen, welche Einstellungen für ownCloud passen könnten. Ein User berichtete uns z.B., dass er seinen WebDAV-Account zweimal einbinden musste, einmal mit dem Root-Verzeichnis, einmal mit dem Verzeichnis das er eigentlich einbinden wollte, damit letzteres funktioniert.</note>

==== anderer externer Speicher ====

Die External Storage App von ownCloud unterstützt auch noch andere externe Speicher, wenn Du auf soetwas Zugriff hast und das erfolgreich testen konntest, lass es uns ruhig wissen, wenn es dazu was zu sagen gibt, verlinken wir das hier gern.

<note>Uns wurde verschiedentlich berichtet, dass auch die Dropbox-Anbindung funktioniert. Da es sich dabei um propietäre Software handelt können wir dazu aber keinen Support leisten und gehen daher hier nicht näher darauf ein.</note>

==== Speicher mehrerer Uberspaces zusammenschalten ====

Das geht über die External Storage App für ownCloud natürlich (auch wenn es nicht sonderlich effizient ist). Du kannst das auch gerne tun. Bedenke aber bitte, dass Speicher Kosten verursacht.

===== Debugging =====

=== Meldungen im Admin Panel ===

Das Admin Panel von Owncloud gibt ''Security & setup warnings'' aus, zu denen wir im Support immer wieder gefragt werden. Hier ein paar Beispiele und Ansatzpunkte: 

  * Dieser Server hat keine funktionierende Internetverbindung.
  * cURL is using an outdated NSS version.

Stelle dir eine [[https://wiki.uberspace.de/development:php#php-version_einstellen|aktuelle PHP-Version]] ein. Ältere Versionen linken gegen eine Version von ''cURL'', in der es zu [[https://github.com/owncloud/core/issues/16255#issuecomment-119531656|Problemen mit dem Handling von HTTPS-Verbindungen]] kommen kann.

  * Es wurde kein PHP Memory Cache konfiguriert. 
  * Transactional file locking is using the database as locking backend, for best performance it's advised to configure a memcache for locking.

[[http://metafakten.de/|Johannes Ries]] hat einen Blogpost zum [[http://metafakten.de/2015-11-06/owncloud-redis-cache-und-transactional-file-locking-bei-uberspace/|Einsatz von Redis in ownCloud]] verfasst.

  * You are accessing this site via HTTP. We strongly suggest you configure your server to require using HTTPS instead as described in our security tips.

Richte dir eine [[https://wiki.uberspace.de/webserver:htaccess#https_erzwingen|Zwangsumleitung auf HTTPS]] ein.

  * Der „Strict-Transport-Security“-HTTP-Header ist nicht auf mindestens „15768000“ Sekunden eingestellt.

Mit diesem Header kannst du den Browser instruieren, dass er künftig keine HTTP-Verbindungen mehr zu dieser Site aufbaut, sondern für die vorgegebene Zeit nur noch HTTPS verwendet. In einer ''.htaccess''-Datei kann man diesen Header nur für statische Inhalte setzen; für die Ausgabe von PHP-Scripts - wie ownCloud - ist das  nicht so trivial zu machen. Wir empfehlen dir eine [[https://wiki.uberspace.de/webserver:htaccess#https_erzwingen|Zwangsumleitung auf HTTPS]], können die den Header aber auch händisch in deiner ''VirtualHosts'' Konfiguration setzen. Schreib' uns dazu einfach [[mailto:hallo@uberspace.de|eine Mail]]. Beachte aber, dass der Header für **alle** deine aufgeschalteten Domains gilt und du daher [[https://wiki.uberspace.de/webserver:https#nutzung_von_let_s-encrypt-zertifikaten|valide HTTPS-Zertifikate]] installiert haben solltest.

=== Cron ===

Wenn du die cron.php einbinden möchtest, dann achte bitte auf die Stolperfalle bei der Benutzung von PHP in der [[development:php#php-scripts_unter_cron|crontab]] bzw. bei [[development:php#php-scripts_unter_runwhen|runwhen]].

=== PHP ===

Häufig gibt es Probleme mit dem Upload von großen Dateien. Serverseitig liegt die von uns voreingestellte Grenze bei 300 MB (noch größere Uploads per HTTP dauern einfach zu lange, für sowas nimm bitte SFTP/SCP), aber die meisten Skriptsprachen steigen schon vorher aus. Das betrifft auch ownCloud, das in PHP geschrieben ist, was in seiner Default-Konfiguration bei so großen Uploads nicht mitspielt. Wenn Du das nicht bereits für eine andere Installation behoben hast, kannst Du mit den folgenden Befehlen PHP für größere Uploads vorbereiten:

<code bash>
cp /package/host/localhost/php-$PHPVERSION/lib/php.ini ~/etc/
sed -i -e "s/^upload_max_filesize.*/upload_max_filesize = 290M/" ~/etc/php.ini 
sed -i -e "s/^post_max_size.*/post_max_size = 300M/" ~/etc/php.ini 
killall -u $USER php-cgi
</code>

===== Was nicht geht =====

==== News App ====

Seit Owncloud 8 benötigt die News App eine neuere Version von ''libxml'':

<code>
Library libxml with a version higher than 2.7.8 is required - available 
version 2.7.6.0.
</code>

Und da gibt es ein gewisses Problem: Die ''libxml2'' ist eine Bibliothek, die von der Distribution bereitgestellt und auch gepflegt wird, und das ist bei CentOS halt nicht die Version 2.7.8. Das wird sich innerhalb des Lebenszyklus der Distribution auch nicht ändern; hier wird aus Gründen der Abwärtskompatibilität [[https://wiki.uberspace.de/faq#die_version_von_ist_auf_eurem_server_so_alt_koennt_ihr_da_was_machen|lediglich Modellpflege betrieben]]. 

Du kannst dir zwar hypothetisch eine neuere libxml2 via [[system:toast|toast]] oder [[cool:homebrew|Brew]] in deinem Home-Verzeichnis installieren, nur dürfte das nicht viel bringen, wenn das betreffende ownCloud-Modul nicht direkt auf die libxml2 zugreift, sondern die PHP-Extension haben will, die dann wiederum gegen die libxml2 des Systems linkt - denn das PHP bleibt ja nach wie vor das gleiche. Das libxml-Modul von PHP gehört auch zum Sprachkern - man kann das also weder weglassen noch autark als eigenständiges Modul (in neuerer Version) installieren. 
