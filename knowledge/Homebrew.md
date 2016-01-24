---
layout: default
---
# Homebrew als Alternative zu toast

Wie [[toast|Anleitungen/toast]] ist Homebrew für Linux ein Paketmanager, der Software im Userspace für dich installiert. Homebrew kommt ursprünglich aus der Mac-Ecke und hat dort den Paketmanager Macports abgelöst. Homebrew funktioniert unter Linux genau so wie auf dem Mac, mit einer Ausnahme: Die Pakete werden standardmäßig nicht nach ''/usr/local'' (dort hättest du ja ohnehin keine Schreibrechte) installiert, sondern in das Verzeichnis ''~/.linuxbrew''. Das ist für den Einsatz auf einem geteilten Server natürlich optimal.

**Beta-Hinweis:** Noch ist Homebrew für Linux ein sehr junges Projekt! Es kann also vorkommen, dass du auf bugs stößt!

Im Gegensatz zu toast kann Homebrew nicht sämtliche Software aus jeder Quelle installieren. Es benötigt Meta-Informationen, die als Formeln bezeichnet werden. Wenn du dich damit aber nicht beschäftigen möchtest und stattdessen "auf gut Glück" lieber einen Tarball aus einer beliebigen Quelle kompilieren möchtest, so sollte [[toast|Anleitungen/toast]] das Werkzeug deiner Wahl sein.

## Installation
Zuerst klonst du das git-Repository:

```
	[abigail@deathspell ~]$ git clone https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew
```

Daraufhin fügst du zwei Zeilen deiner .bashrc hinzu, damit via Homebrew installierte Software auch bevorzugt aufgerufen wird und du die zusätzlich installierten MAN- und INFO-Pages lesen kannst:

```
	[abigail@deathspell ~]$ echo "PATH=\"$HOME/.linuxbrew/bin:$PATH\"" >> ~/.bashrc
	[abigail@deathspell ~]$ echo "MANPATH=\"$HOME/.linuxbrew/share/man:$MANPATH\"" >> ~/.bashrc
	[abigail@deathspell ~]$ echo "INFOPATH=\"$HOME/.linuxbrew/share/info:$INFOPATH\"" >> ~/.bashrc
```

Die Änderungen in der ~/.bashrc aktivierst du, indem du deine Shell anweist, deine ''~/.bashrc'' neu einzulesen: 

```
	[abigail@deathspell ~]$ source ~/.bashrc
```

## Anwendung
Homebrew für Linux rufst du mit dem Befehl ''brew'' auf. Das listet dir auch gleich auf, welche Parameter dir zur Verfügung stehen. Hier eine kleine Auswahl sinnvoller Parameter für den Alltag: 

Software installierst du mittels: 

```
   [abigail@deathspell ~]$ brew install $paket
```

Benötigst du eine zuvor installierte Software nicht mehr, so kannst du sie wieder löschen: 

```
   [abigail@deathspell ~]$ brew remove $paket
```

Informationen zu bestimmten Paketen findest du mittels 

```
   [abigail@deathspell ~]$ brew info $paket
```

Wenn du erstmal herausfinden willst, ob ein bestimmtes Paket für Homebrew verfügbar ist: 

```
   [abigail@deathspell ~]$ brew search $paket 
```

Brew kann sowohl sich selbst als auch sämtliche installierten Pakete upgraden:

```
   [abigail@deathspell ~]$ brew update && brew upgrade
```

Du kannst überprüfen, ob sämtliche mit Homebrew installierte Software ohne Fehler installiert wurde:  

```
   [abigail@deathspell ~]$ brew doctor
```

Mehr dazu findest über den help-Parameter oder in der Manpage von brew: 

```
   [abigail@deathspell ~]$ brew help
   [abigail@deathspell ~]$ man brew
```

Wie du eigene Formeln schreibst, findest du in der [Dokumentation](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md#formula-cookbook) von Homebrew.

## Probleme

### git ist zu alt

Kein Problem, toast hilft dir weiter:

```
[abigail@deathspell ~]$ toast arm https://www.kernel.org/pub/software/scm/git/git-2.3.0.tar.gz
```

### Python

Wenn ihr beim brauen in den folgenden Fehler lauft ...

```
error: option --no-user-cfg not recognized
```

... ist die installierte Python-Version zu alt und ein ...

```
[abigail@deathspell ~]$ brew install python
```

... hilft weiter.

### gcc (und weitere Compiler) werden nicht gefunden
Homebrew bemängelt, dass es nicht weiß, ob der Compiler gcc installiert ist, weil es diesen nicht ''~/.linuxbrew'' finden kann. Aktuell sind daher noch zwei Symlinks nötig, wenn du ''gcc'' voraussetzende Software aus dem Quellcode installieren möchtest (brew kommt momentan noch nicht mit ''gcc'' 5 klar, daher nehmen wir einfach Version 4):

	[abigail@deathspell ~]$ ln -s /package/host/localhost/gcc-4.9/bin/gcc ~/.linuxbrew/bin/gcc-4.9
	[abigail@deathspell ~]$ ln -s /package/host/localhost/gcc-4.9/bin/g++ ~/.linuxbrew/bin/g++-4.9

Danach klappt's aber auch mit der Installation von Software die mit ''gcc'' kompiliert wird.

