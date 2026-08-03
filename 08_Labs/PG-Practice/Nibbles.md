My IP: 192.168.45.186
Target IP: 192.168.225.47

# nmap: 
```
PORT     STATE  SERVICE      VERSION
21/tcp   open   ftp          vsftpd 3.0.3
22/tcp   open   ssh          OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 10:62:1f:f5:22:de:29:d4:24:96:a7:66:c3:64:b7:10 (RSA)
|   256 c9:15:ff:cd:f3:97:ec:39:13:16:48:38:c5:58:d7:5f (ECDSA)
|_  256 90:7c:a3:44:73:b4:b4:4c:e3:9c:71:d1:87:ba:ca:7b (ED25519)
80/tcp   open   http         Apache httpd 2.4.38 ((Debian))
|_http-title: Enter a title, displayed at the top of the window.
|_http-server-header: Apache/2.4.38 (Debian)
139/tcp  closed netbios-ssn
445/tcp  closed microsoft-ds
5437/tcp open   postgresql   PostgreSQL DB 11.3 - 11.9
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=debian
| Subject Alternative Name: DNS:debian
| Not valid before: 2020-04-27T15:41:47
|_Not valid after:  2030-04-25T15:41:47
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

```
Port 21: 
- Tried anonymous access didnt work
Port 80: 
- ![[Pasted image 20260803154325.png]]
	- Internet cats takes you to a random image.
	- Gobuster reveals nothing other than index.html
	- " Another page" reveals a very non interactive web-page![[Pasted image 20260803154451.png]]
- Observing our nmap output, we find that there is a postgres version number.
	- I tried searching up default creds for postgres, google didnt give me a straightforward answer saying it depends.
	- Searchsploit ends up revealing an exploit that is almost identical to the version numbers we found in nmap![[Pasted image 20260803154642.png]]
	- Using `multiple/remote/50847.py` we were were then able to get a shell as `progress@nibbles`, thus allowing us to find our first flag of -> `79221d8fd460630c63b448d0237ff838`
	- This file was found under a user named wilson. After checking /etc/passwd this indeed was also another user we couldve logged in as. 
	- reading the exploit we used, we learn that the username and password for postgres is postgres:postgress
- Transferring over linpeas we find that there is a vulnerable SUID binary set.
![[Pasted image 20260803154225.png]]
- Abusing it lets us get a shell as root allowing us to find the last flag -> `b2b555ac6215804e44df01b8df1b5501`
