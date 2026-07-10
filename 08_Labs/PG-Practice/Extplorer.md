My  IP: 192.168.45.211
Target IP: 192.168.108.16
	New IP: 192.168.170.16

nmap:
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 98:4e:5d:e1:e6:97:29:6f:d9:e0:d4:82:a8:f6:4f:3f (RSA)
|   256 57:23:57:1f:fd:77:06:be:25:66:61:14:6d:ae:5e:98 (ECDSA)
|_  256 c7:9b:aa:d5:a6:33:35:91:34:1e:ef:cf:61:a8:30:1c (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
| http-title: WordPress &rsaquo; Setup Configuration File
|_Requested resource was http://192.168.108.16/wp-admin/setup-config.php
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 22: If we can get creds we can abuse this!

Port 80:
- Webpage lets observe what we can see. 
	- Dead end we find a set up a wordpress page. Additionally, trying to follow the steps to advance on the webpage by providing things such as local host, the target IP and test creds nothing works
- Ran gobuster: Was able to find a few stand out directories. 
	- Filemanager
	- wp-includes
```
filemanager          (Status: 301) [Size: 322] [--> http://192.168.108.16/filemanager/]
index.php            (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
index.php            (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
license.txt          (Status: 200) [Size: 19915]
server-status        (Status: 403) [Size: 279]
wordpress            (Status: 301) [Size: 320] [--> http://192.168.108.16/wordpress/]
wp-admin             (Status: 301) [Size: 319] [--> http://192.168.108.16/wp-admin/]
wp-blog-header.php   (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
wp-content           (Status: 301) [Size: 321] [--> http://192.168.108.16/wp-content/]
wp-cron.php          (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
wp-includes          (Status: 301) [Size: 322] [--> http://192.168.108.16/wp-includes/]
wp-load.php          (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
wp-links-opml.php    (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
wp-login.php         (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
wp-mail.php          (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
wp-settings.php      (Status: 500) [Size: 0]
wp-signup.php        (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
wp-trackback.php     (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
xmlrpc.php           (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
xmlrpc.php           (Status: 302) [Size: 0] [--> http://192.168.108.16/wp-admin/setup-config.php]
```
- We find under the filemanager directory a login page. This seems convincing..however for saftey measure we run another gobuster to see whats under this page. 
	- I also tried putting a single quote in the text box to see if sql injection was possible..and it wasnt
![[Pasted image 20260709171851.png]]
	-From gobuster I  Found some txt files hinting towards a version number however this also appeared to be a dead end
- Meanwhile we searched for the default credentials for extplorer (login page) and we find admin   admin. Luckily, it works allowing us to see all the directories running under this service. 
- We find PHP is a commonly used file type on this webpage. I decided to upload my own php file this time with the standard get cmd function, allowing us to interact with the file through the search bar. 
![[Pasted image 20260709173348.png]]
![[Pasted image 20260709173733.png]]
- command execution works. I created reverse shell encoded in base 64. I got stuck with getting some of the special characters in the encoded text such as "+" and "=" to display. But using my notes was able to replace those characters with the correct characters, thus allowing me to get a shell as www-data. 
- As www-data, I decided to cat  the /etc/passwd file to see if we can enumerate more users. 
- We find another user by the name of `dora`
	- dora:x:1000:1000::/home/dora:/bin/sh
- sudo -l doesnt work for us, so im pretty sure it would be smart to pivot to dora.
	- I tried the rest of my linux esc process and nothing worked. So i was pretty sure we had to find the password to dora if we wanted to escalate. 
	- I went searching for ssh keys and found nothing
	- I used this command `grep -r "dora" /var/www/` to search recursively for any string with the word dora, with intention to get lucky finding doras password. Sure enough we get this line
		- `/var/www/html/filemanager/config/.htusers.php:	array('dora','$2a$08$zyiNvVoP/UuSMgO2rKDtLuox.vYj.3hZPVYq3i4oG3/CtgET7CjjS','/var/www/html','http://localhost','1','','0',1),
- This is for sure encrypted. I will have to use hashcat to crack this. 
- Cracked the password -> doraemon
![[Pasted image 20260709175600.png]]
`
- Now we should be able to switch users from with inside our original shell. 
	- Works; flag -> 0cce6b1e6924f918781bfe0a065e4a64

- Running linpeas we were able to find: `uid=1000(dora) gid=1000(dora) groups=1000(dora),6(disk)
- This means we can use debugfs to read things. See [[debugfs]]
- was able to pull the password hash of root from /etc/shadow, and cracked it with hashcat giving us the password of `explorer`
- Was able to su and get root!
`

Root hash:
```
$6$AIWcIr8PEVxEWgv1$3mFpTQAc9Kzp4BGUQ2sPYYFE/dygqhDiv2Yw.XcU.Q8n1YO05.a/4.D/x4ojQAkPnv/v7Qrw7Ici7.hs0sZiC.

password: explorer
```
Root flag `68e0a40e5662fb101ca9688b4e1948bf`
