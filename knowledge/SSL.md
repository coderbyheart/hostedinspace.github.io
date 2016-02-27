# Website-Traffice mit SSL verschlüsseln

In diesem Guide wird beschrieben, wie man am Beispiel der eigenen Domain `username.andromeda.hostedinspace.de` für diese ein kostenloses SSL-Zertifikat mit [letsencrypt](https://letsencrypt.org/) erstellt und für diese Domain aktiviert.

## Ein neues Zertifikat erstellen

    space-run-letsencrypt certonly -d username.andromeda.hostedinspace.de

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

    space-prepare-certificate -k ~/.config/letsencrypt/live/username.andromeda.hostedinspace.de/privkey.pem -c ~/.config/letsencrypt/live/username.andromeda.hostedinspace.de/cert.pem -i ~/.config/letsencrypt/live/username.andromeda.hostedinspace.de/chain.pem

Die Ausgabe sieht so aus:

    ✓ Check certificate
    ✓ Certificate imported
    ✓ Check configuration of webserver
    ✓ Restart webserver

Nun kannst Du <https://username.andromeda.hostedinspace.de> aufrufen.

## Optional: SSL für die Website erzwingen

Lege dazu eine `.htaccess` im Verzeichnis `~/domains/default` (für `username.andromeda.hostedinspace.de`) bzw. `~/domains/<domain>` bei allen anderen Domains mit diesem Inhalt:

    # Force HTTPs
    RewriteEngine On
    RewriteCond %{HTTPS} !=on
    RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R=permanent,L]

Nun wird jeder Aufruf von <http://username.andromeda.hostedinspace.de> nach <https://username.andromeda.hostedinspace.de> umgeleitet.
