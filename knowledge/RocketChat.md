---
layout: default
---
# RocketChat

[RocketChat](https://rocket.chat) ist ein Webchat. Wer Slack kennt und eine Alternative sucht, die auf eigenen Servern gehostet werden kann, hat mit RocketChat eine mögliche Alternative gefunden.

Um RocketChat zu betreiben muss zunächst sichergestellt werden, dass die Voraussetzungen erfüllt sind:

 * git
 * meteor

## Meteor installieren

Das Installationsscript, welches auf <https://www.meteor.com/> zu finden ist, geht davon aus es nach /usr/local/bin schreiben kann. Deswegen muss es zunächst angepasst werden:

{% highlight bash %}
curl https://install.meteor.com | sed -e 's#sudo ##g' -e 's#PREFIX="/usr/local"#PREFIX="$HOME/.local/bin"#g' | sh
{% endhighlight %}

## RocketChat installieren

{% highlight bash %}
mkdir -p $HOME/.opt
cd $HOME/.opt
git clone https://github.com/RocketChat/Rocket.Chat.git
cd Rocket.Chat
{% endhighlight %}

