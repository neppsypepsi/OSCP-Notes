My IP: 192.168.45.207
Target IP: 192.168.196.229

# nmap
```
Starting Nmap 7.99 ( https://nmap.org ) at 2026-07-21 22:16 -0700
Nmap scan report for 192.168.196.229
Host is up (0.064s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 c1:99:4b:95:22:25:ed:0f:85:20:d3:63:b4:48:bb:cf (RSA)
|   256 0f:44:8b:ad:ad:95:b8:22:6a:f0:36:ac:19:d0:0e:f3 (ECDSA)
|_  256 32:e1:2a:6c:cc:7c:e6:3e:23:f4:80:8d:33:ce:9b:3a (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title: Zipper
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```



![[Pasted image 20260722222243.png]]
- Here we have a very basic page to which we can only upload a file. Doing so creates a link for us. Hovering over the link reveals to us an uploads directory. 
	- Clicking the link simply spits back to us a zipped version of the file we uploaded.
	- Additionally the search button or feature on this webpage servers no functionality as I have already tried various things including sql injection
- ![[Pasted image 20260722222629.png]]
- Additionally I ran gobuster to see what we can find and we also find the uploads directory, however trying to browse to it gives us a forbidden page `You don't have permission to access this resource.`
- ![[Screenshot From 2026-07-22 22-23-46.png]]
- We sort of hit a dead end, however observing the source code of the page reveals a possible lfi vulnerability 
- ![[Pasted image 20260722222943.png]]
- Our goal is to be able to use this LFI to browse to our uploaded file, to then get our code to execute. However our main roadblock is that replacing "home" with our file name or full file path that is spit back to us, ends up giving us a blank white screen. 
	- I ended up learning that "display_errors" could be disabled/off, and or the the .php could be appended to whatever we replace our file name with when trying to browse to `index.php?file=<file-name>`, due to the fact when trying to resolve to a real file path like our uploads . In fact we proved this because we see in our gobuster the real home page is "home.php", not home without the php extension. Trying to paste in "home.php" a real file path, we again end up getting this blank scren
- So the work around for this is to directly point at the file we want, but getting around the zipped file. To do this we needed to use the "zip" wrapper.
	- `http://192.168.196.229/index.php?file=zip://uploads/upload_1784784318.zip%23exploit`
	- You may wonder why not add php to the end of the file, and its because the webpage appends it
- We end up getting a reverse shell as www-data, and then able to find our first flag -> `0afcc216e9ae2144f6119c6e6b925163`
- Linpeas revealed under "/etc/crontab" that there was a backup script that runs. We do not have privleges to modify the file however we can read it.
- ![[Pasted image 20260722234404.png]]
- reading the file reveals::
```
#!/bin/bash
password=`cat /root/secret`
cd /var/www/html/uploads
rm *.tmp
7za a /opt/backups/backup.zip -p$password -tzip *.zip > /opt/backups/backup.log
```
- It  appears as if first the script reads roots password, moves into the uploads direcrtory, removed everything from tmp, then does something with the password varriable "$password", likley roots password and puts it into the backup.log file. 
	- We are able to read the backup.log file which then reads: 
- ![[Pasted image 20260722234801.png]]
- We have a possible password at the end of the file. Sure enough, switching users over to root, and using this password gets us in, allowing us to find the last flag -> `a2ceaf7c4af8643c80d10ce0a8d9a5b3`