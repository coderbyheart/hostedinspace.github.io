---
layout: default
---
# Prosody

Zunächst muss geschaut werden, welche Lua-Version installiert ist, da Prosody nur mit Lua 5.1 läuft:

```
$ lua -v
Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio
```

Danach müssen die nötigen Lua-Module mit luarocks installiert werden:

`luarocks install luasocket --local`  
`luarocks install luaexpat --local`  
`luarocks install luafilesystem --local`  
`luarocks install luasec --local`

Wenn das geklappt hat, sieht das nach dem Befehl `luarocks list` in etwa so aus:

```
Installed rocks:
----------------

luaexpat
   1.3.0-1 (installed) - /home/UUSER/.luarocks/lib/luarocks/rocks

luafilesystem
   1.6.2-2 (installed) - /home/UUSER/.luarocks/lib/luarocks/rocks

luasec
   0.5-2 (installed) - /home/UUSER/.luarocks/lib/luarocks/rocks

luasocket
   3.0rc1-1 (installed) - /home/UUSER/.luarocks/lib/luarocks/rocks
```

Danach kommt die eigentliche Installation von Prosody, welches wir mit toast installieren. Dazu zunächst auf der [Homepage](https://prosody.im/download/start) die aktuelle Version herausfinden und dann installieren:

```
toast --confappend="--with-lua-include=/usr/include/lua5.1" arm https://prosody.im/downloads/source/prosody-$VERSIONSNUMMER.tar.gz
```

Nun müssen ein paar Verzeichnisse für Daten und Konfigurationsdateien angelegt werden:
`mkdir -p ~/.var/lib/prosody`

Nun werden Zertifikate erstellt:

```
mkdir -p ~/.var/lib/prosody/ssl/
cd ~/.var/lib/prosody/ssl/
openssl dhparam -out dh-4096.pem 4096
openssl genrsa -out prosody_domain.tld_private.key 4096
openssl req -new -key prosody_domain.tld_private.key -out prosody_domain.tld_cert.csr
```

Wichtig ist der 'CommonName'; hier muss der Domainname stehen, z.B. 'domain.tld'.
Mit dem Inhalt von prosody_domain.tld_cert.csr lässt sich nun ein kostenloses signiertes Zertifikat erstellen, bei [CaCert](http://cacert.org) oder [StartCom](http://startcom.com).

Das Zertifikat in `~/.var/lib/prosody/ssl/prosody_domain.tld.crt` einfügen.

Zertifikatsanfrage wieder entfernen:
```
rm ~/.var/lib/prosody/ssl/prosody_domain.tld_cert.csr
```

Erstellt noch eine PID-Datei:
```
mkdir -p ~/.var/run
touch ~/.var/run/prosody.pid
```

Und nun prosody konfigurieren: Eine kommentierte Konfigurationsdatei liegt in `~/.toast/armed/etc/prosody/prosody.cfg.lua`. Kann nicht schaden, die mal für Referenzen beiseite zu legen:
```
cp ~/.toast/armed/etc/prosody/prosody.cfg.lua ~/.toast/armed/etc/prosody/prosody.cfg.lua.stock
```

Wir schreiben unsere config jedoch nach `~/.var/lib/prosody/data/prosody.cfg.lua`, damit sie bei späteren Updates mit toast nicht überschrieben wird.
Folgende config wird so schon funktionieren, wie es die allermeisten brauchen.
Anpassen müsst ihr unbedingt wieder UUSER (siehe [sed](https://de.wikipedia.org/wiki/Sed_%28Unix%29)-Schnippsel), eure Domain und die Ports:

```
pidfile = "/home/UUSER/.var/run/prosody.pid";
admins = { "admin@domain.tld" }
modules_enabled = {
	"roster";
	"saslauth";
	"tls";
	"dialback";
	"disco";
	"private";
	"vcard";
	"privacy";
	"version";
	"uptime";
	"time";
	"ping";
	"posix";
	"pep";
	"register";
	"admin_adhoc";
	"motd";
	"welcome";
};
daemonize = false; -- IMPORTANT for daemontools! DO NOT EDIT!  
data_path = "/home/UUSER/.var/lib/prosody/data";  
log = { info = "*console" } -- IMPORTANT for daemontools! DO NOT EDIT! "*console" schickt den Output in daemontools Konsole. 
-- log = { "*console" } -- diese Zeile anstelle obiger, wenn ihr auch Debug-Infos wollt. Achtung: IPs werden dann auch geloggt.
allow_registration = false;  
s2s_ports = { XXXXX } -- Server to Server
c2s_ports = { XXXXX } -- Client to Server
c2s_require_encryption = true  
s2s_require_encryption = true  
authentication = "internal_hashed" -- do not save passphrases in cleartext!

VirtualHost "domain.tld" -- anpassen!  
	enabled = true

	ssl = {  
		key = "/home/UUSER/.var/lib/prosody/ssl/prosody_domain.tld_private.key";
		certificate = "/home/UUSER/.var/lib/prosody/ssl/prosody_domain.tld.crt";

		-- Allow perfect forward secrecy.
		dhparam = "/home/UUSER/.var/lib/prosody/ssl/dh-4096.pem";

		-- Best ciphers for perfect forward secrecy.
		ciphers = "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH:EDH+aRSA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4:!SEED:!AES128:!CAMELLIA128";

        	options = { "no_sslv2", "no_sslv3", "no_ticket", "no_compression", "cipher_server_preference", "single_dh_use", "single_ecdh_use" }
}
```

Nett zu haben ist auch die MUC (Multi User Chat)-Funktion, sie erlaubt das erstellen von chatrooms.
Sie setzt allerdings eine subdomain voraus und ist daher davon abhängig, ob euer Zertifikat das zulässt.
Falls ja, könnt ihr folgendes an das Ende der config hängen:

```
Component "subdomain.domain.tld" "muc"
	name = "EinName"
	restrict_room_creation = false --- user dürfen Räume selbst erstellen
```

Jetzt verlinken wir unsere config dorthin, wo prosody sie erwarten wird:

```
rm ~/.toast/armed/etc/prosody/prosody.cfg.lua
ln -s ~/.var/lib/prosody/data/prosody.cfg.lua ~/.toast/armed/etc/prosody/prosody.cfg.lua
```

Nun erstellen wir einen daemontools-service. Falls das euer erster ist:

```
space-setup-svscan
```

```
space-setup-service prosody ~/.toast/armed/bin/prosody
```

Testen ob prosody läuft:

```
$ prosodyctl status
Prosody is running with PID XXXX
```

Testen ob prosody auch die über luarocks installierten Module nutzt:

```
$ prosodyctl about

Prosody unknown

# Prosody directories
Data directory:  	/home/UUSER/.toast/armed/var/lib/prosody
Plugin directory:	/home/UUSER/.toast/pkg/prosody/v0.9.4/1/root/lib/prosody/modules/
Config directory:	/home/UUSER/.toast/armed/etc/prosody
Source directory:	/home/UUSER/.toast/pkg/prosody/v0.9.4/1/root/lib/prosody

# Lua environment
Lua version:             	Lua 5.1

Lua module search paths:
  /home/UUSER/.toast/pkg/prosody/v0.9.4/1/root/lib/prosody/?.lua
  /home/UUSER/.luarocks/share/lua/5.1/?.lua
  /home/UUSER/.luarocks/share/lua/5.1/?/init.lua
  /usr/share/lua/5.1/?.lua
  /usr/share/lua/5.1/?/init.lua
  /home/UUSER/.luarocks/share/lua/5.1/?.lua
  /home/UUSER/.luarocks/share/lua/5.1/?/init.lua
  /usr/lib64/lua/5.1/?.lua
  /usr/lib64/lua/5.1/?/init.lua
  /home/UUSER/.luarocks/share/lua/5.1/?.lua
  /home/UUSER/.luarocks/share/lua/5.1/?/init.lua

Lua C module search paths:
  /home/UUSER/.toast/pkg/prosody/v0.9.4/1/root/lib/prosody/?.so
  /home/UUSER/.luarocks/lib/lua/5.1/?.so
  /usr/lib/lua/5.1/?.so
  /home/UUSER/.luarocks/lib/lua/5.1/?.so
  /usr/lib64/lua/5.1/?.so
  /usr/lib64/lua/5.1/loadall.so
  /home/UUSER/.luarocks/lib/lua/5.1/?.so

LuaRocks:        	Installed (2.1.2)

# Lua module versions
lfs:     	LuaFileSystem 1.6.2
lxp:     	LuaExpat 1.3.0
pposix:  	0.3.6
socket:  	LuaSocket 3.0-rc1
ssl:     	0.5.PR
```

## Account erstellen

```
prosodyctl adduser admin@domain.tld
```

Nun musst du bei deiner Domain noch passende SRV-Einträge anlegen. Wie das geht findet sich z.B. im [Prosody Wiki](https://prosody.im/doc/dns).

Nun kannst du dich mit deinem client anmelden. Die meisten Clients werden nur funktionieren, wenn du den c2s-Port mit angibst.

Zu guter Letzt: Teste deinen Prosody XMPP-Server im [IM Observatory](https://xmpp.net).

