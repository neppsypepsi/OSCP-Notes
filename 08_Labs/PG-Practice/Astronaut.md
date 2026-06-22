My IP: 192.168.45.166
Target IP: 192.168.111.12

nmap:
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 98:4e:5d:e1:e6:97:29:6f:d9:e0:d4:82:a8:f6:4f:3f (RSA)
|   256 57:23:57:1f:fd:77:06:be:25:66:61:14:6d:ae:5e:98 (ECDSA)
|_  256 c7:9b:aa:d5:a6:33:35:91:34:1e:ef:cf:61:a8:30:1c (ED25519)
80/tcp open  http    Apache httpd 2.4.41
| http-ls: Volume /
| SIZE  TIME              FILENAME
| -     2021-03-17 17:46  grav-admin/
|_
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: Index of /
Service Info: Host: 127.0.0.1; OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Ideas:
 - Port 22/SSH : Good for connecting to users and and transferring files 
 - Port 80/HTTP : Take a browse at what the web page has to offer.
	 - Real page lives in `/grav-admin`
	- With a gobuster scan we find that there is a sub directory under grav-admin. 
		- /login
		- admin


I stopped doing this one after i learned that the way to do it on youtube was through msfvenon. Not likley id use the tool on oscp so i gave up.
