My IP: 192.168.45.164
Target IP: 192.168.193.109

# nmap:
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 76:18:f1:19:6b:29:db:da:3d:f6:7b:ab:f4:b5:63:e0 (ECDSA)
|_  256 cb:d8:d6:ef:82:77:8a:25:32:08:dd:91:96:8d:ab:7d (ED25519)
80/tcp open  http    Apache httpd 2.4.58 ((Ubuntu))
| http-robots.txt: 1 disallowed entry 
|_/
|_http-trane-info: Problem with XML parsing of /evox/about
|_http-server-header: Apache/2.4.58 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

Port 80: 
- Here we have a default Apache2 web page
![[Pasted image 20260727112551.png]]
- Following the file path they give us, `/var/www/html/index.html`, we are then able to find a login page. 
![[Pasted image 20260727112643.png]]
- Towards the bottom we can see a version number along with the service name. We can use this for further enumeration if default creds dont work -> `Jorani v1.0.0`
	- admin/admin doesnt work
	- Default creds likley won't work given the documentation page mentions that it would be emailed to you![[Pasted image 20260727113020.png]]
- We end up finding a possible cve -> [CVE-2023-26469](https://github.com/samipmainali/Jorani-Reverse-Shell-v1.0.0/tree/main)
- Running the script we end up getting a shell as jordak, thus allowing us to find our first flag -> `027a51857468d250b47080c3987087b5`
- Trying `sudo -l`, we find we can run `    (ALL) NOPASSWD: /usr/bin/env` as root.
- Searching [gtfobins](https://gtfobins.org/gtfobins/env/#shell) we find that we can run `sudo env /bin/sh` and get a root shell, allowing me to find the last flag -> `ccbb919d9caf5ea8479896cfe38fcd5a`.