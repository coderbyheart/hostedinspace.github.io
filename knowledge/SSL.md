# Website-Traffice mit SSL verschlüsseln

In diesem Guide wird beschrieben, wie man am Beispiel der eigenen Domain `example.com` für diese ein kostenloses SSL-Zertifikat mit [letsencrypt](https://letsencrypt.org/) erstellt und für diese Domain aktiviert.

## DNS Einträge setzen

Die DNS-Einträge müssen auf `andromeda.hostedinspace.de` zeigen. Dies kannst Du erreichen, indem Du einen `A`-Record und einen `AAAA`-Record mit den Angaben anlegst, die dir nach dem Login angezeigt werden.

    ssh username@andromeda.hostedinspace.de
    …
    Shared IPv4 address: …
    Your IPv6 address: …

Einfacher geht es indem Du einen `CNAME`-Record mit `andromeda.hostedinspace.de` anlegst.

## Domain anlegen (ohne SSL)

Die Domain wird als Umgebungsvariable definiert, damit die nachfolgenden Befehle einfach per Copy&Paste verwendet werden können.

    DOMAIN=example.com

Dies ist nötig, damit letsencrypt die Inhaberschaft der Domain verifizieren kann.

    space-mod-vhost add --domain=$DOMAIN

Die Ausgabe sieht so aus

    ✓ Domain (example.com) added successfully

## Ein neues Zertifikat erstellen

    space-run-letsencrypt certonly -d $DOMAIN

Die Ausgabe sieht in etwa so aus:

    2016-02-27 16:25:52,892:WARNING:letsencrypt.cli:Root (sudo) is required to run most of letsencrypt functionality.
    2016-02-27 16:25:59,506:WARNING:letsencrypt.client:Non-standard path(s), might not work with crontab installed by your operating system package manager
    
    IMPORTANT NOTES:
     - Congratulations! Your certificate and chain have been saved at /hom
       e/username/.config/letsencrypt/live/username.andromeda.host
       edinspace.de/fullchain.pem. Your cert will expire on 2016-05-27. To
       obtain a new version of the certificate in the future, simply run
       Let's Encrypt again.
     - If you like Let's Encrypt, please consider supporting our work by:

       Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
       Donating to EFF:                    https://eff.org/donate-le

## Das Zertifikat für die Verwendung im Webserver vorbereiten

    space-prepare-certificate -k ~/.config/letsencrypt/live/$DOMAIN/privkey.pem -c ~/.config/letsencrypt/live/$DOMAIN/cert.pem -i ~/.config/letsencrypt/live/$DOMAIN/chain.pem

Die Ausgabe sieht so aus:

    ✓ Check certificate
    ✓ Certificate imported
    ✓ Check configuration of webserver
    ✓ Restart webserver

## Vhost für SSL anlegen

Nun kannst Du den VHOST für die verschlüsselte Domain anlegen.

    space-mod-vhost add --domain=$DOMAIN --ssl

Die Ausgabe sieht so aus

    ✗ Directory /var/www/username/domains/example.com already exists. Not creating.
    ✓ Domain (example.com) added successfully

Nun kannst Du <https://example.com> aufrufen.

## Optional: SSL für die Website erzwingen

Lege dazu eine `.htaccess` Datei im Verzeichnis `~/domains/example.com` mit diesem Inhalt an:

    # Force HTTPs
    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R=permanent,L]

Nun wird jeder Aufruf von <http://example.com> nach <https://example.com> umgeleitet.
