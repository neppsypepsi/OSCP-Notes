My IP: 192.168.45.231
Target IP: 192.168.108.103

# nmap: 

```
PORT     STATE SERVICE  VERSION
21/tcp   open  ftp      vsftpd 3.0.5
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to 192.168.45.231
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 3
|      vsFTPd 3.0.5 - secure, fast, stable
|_End of status
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-rw-r--r--    1 0        0            1752 Sep 19  2024 config.xml
22/tcp   open  ssh      OpenSSH 9.6p1 Ubuntu 3ubuntu13.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 76:18:f1:19:6b:29:db:da:3d:f6:7b:ab:f4:b5:63:e0 (ECDSA)
|_  256 cb:d8:d6:ef:82:77:8a:25:32:08:dd:91:96:8d:ab:7d (ED25519)
80/tcp   open  http     Apache httpd 2.4.58 ((Ubuntu))
|_http-server-header: Apache/2.4.58 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
9443/tcp open  ssl/http Apache httpd 2.4.58 ((Ubuntu))
|_http-server-header: Apache/2.4.58 (Ubuntu)
| ssl-cert: Subject: commonName=vmdak.local/organizationName=PrisonManagement/stateOrProvinceName=California/countryName=US
| Subject Alternative Name: DNS:vmdak.local
| Not valid before: 2024-08-20T09:21:33
|_Not valid after:  2025-08-20T09:21:33
| tls-alpn: 
|_  http/1.1
|_ssl-date: TLS randomness does not represent time
|_http-title:  Home - Prison Management System
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 21: We find that this is a ftp server allowing us to connect as `anonymous`. We find that there is a forgotten config.xml file, and after reading the file, we find this line -> `  <InitialRootPassword>/root/.jenkins/secrets/initialAdminPassword></InitialRootPassword>` which looks like a file path. We can't do much with this info right now however it might come in handy later.

Port 9443:
- Just in case, from the nmap scan I observed a hostname of `vmdak.local`. I decided to add it to my /etc/hosts.
- Trying to resolve to the page regularly by appending the port after the IP, we see![[Pasted image 20260730202049.png]]
- So, by using https, we are then able to see a web page![[Pasted image 20260730202111.png]]
- Where it says Admin Dashboard there is this page -> ![[Pasted image 20260730223142.png]]
	- I tried looking up default credentials couldnt find any
	- Tried admin:admin, did not work.
	- Tried single quote, and it crashed the entire page. This hints that SQLi might be in play here
- I used the `sqli.auth.bypass.txt` file to use as a payload for testing possible injections that would work. Here you can see for some we got `302` codes which is different from the standard 200 error splash page we see or the 500 error code. ![[Pasted image 20260730224230.png]]
- Using any of the 302 status code injections worked, and we were then able to see a new web page.
- Right clicking on our users profile picture, and opening it in a new tab reveals a url `https://192.168.108.103:9443/uploadImage/Profile/User.png`![[Pasted image 20260730224620.png]]
- If we can find a way to change this profile picture and create a reverse shell, browse to this url again, we should have a shell. 
- Here we see that we cannot directly upload a php extention based file as a profile picture. Howerver it does accept a file with an extension of jpg with php code inside of it.![[Pasted image 20260730224944.png]]
	- One thing I learned was that after uploading a file with the correct extension with malicious code, trying to browse to it in the URL reveals this error message.![[Pasted image 20260730225051.png]]
	- So, the method that worked was uploading a file with the correct extension, catching the POST in burpsuite, and changing the extension to PHP so that the web page doesn't indeed treat my file as a jpg, which still ends up bypassing the extension specific requirement.
- Doing so allows us to land a shell as `www-data`. After trying to find the local.txt file, there is none for this user, which prompted me to look at the /etc/passwd file to see if there were any other users and sure enough there was, another user `vmdak`
- Remembering from the web-page, there was a password under the leave management tab -> `RonnyCache001` ![[Pasted image 20260730232638.png]]
	- This ended up being vmdak's password, thus allowing us to find the first flag `5af82a3d7fee75e378a4575d247bfd1f`
- After checking most things out, we end up finding a mysql db running on port 3306 (that is NOT visible to the public), and port 8080, likely a webpage (also NOT visible to the public). 
--- 
	- We would need credentials for this, and after later revisiting this, I figured out following my [[Juicy_Files]] notes I wouldve found this out.
		- `grep -rilE 'passw|secret|cred|key|token' /etc /opt /var /home /root 2>/dev/null`
		- grep -inE 'passw|secret|key' /path/to/file (after trying a few that stand out connect2.php ends up being a file with good loot). ![[Pasted image 20260803121431.png]]
		- Using these creds to login to the mysql service then reveals more credentials. Also, using `-h localhost` as our ip works given that this is an internal service running, local host should also work. 
Here is the relevant info i found
DB of interest:
![[Pasted image 20260803122223.png]]
Tables within `employee_akpoly`:
![[Pasted image 20260803122418.png]]
Under tblemployee -> Credentials for prisoner/could be reused
![[Pasted image 20260803122451.png]]
Under tblleave -> Password found ![[Pasted image 20260803122608.png]]
Under users -> Our admin password from the beginning -> nothing special.
![[Pasted image 20260803122639.png]]
- With this information, and placing the passwords, and possible users not only from here but from /etc/passwd, we find that vmdak is indeed our next pivot. We already knew this from guessing and trying password however here was the correct way to figure that out.
--- 
# continuing again...
We found by running `ss -tlnp`, that we find ->![[Pasted image 20260803123021.png]]
So we can browse the port 8080 web page locally, we need to use [[Chisel]].
- We find:
![[Pasted image 20260803131817.png]]
- Here we find a new service (Jenkins), and are new goal would be to enumerate to try and find a version number so we can find an exploit or something similar. 
- Using `curl -v http://127.0.0.1:8082/`![[Pasted image 20260803132117.png]]
	- We end up finding a version of 2.401.2. This was also revealed at the very beginning when we observed the config.xml file.
	- Using this we were able to find this [LFI exploit](https://github.com/godylockz/CVE-2024-23897/tree/main) online.
	- Using the file path mentioned in the config file, and login page, we end up being able to read that file which gives us the password needed to login to the Jenkins Service -> `140ef31373034d19a77baa9c6b84a200` ![[Pasted image 20260803141007.png]]
	- We end up being able to get a reverse shell going with busybox![[Pasted image 20260803141147.png]]
	- Doing so we then have a shell as root, allowing us to find the last flag -> `96a89f208843856892faf8c9aa5b7e55`