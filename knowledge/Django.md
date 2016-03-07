---
layout: default
---
# Mit dem Django-Framework entwickeln

[Django](http://www.djangoproject.com/) ist ein beliebtes Framework für Webapplikationen auf Python-Basis.
In der Doku wird Python 2.7 (Aufruf über _python2.7_) benutzt.


## Django installieren

Erstmal gilt es, Django zu installieren. Nichts leichter als das - mit _pip-2.7_.

{% highlight bash %}
benutzername@andromeda ~ % pip-2.7 install django --user
Collecting django
  Downloading Django-1.8.6-py2.py3-none-any.whl (6.2MB)
    100% |████████████████████████████████| 6.2MB 40kB/s
Installing collected packages: django
Successfully installed django-1.8.6
{% endhighlight %}


## Django-Projekt anlegen und konfigurieren

Die Dokumentation empfiehlt, Django-Projekte ausdrücklich außerhalb des DocumentRoots anzulegen,
und dieser Empfehlung folgen wir gerne. Wir nennen unser Projekt hier im Beispiel _MyDjangoProject_
und möchten es in unserem Home-Verzeichnis anlegen. Also los:

{% highlight bash %}
benutzername@andromeda ~ % django-admin.py startproject MyDjangoProject
{% endhighlight %}

Als nächstes muss die _settings.py_ bearbeitet werden. Hier findest du unter anderem die
Timezone- und Spracheinstellungen. Unser Projekt heißt ja, wie eben festgelegt, _MyDjangoProject_, also ...

{% highlight bash %}
benutzername@andromeda ~ % cd ~/MyDjangoProject
benutzername@andromeda ~/MyDjangoProject % nano MyDjangoProject/settings.py
{% endhighlight %}

Gehen wir mal davon aus, dass wir in Europa sind ...

{% highlight bash %} 
[...]

TIME_ZONE = 'Europe/Berlin'

[...]
{% endhighlight %}

... und Deutsch sprechen ...

{% highlight bash %}
[...]
LANGUAGE_CODE = 'de-de'
[...]
{% endhighlight %}

**wichtig** ist es außerdem, _USE_X_FORWARDED_HOST_ zu setzen, sonst kommt Gunicorn nicht durch den Webserver,
[der hier ja als Proxy arbeitet](https://docs.djangoproject.com/en/dev/ref/settings/#use-x-forwarded-host), hindurch:

{% highlight bash %}
[...]

USE_X_FORWARDED_HOST = True

[...]
{% endhighlight %}

Damit Django im produktiven Betrieb auch auf die eingehenden Anfragen reagiert, ist es inzwischen nötig,
die _ALLOWED_HOSTS_-Variable auf den FQDN (Fully Qualified Domain Name) zu setzen, für den Django zuständig sein soll.
In diesem Fall lautet dieser _django.benutzername.andromeda.hostedinspace.de_ und ist somit identisch mit der URL,
die wir im nächsten Schritt in als _DJANGOURL_ verwenden:

{% highlight bash %}
[...]

ALLOWED_HOSTS = [
  'django.benutzername.andromeda.hostedinspace.de'
]

[...]
{% endhighlight %}

Das war's erstmal an Konfiguration - bitte speichern und schließen.


### Mediendateien für den Admin-Bereich kopieren

... eins haben wir noch vergessen: Die [static files](https://docs.djangoproject.com/en/1.8/howto/deployment/wsgi/modwsgi/#serving-the-admin-files).
Die liegen nämlich nach der Django-Installation außerhalb des DocumentRoots, so dass der Apache nicht drankommt.
Die Django-Dokumentation empfiehlt, sie entweder mit einem Symlink in den DocumentRoot zu bringen oder sie dorthin zu kopieren.
Die erste Variante ist hier keine Option: Da das Home-Verzeichnis für den Webserver
aus Sicherheitsgründen bewusst nicht lesbar ist, könnte der Webserver dem Symlink nicht folgen. Wir müssen die Dateien also kopieren.

Vorher müssen wir uns allerdings Gedanken machen, unter welcher Adresse das Projekt erreichbar sein soll.
Da wir faul sind benutzen wir hierfür eine Variable - _DJANGOURL_. In unserem Beispiel soll das Projekt
unter _django.benutzername.andromeda.hostedinspace.de_ erreichbar sein, also einen eigenen
DocumentRoot spendiert bekommen. Das hat den Vorteil, dass es vollkommen unabhängig von deinem ~/domains-Ordner läuft.

{% highlight bash %}
benutzername@andromeda ~ % DJANGOURL=django.$USER.$(hostname)
{% endhighlight %}

Hier kannst du übrigens alles an Subdomains benutzen, was du aufgeschaltet hast.
Wenn du eine eigene Domain dafür nutzt, hat das den charmanten Nebeneffekt, dass du eigene HTTPS-Zertifikate
benutzen kannst.

... lieber noch mal nachsehen, ob das geklappt hat:

{% highlight bash %}
benutzername@andromeda ~ % echo $DJANGOURL
django.benutzername.andromeda.hostedinspace.de
{% endhighlight %}


Variable gesetzt? Prima. Dann kann's losgehen:

{% highlight bash %}
benutzername@andromeda ~ % mkdir -p ~/domains/$DJANGOURL/static/
benutzername@andromeda ~ % cp -a ~/.local/lib/python2.7/site-packages/django/contrib/admin/static/admin ~/domains/$DJANGOURL/static/
{% endhighlight %}

### Datenbank initialisieren

Nun wird die Datenbank mit _syncdb_ initialisiert, wozu wir das _manage.py_-Script benutzen,
das dann auch gleich den Superuser für das Admin-Interface anlegt.

{% highlight bash %}
benutzername@andromeda ~/MyDjangoProject % python2.7 manage.py syncdb
Creating table auth_permission
...
You just installed Django's auth system, which means you don't have any superusers defined.
Would you like to create one now? (yes/no): yes
Username (Leave blank to use 'benutzername'):
E-mail address: benutzername@andromeda.hostedinspace.de
Password:
Password (again):
Superuser created successfully.
Installing custom SQL ...
Installing indexes ...
Installed 0 object(s) from 0 fixture(s)
{% endhighlight %}

### Deployment mit Gunicorn

Es gibt nun verschiedene Varianten, Django ins Web zu bringen: Mit dem eingebauten Development-Webserver oder
mit [WSGI](https://docs.djangoproject.com/en/1.8/howto/deployment/wsgi/). Bei WSGI gibt es momentan zwei Möglichkeiten:
[uWSGI](http://projects.unbit.it/uwsgi/) und [Gunicorn](http://gunicorn.org/). Wir wollen hier mal mit Gunicorn arbeiten,
uWSGI sollte es aber genau so gut tun. Der Development-Webserver ist nicht für den Produktivbetrieb gedacht. 

### Gunicorn installieren

Auch die Installation von Gunicorn ist nicht sonderlich kompliziert:

{% highlight bash %}
benutzername@andromeda ~/MyDjangoProject % pip-2.7 install gunicorn --user
{% endhighlight %}

... das war's schon.

### deamon einrichten

Gunicorn braucht einen eigenen Port auf dem es laufen kann. Nachdem du dir einen nach den Regeln ausgesucht und überprüft hast, ob er frei ist,
können wir loslegen. Damit wir es später etwas leichter haben, richten wir uns hier mal eine Variable _DJANGOPORT_ ein.

Für die Faulen unter uns:

{% highlight bash %}
benutzername@andromeda ~/MyDjangoProject % DJANGOPORT=$(( $RANDOM % 4535 + 61000)); netstat -tulpen | grep $DJANGOPORT && echo "versuch's nochmal"
{% endhighlight %}

... wenn hier keine Ausgabe _versuch's nochmal_ erscheint, passt alles. Wenn _versuch's nochmal_ kommt - versuch's noch mal :)

Als nächstes ein Daemon, damit wir gunicorn bequem über die Daemontools steuern können.

{% highlight bash %}
benutzername@andromeda ~ % test -d ~/.config/service || space-setup-svscan
benutzername@andromeda ~ % space-setup-service gunicorn gunicorn --error-logfile - --reload --chdir /home/$USER/MyDjangoProject --bind 127.0.0.1:$DJANGOPORT MyDjangoProject.wsgi:application
{% endhighlight %}

... vorsichtshalber schauen wir direkt mal in die Logs:

{% highlight bash %}
benutzername@andromeda ~ % tail ~/.config/service/gunicorn/log/main/current | tai64nlocal
2014-07-24 14:26:56.372297500 2014-07-24 14:26:56 [18606] [INFO] Starting gunicorn 19.0.0
2014-07-24 14:26:56.372824500 2014-07-24 14:26:56 [18606] [INFO] Listening at: http://127.0.0.1:<deinPort> (18606)
2014-07-24 14:26:56.372956500 2014-07-24 14:26:56 [18606] [INFO] Using worker: sync
2014-07-24 14:26:56.374943500 2014-07-24 14:26:56 [18629] [INFO] Booting worker with pid: 18629
{% endhighlight %}

... na das sieht doch gut aus!

### RewriteRule mit Proxy

Unser Gunicorn läuft jetzt auf einem eigenen Port, der aber nach außen hin nicht erreichbar ist. Das erledigen wir nun über eine RewriteRule mit Proxy mit einer eigenen _.htaccess_-Datei.

Hier gibt's nun die Lorbeeren für unsere vorherige Arbeit mit den Variablen. Wenn du _DJANGORUL_ und _DJANGOPORT_ gesetzt hast, wie oben beschrieben, kannst du den folgenden Absatz einfach übernehmen:

{% highlight bash %}
benutzername@andromeda ~ % cat <<__EOF__> ~/domains/$DJANGOURL/.htaccess
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteBase /
RewriteRule ^(.*)$ http://127.0.0.1:$DJANGOPORT/\$1 [P]

RequestHeader set X-Forwarded-Proto https env=HTTPS
__EOF__
{% endhighlight %}

### Ausprobieren

Ruf das Projekt einfach im Browser auf - im konkreten Fall wäre das _https://django.benutzername.andromeda.hostedinspace.de/_.
Da es hier wohl etwas leer aussehen wird ist für uns wohl eher der Admin-Bereich interessant.
Du kannst ihn unter _https://django.benutzername.andromeda.hostedinspace.de/admin/_ erreichen.
Die Zugangsdaten für den Admin-Bereich hast du im Schritt Datenbank initialisieren ja selbst angegeben -
mit diesen Daten kannst du dich hier jetzt einloggen.

Wenn du Dateien in deinem Projekt änderst, vergiss nicht, gunicorn neu zu starten.

### Wie geht es weiter?

Unser Part bei der Sache ist, wie du Django bei Hosted in Space zum Laufen bekommst, also sozusagen der administrative Teil.
Dein eigener Job ist es nun, Django-Applikationen zu entwickeln - da legen wir dir dir das
[offizielle Tutorial](https://docs.djangoproject.com/en/1.6/intro/tutorial01/) ans Herz, und zwar ab dem Abschnitt
[Creating Models](https://docs.djangoproject.com/en/1.6/intro/tutorial01/#creating-models),
denn den ganzen Teil davor hast du mit unserer Doku bereits abgedeckt. Wenn du zu [Part 2](https://docs.djangoproject.com/en/1.6/intro/tutorial02/) wechselst,
kannst du auch erstmal die ersten Teile überspringen, die erklären, wie man den Admin-Bereich aktiviert (denn das hast du ja schon hinter dich gebracht),
so dass du direkt zu [Enter the admin site](https://docs.djangoproject.com/en/1.6/intro/tutorial02/#enter-the-admin-site)) springen und dort weitermachen kannst. Viel Erfolg!
