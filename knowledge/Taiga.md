---
layout: default
---
# Taiga

## Backend installation

### PostgreSQL

{% highlight bash %}
space-setup-postgresql
{% endhighlight %}

dann erst mal ausloggen und wieder einloggen.
Dann sind die Befehle verfügbar um Datenbankuser/Datenbank anzulegen:

{% highlight bash %}
createuser taiga
createdb taiga -O taiga
{% endhighlight %}

### Python Environment

{% highlight bash %}
pip3.4 install virtualenvwrapper --user
source ~/bin/virtualenvwrapper_lazy.sh 
mkvirtualenv -p /usr/local/bin/python3.4 taiga
source ~/.virtualenvs/taiga/bin/activate
{% endhighlight %}

### taiga-back

Download [taiga-back](https://github.com/taigaio/taiga-back)

{% highlight bash %}
mkdir -p $HOME/.opt
cd $HOME/.opt
git clone https://github.com/taigaio/taiga-back.git taiga-back
cd taiga-back
git checkout stable   #or stay at branch master for bleeding edge
{% endhighlight %}

Erstmal alle requirements für taiga-back installieren. Durch virtualenv wird das in $HOME/.virtualenvs/taiga abgelegt.

{% highlight bash %}
pip3.4 install -r requirements.txt
{% endhighlight %}

Ich musste dann noch $PYTHONPATH setzen, damit die mit pip installierten Packages in sys.path verfügbar sind:

{% highlight bash %}
export PYTHONPATH*$HOME/.virtualenvs/taiga/lib/python3.4/site-packages
{% endhighlight %}

weiter geht es mit der offizielen Installationsanleitung:

{% highlight bash %}
python manage.py migrate --noinput
python manage.py loaddata initial_user
python manage.py loaddata initial_project_templates
python manage.py loaddata initial_role
python manage.py collectstatic --noinput
{% endhighlight %}

und falls gewünscht:

{% highlight bash %}
python manage.py sample_data
{% endhighlight %}

jetzt noch konfigurieren, dabei die *example.com* URL abändern zu deiner eigenen URL: 

{% highlight bash %}
from .common import *

MEDIA_URL = "http://example.com/media/"
STATIC_URL = "http://example.com/static/"
ADMIN_MEDIA_PREFIX = "http://example.com/static/admin/"
SITES["front"]["domain"] = "example.com"

SECRET_KEY = "theveryultratopsecretkey"

DEBUG = False
TEMPLATE_DEBUG = False
PUBLIC_REGISTER_ENABLED = True

DEFAULT_FROM_EMAIL = "no-reply@example.com"
SERVER_EMAIL = DEFAULT_FROM_EMAIL

# Uncomment and populate with proper connection parameters
# for enable email sending.
EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
EMAIL_USE_TLS = True
EMAIL_HOST = "DEINHOST.hostedinspace.de"
EMAIL_HOST_USER = "USERNAME@DEINHOST.hostedinspace.de"
EMAIL_HOST_PASSWORD = "PASSWORD"
EMAIL_PORT = 587
{% endhighlight %}

hier müssen natürlich *ASTEROID* und *USER* entsprechend eingetragen werden. Das *PASSWORD* ist das selbe wie für den SSH-Zugang (initial nicht gesetzt, im [Dashboard](https://uberspace.de/dashboard/authentication) einstellen!  
Standardmäßig startet der Backend-Server auf Port 8000.  
Wir sollten aber einen anderen Port als 8000 verwenden:

{% highlight bash %}
TAIGAPORT*$(( $RANDOM % 4535 + 61000)); netstat -tulpen | grep $TAIGAPORT && echo "versuch's nochmal"
{% endhighlight %}

und starten dann den Server mit:

{% highlight bash %}
python manage.py runserver $TAIGAPORT
{% endhighlight %}

## Frontend installation

taiga-front generiert einen Batzen statischer Dateien, die dann später über einen Webserver ausgeliefert werden und über die URL zur API mit dem Backend kommunizieren.

### Ruby

Gewünsche Ruby Version aktivieren wie in [Uberspace: ruby](https://wiki.uberspace.de/development:ruby) beschrieben. Also zum Beispiel:

{% highlight bash %}
cat <<'__EOF__' >> ~/.bash_profile
export PATH=/package/host/localhost/ruby-2.1.1/bin:$PATH
export PATH=$HOME/.gem/ruby/2.1.0/bin:$PATH
__EOF__
{% endhighlight %}

Danach geht es weiter mit:

{% highlight bash %}
gem install --user-install sass scss-lint
{% endhighlight %}

Und jetzt noch *npm* vorbereiten: [Uberspace: nodejs/npm](https://wiki.uberspace.de/development:nodejs#npm)

{% highlight bash %}
cat > ~/.npmrc <<__EOF__
prefix * $HOME
umask * 077
__EOF__
{% endhighlight %}

### Gulp und Bower

Abweichend zur Taiga.io-Installationsanleitung ist hier das *--prefix* wichtig!

{% highlight bash %}
npm install -g --prefix*$HOME gulp bower
{% endhighlight %}

### taiga-front

[taiga-front](https://github.com/taigaio/taiga-front) installieren:

{% highlight bash %}
cd ~
git clone https://github.com/taigaio/taiga-front.git taiga-front
cd taiga-front
git checkout stable	 #or stay at branch master for bleeding edge
{% endhighlight %}

alle Abhängigkeiten installieren:

{% highlight bash %}
npm install
bower install
{% endhighlight %}

und in *~/taiga-front/conf/main.json* die entsprechende URL eintragen:

{% highlight bash %}
    {
        "api": "http://example.com/api/v1/",
        "eventsUrl": "ws://example.com/events",
        "debug": "true",
        "publicRegisterEnabled": true,
        "privacyPolicyUrl": null,
        "termsOfServiceUrl": null
    }
{% endhighlight %}

*example.com* muss hier mit der verwendeten Domain ersetzt werden (deine Uberspace URL), ohne die Angabe von einem Port.
Falls du keinen Apache-Proxy (siehe nächster Abschnitt) verwendest, kann hier auch der Port eingetragen werden (http://example.com:$TAIGAPORT/api/v1), muss dann aber weitergeleitet werden.

Mit gulp kann jetzt alles fürs Frontent erzeugt werden.

{% highlight bash %}
cd ~/taiga-front
gulp deploy
{% endhighlight %}

Mit dem Befehl "gulp" kann ein Testserver auf Port 9001 gestartet werden, dafür benötigt man aber auch Port Forwarding und ist eher für Development-Umgebung und hier nicht empfohlen.

## Apache konfigurieren

Hier gibt es bestimmt elegantere Lösungen, aber manchmal will man schnell Ergebnisse sehen und nicht erst noch einen schönen Deploy-Workflow ausarbeiten ;)

### Dateien kopieren

Dist Files fürs Frontend in den Apache Ordner verschieben. Falls eine andere Domain als die Uberspace-URL verwendet werden soll muss der Pfad entsprechend angepasst werden. 

{% highlight bash %}
cp -r ~/taiga-front/dist/* $HOME/html/
{% endhighlight %}

Static Files fürs Backend:

{% highlight bash %}
cp -r ~/taiga-back/static $HOME/html/
#cp -r ~/taiga-back/media $HOME/html/
{% endhighlight %}

Der "media" Ordner wird in der offiziellen Anleitung beschrieben, war bei mir aber nicht vorhanden. 

### .htaccess 

Die offizielle Anleitung verwendent **nginx** als Webserver, wir konfigurieren hier aber den schon vorhandenen **Apache**.  
Natürlich geht es auch ohne den Proxy zum Backend, dann musst du das Kontrollzentrum wie in [Uberspace: System/Ports](https://wiki.uberspace.de/system:ports) beschrieben deinen gewählten Port weiterleiten lassen.  

$HOME/html/.htaccess

{% highlight bash %}
RewriteEngine On

# api requests
RewriteCond %{REQUEST_URI} ^/api
RewriteRule ^(.*)$ http://127.0.0.1:$TAIGAPORT/$1 [P]
RequestHeader set X-Forwarded-Proto https env*HTTPS

# deliver files, if not a file deliver index.html
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_URI} !^/static/
RewriteCond %{REQUEST_URI} !^/media/
RewriteRule ^ index.html [L]
{% endhighlight %}

Dadurch liefert Apache jetzt alle vorhandenen Dateien aus (JS, CSS, IMG, etc), /api Request werden an das Taiga-Backend weitergeleitet und für alles andere gibt es die index.html zurück. Das ist wichtig damit später Direktaufrufe wie auf http://example.com/project/test/issues richtig verarbeitet werden.

Jetzt sollte alles eingerichtet sein und funktionieren! Browser öffnen und http://USER.ASTEROID.uberspace.de aufrufen und anmelden. Vorausgesetzt du hast die *python manage.py* Befehle ausgeführt kannst du dich mit User admin und Passwort 123123 einloggen (Passwort ändern!)

## daemon

Mit Hilfe der [Uberspace: Daemontools](https://wiki.uberspace.de/system:daemontools) konfigurieren wir einen Service für unser Backend.
Aktiviere services: (das sollte nicht benötigt werden da während der Installation von PostgreSQL schon die Services aktiviert wurden)

{% highlight bash %}
test -d ~/.config/service || space-setup-svscan 
{% endhighlight %}

### Service einrichten

{% highlight bash %}
space-setup-service taiga gunicorn -w 3 -t 60 --chdir /home/$USER/taiga-back --error-logfile - --pythonpath=. -b 0.0.0.0:$TAIGAPORT taiga.wsgi
{% endhighlight %}

und starten:

{% highlight bash %}
svc -u ~/.config/service/taiga
{% endhighlight %}
