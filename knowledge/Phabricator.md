---
layout: default
---
# Phabricator

Phabricator ist eigentlich darauf ausgelegt einen eigenen Server für sich zu haben, läuft mit ein paar Anpassungen auch in einer Shared Webhosting Umgebung.

```
$ cd $HOME/domains
$ mkdir phabricator
$ cd phabricator
$ git clone git://github.com/facebook/libphutil.git
$ git clone git://github.com/facebook/arcanist.git
$ git clone git://github.com/facebook/phabricator.git
$ cd ..
```

Dann muss die Konfiguration angepasst werden:
```
$ vim phabricator/conf/local/local.json
```

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
Now go to $SUBDOMAIN.$DOMAIN.$TLD. It should say:

 run ./bin/storage upgrade
So, do that:

$ phabricator/phabricator/bin/storage upgrade
Phabricator offloads some work to daemon processes that need to be running all the time. To ensure that, let's create a uberspace service:

$ runwhen-conf ~/etc/run-phd /var/www/virtual/$USER/phabricator/phabricator/bin/phd
Now, edit ~/etc/run-phd/run, and change

 RUNWHEN=""
to something like

 RUNWHEN=",M/5"
which will run the service every five minutes. Edit the last line and change

 /var/www/virtual/$USER/phabricator/phabricator/bin/phd
to

 /var/www/virtual/$USER/phabricator/phabricator/bin/phd start
Start the service:

$ svc -a ~/service/phd
You can follow the service log using

$ tail -f ~/service/phd/log/main/current
You're done! Navigate again to your subdomain and work on the open issues list.

