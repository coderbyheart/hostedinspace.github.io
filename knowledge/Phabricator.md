---
layout: default
---
# Phabricator

Phabricator ist eigentlich darauf ausgelegt einen eigenen Server für sich zu haben, läuft mit ein paar Anpassungen auch in einer Shared Webhosting Umgebung.

{% highlight bash %}
$ cd $HOME/domains
$ mkdir phabricator
$ cd phabricator
$ git clone git://github.com/facebook/libphutil.git
$ git clone git://github.com/facebook/arcanist.git
$ git clone git://github.com/facebook/phabricator.git
$ cd ..
{% endhighlight %}

Dann muss die Konfiguration angepasst werden:

{% highlight bash %}
$ vim phabricator/conf/local/local.json
$ ln -s phabricator/phabricator/webroot $SUBDOMAIN.$DOMAIN.$TLD
$ cd $SUBDOMAIN.$DOMAIN.$TLD
$ cat << EOF > .htaccess
  RewriteEngine on
  RewriteBase /
  RewriteRule ^/rsrc/(.*)     -                       [L,QSA]
  RewriteRule ^/favicon.ico   -                       [L,QSA]
  #RewriteRule ^(.*)$          /index.php?__path__=$1  [B,L,QSA] # from docs, wrong for uberspace.
  RewriteRule ^(.*)$ index.php?__path__=/$1 [B,L,QSA]
  EOF
{% endhighlight %}

Now go to $SUBDOMAIN.$DOMAIN.$TLD. It should say:

{% highlight bash %}
run ./bin/storage upgrade
{% endhighlight %}

So, do that:

{% highlight bash %}
$ phabricator/phabricator/bin/storage upgrade
{% endhighlight %}

Phabricator offloads some work to daemon processes that need to be running all the time. To ensure that, let's create a uberspace service:

{% highlight bash %}
$ runwhen-conf ~/etc/run-phd /var/www/virtual/$USER/phabricator/phabricator/bin/phd
{% endhighlight %}

Now, edit ~/etc/run-phd/run, and change

{% highlight bash %}
RUNWHEN=""
{% endhighlight %}

to something like

{% highlight bash %}
RUNWHEN=",M/5"
{% endhighlight %}

which will run the service every five minutes. Edit the last line and change

{% highlight bash %}
/var/www/virtual/$USER/phabricator/phabricator/bin/phd
{% endhighlight %}

to

{% highlight bash %}
/var/www/virtual/$USER/phabricator/phabricator/bin/phd start
{% endhighlight %}

Start the service:

{% highlight bash %}
$ svc -a ~/service/phd
{% endhighlight %}

You can follow the service log using

{% highlight bash %}
$ tail -f ~/service/phd/log/main/current
{% endhighlight %}

You're done! Navigate again to your subdomain and work on the open issues list.
