---
layout: default
---
# Brimir
> [Brimir](https://getbrimir.com/) is a simple helpdesk system that can be used to handle support requests via incoming email. Brimir is currently used in production at Ivaldi.

Quelle: [Brimir Git Repo](https://github.com/ivaldi/brimir#brimir--)

## Installation
Wechsle in das Verzeichnis `cd ~/.opt`. Wenn es noch nicht vorhanden ist, lege es erst an:

{% highlight bash %}
cd ~
mkdir .opt
cd .opt
{% endhighlight %}

Klone das Brimi-Git-Repo `git clone https://github.com/ivaldi/brimir.git` und wechsle in das angelegte Verzeichnis `cd brimir`.

Trag das `unicorn`-gem in das Gemfile ein `echo "gem 'unicorn'" >> Gemfile`.

Installiere `bundler` mit `gem install bundler`.

{% highlight bash %}
bundle install --without sqlite postgresql development test --path .bundle --no-deployment
sed -i "s/<%= ENV\[\"SECRET_KEY_BASE\"\] %>/`bin/rake secret`/g" config/secrets.yml
mysql -e "CREATE DATABASE $(id -nu)_brimir;"
{% endhighlight %}

Passe die `config/database.yml` an.
Setze den Adapter auf `mysql2` und ändere die variable `user: ` zu `username: `.
Für `username: ` und `password: ` füge die Zugangsdaten aus der Datei `~/.my.cnf` ein.

Lass die folgenden Befehle laufen:

{% highlight bash %}
bundle exec rake db:schema:load RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production
bundle exec rails console production
{% endhighlight %}

Gebe den folgenden String, angepasst um deine Daten für den Admin-Account, in den Prompt ein:

{% highlight ruby %}
u = User.new({ email: 'your@email.address', password: 'somepassword', password_confirmation: 'somepassword' });
u.agent = true;
u.save!
{% endhighlight %}

Öffne einen Port mit [`space-mod-ports open`](/Skripte/space-mod-ports#open).

Lass den Befehl mit deinem neuen Port laufen:

{% highlight bash %}
bundle exec unicorn -E production -p $PORTNUMMER
{% endhighlight %}

Dein Brimir ist jetzt auf http://andromeda.hostedinspace.de:$PORTNUMMER zu erreichen.
