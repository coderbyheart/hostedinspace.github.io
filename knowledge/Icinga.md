---
layout: default
---
# Icinga

[Icinga](https://www.icinga.org/) bietet eine Sammlung von Modulen zur Überwachung von Netzwerken, Servern und Diensten. Außerdem bringt es eine Web-Schnittstelle zum Abfragen der gesammelten Daten mit.

Bei Icinga handelt es sich um einen [Nagios](https://www.nagios.org/)-Fork, welcher von einer Gruppe von Nagios-Entwicklern 2009 gegründet wurde. Der Entwicklungsprozess ist dynamischeren als bei Nagios, sodass Patches schneller angewendet werden und mehr Rücksicht auf die Community genommen wird.

# Installation

Zunächst erstellen wir eine temporäres Verzeichnis und wechseln hinein:

{% highlight bash %}
$ mkdir -p ~/.var/tmp
$ cd ~/.var/tmp
{% endhighlight %}

Dann laden wir die aktuelle Version von Icinga herunter und entpacken das Archiv:

{% highlight bash %}
$ wget https://github.com/Icinga/icinga-core/releases/download/v1.13.3/icinga-1.13.3.tar.gz
$ tar xf icinga-1.13.3.tar.gz
{% endhighlight %}

Dann wechseln wir in das Verzeichnis, konfigurieren, kompilieren und installieren Icinga:

{% highlight bash %}
$ cd icinga-1.13.3
$ ./configure --prefix=$HOME/.opt/icinga --with-icinga-user=$USER \
    --with-icinga-group=$USER \
    --with-command-user=$USER \
    --with-command-group=$USER \
    --with-web-user=$USER \
    --with-web-group=$USER \
    --with-httpd-conf=$HOME/.opt/icinga/etc/apache2 \
    --with-init-dir=$HOME/.opt/icinga/etc/init.d \
    --with-cgiurl=/cgi-bin/icinga \
    --disable-idoutils
$ sed "/^INIT_OPTS=/s/root/$USER/g" -i Makefile
$ make all
$ mkdir -p ~/.opt/icinga/var/{rw,lock}
$ mkdir -p ~/.opt/icinga/etc/{apache2,init.d}
$ mkdir /var/www/$USER/cgi-bin/icinga
$ ln -s /var/www/$USER/cgi-bin/icinga ~/.opt/icinga/sbin
$ mkdir /var/www/$USER/domains/default/icinga
$ ln -s /var/www/$USER/domains/default/icinga ~/.opt/icinga/share
$ make fullinstall
$ make install-config
{% endhighlight %}

Nun passen wir noch einige Rechte an:

{% highlight bash %}
chmod -R 755 /var/www/$USER/cgi-bin/icinga
{% endhighlight %}

Syslog muss deaktiviert werden:

{% highlight bash %}
sed -i '/use_syslog=1/s/1/0/' /home/$USER/.opt/icinga/etc/icinga.cfg
{% endhighlight %}

Der Pfad zum locking-Verzeichnis von icinga muss auch angepasst werden:

{% highlight bash %}
sed -i '/^IcingaLockDir=/s/=/=${prefix}/' /home/$USER/.opt/icinga/etc/init.d/icinga
{% endhighlight %}

Einen Benutzer erstellen:

{% highlight bash %}
htpasswd -s -c /var/www/$USER/domains/default/.htpasswd icingaadmin
cat <<__EOF__ > /var/www/$USER/domains/default/.htaccess
AuthName "Icinga Access"
AuthType Basic
AuthUserFile /var/www/$USER/domains/default/.htpasswd
Require valid-user
__EOF__
cp /var/www/$USER/domains/default/.htaccess /var/www/$USER/cgi-bin/icinga/
{% endhighlight %}

Das Initscript muss ausführbar gemacht werden:

{% highlight bash %}
chmod +x ~/.opt/icinga/etc/init.d/icinga
{% endhighlight %}

Nun können wir die Konfiguration testen. Da wir das gerade erst installiert haben, sollte diese in Ordnung sein:

{% highlight bash %}
~/.opt/icinga/etc/init.d/icinga checkconfig
{% endhighlight %}

Nun richten wir das Ganze noch als Dienst ein:

{% highlight bash %}
[ -d ~/.config/service ] || space-setup-svscan
space-setup-service icinga /home/$USER/.opt/icinga/bin/icinga /home/$USER/.opt/icinga/etc/icinga.cfg
{% endhighlight %}

Nun installieren wir noch die Basis Nagios-Checks:

{% highlight bash %}
cd ~/.var/tmp
wget https://nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
tar xzf nagios-plugins-2.1.1.tar.gz
cd nagios-plugins-2.1.1
./configure --prefix=$HOME/.opt/icinga \
  --with-nagios-user=$USER \
  --with-nagios-group=$USER
make
make install
{% endhighlight %}
