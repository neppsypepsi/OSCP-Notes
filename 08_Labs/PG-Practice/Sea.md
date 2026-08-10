My IP: 192.168.45.186
Target IP: 192.168.211.162
# nmap:
```
PORT      STATE SERVICE VERSION
21/tcp    open  ftp     vsftpd 3.0.5
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| -rw-rw-r--    1 0        0            5637 Jun 14  2025 log_01.log
| -rw-rw-r--    1 0        0            7181 Jun 15  2025 log_02.log
| -rw-rw-r--    1 0        0            5627 Jun 14  2025 log_03.log
|_-rw-rw-r--    1 0        0            5687 Jun 14  2025 log_04.log
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 192.168.45.186
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 2
|      vsFTPd 3.0.5 - secure, fast, stable
|_End of status
22/tcp    open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 f2:5a:a9:66:65:3e:d0:b8:9d:a5:16:8c:e8:16:37:e2 (ECDSA)
|_  256 9b:2d:1d:f8:13:74:ce:96:82:4e:19:35:f9:7e:1b:68 (ED25519)
80/tcp    open  http    Apache httpd 2.4.58 ((Ubuntu))
|_http-server-header: Apache/2.4.58 (Ubuntu)
|_http-title: Villa Agency - Real Estate HTML5 Template
55743/tcp open  http    Apache httpd 2.4.58 ((Ubuntu))
|_http-server-header: Apache/2.4.58 (Ubuntu)
|_http-title: Sea
| http-cookie-flags: 
|   /: 
|     PHPSESSID: 
|_      httponly flag not set
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 21: 
- Here we can see that anonymous access is supposed to be granted per our nmap scan. And sure enough when logging in we find 4 different log files. The one that catches my eye is `log_02.log` -> ![[Pasted image 20260806122735.png]]
	- It stands out because there are file paths that we can try browsing too if we acquire the correct IP/Domain for it.
Port 80: 
- Here we find the equivalent of a zillow or redfin, as we get to see different houses along with their prices. What I would be looking for on a web page like this, is emails, domains, potential usernames, hidden directories with gobuster, or any sqli vulns. But this page had none of that so I moved on to the http page on port 55743.

Port **55743**: 
- Here we find a webpage thats all in Chinese, but after translating it we find at the bottom that this page is likely running the SeaCMS as seen in this image -> ![[Pasted image 20260806123641.png]]
- Gobuster reveals a tonnn of hidden directories ->![[Pasted image 20260806123717.png]]
	- Under `/data/admin/` there is a file called ver.txt that reveals what looks like a version number -> `V13.3`. I tried looking for possible exploits releated to SeaCMS and this version number but wasn't able to find anything.
	- Also tried searching searchsploit but found nothing 
- Looking back at the log files we found, we can imply that we can potentially browse to one of the paths. `/th4o4p/database.php`. Here we end up finding some hidden creds ->![[Pasted image 20260806124910.png]]
	- ssh ->`nicolas:YoureGonnaMakeIt846`
	- This allowed me to find the first flag -> `577900674275bc0e56913544590076a4`
- We are able to log in as this user via ssh, and after running sudo -l, we find that we can run   `(ALL) NOPASSWD: /bin/ps aux`
	- I tried seaching gtfo bins if we could exploit this but didn't find anything, and I also trying seeing what processes were running and that maybe there was a service running that `nicolas` couldn't see but root could, but again found nothing that stood out. 
- I ran linpeas, and it flagged file paths in similar locations -> ![[Pasted image 20260806125440.png]]
- I then decided to read the full file to understand context.
```
cat /var/www/SeaCMS/database.php
$hidden_creds = [
  'ssh_user' => 'nicolas',
  'ssh_password' => 'ImGonnaBeSuperhero594'
];
```

- But what was weird about this was that I was currently logged in as nicolas, and given that password reuse is common and possible, I decided to try switching users to root, to see if the password would work and sure enough it did.
- Thus allowing me to find the last flag -> `75789faba2714633563b95109dc55171`