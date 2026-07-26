My IP: 192.168.45.207
target IP: 192.168.175.108

# nmap:
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 b9:bc:8f:01:3f:85:5d:f9:5c:d9:fb:b6:15:a0:1e:74 (ECDSA)
|_  256 53:d9:7f:3d:22:8a:fd:57:98:fe:6b:1a:4c:ac:79:67 (ED25519)
80/tcp open  http    Apache httpd 2.4.52 ((Ubuntu))
|_http-server-header: Apache/2.4.52 (Ubuntu)
|_http-title: Tiny File Manager
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```
- Observing the webpage we find a very basic login page with very little to do.
	- Tried admin admin -> nothing
	- Tried admin password -> nothing
	- Tried searching for default creds for Tiny File Manager. Search results end up proding us with admin/admin@123 or user/12345. Neither work
	- Tried SQL injection by breaking out with single quote -> nothing
	- Tried observing source code of the page to find potential version number
		![[Pasted image 20260725235711.png]]
		- We end up finding a hit for a possible exploit but all of them require for you to get past the login page, which we can't, so this ends up being another dead end
- I end up running a gobuster scan and end up finding a hit for phpinfo.php
```
hta.txt             (Status: 403) [Size: 280]
.hta.bak             (Status: 403) [Size: 280]
.htaccess            (Status: 403) [Size: 280]
.hta.php             (Status: 403) [Size: 280]
.hta                 (Status: 403) [Size: 280]
.htaccess.bak        (Status: 403) [Size: 280]
.htaccess.txt        (Status: 403) [Size: 280]
.htpasswd            (Status: 403) [Size: 280]
.htpasswd.txt        (Status: 403) [Size: 280]
.htpasswd.php        (Status: 403) [Size: 280]
.htaccess.php        (Status: 403) [Size: 280]
.htpasswd.bak        (Status: 403) [Size: 280]
index.php            (Status: 200) [Size: 12045]
index.php            (Status: 200) [Size: 12045]
phpinfo.php          (Status: 200) [Size: 74740]
phpinfo.php          (Status: 200) [Size: 74740]
server-status        (Status: 403) [Size: 280]
Progress: 18452 / 18452 (100.00%)
===============================================================
Finished
===============================================================
```
- We end up finding a php extension that is not standard. 
![[Pasted image 20260726000049.png]]
- A few hints as to why this is our next poi. 
	- The box name is called spx.
	- Running `php -m` within our terminal allows us to get a list of what a default module list looks like (for php), and spx is not in there
	- Searching up what spx is -> "SPX, which stands for Simple Profiling eXtension, is just another profiling extension for PHP."
		- Given that its a third party extension, it should cause us to be more curious about it and enumerate further
- Doing a google search for spx 0.4.15 cve allows us to find a possible hit -> `CVE-2024-42007`
	- Searching for a [github exploit](https://github.com/Strikoder-Premium/CVE-2024-42007-POC) 
	- The exploit ends up requiring a SPX_KEY which we can end up finding on the phpinfo page -> `a2a90ca2f9f0ea04d267b16fb8e63800`
	![[Pasted image 20260726001121.png]]
	- The script we run ends up being a LFI exploit, and the default command ends up cat'ing the /etc/passwd file. 
		- We end up finding a user by the name of profiler that we can actually log into, this can be useful for later.
	- I also tried cat'ing the /proc/self/cmdline but keep getting -> `/usr/sbin/apache2-kstart`
	- What we can end up doing since its likley that `www-data` is running the web-page/login-page, is that we can print out the the index.php file which should be the login page but we should see more info as to whats going on in the back end. 
		- To find out where this web-page file lives we can use help from the phpinfo page for reference as to where things live 
		 ![[Pasted image 20260726002117.png]]
	- After using the correct file path of `/var/www/html/index.php`, we are then able to see some more info
	 ![[Pasted image 20260726002245.png]]
- We are able to see that there are user creds in plain text on the web page, but the password(s), are in hashes. We can then use hashcat to try and crack both of these passwords. 
```
'admin' => '$2y$10$7LaMUa8an8NrvnQsj5xZ3eDdOejgLyXE8IIvsC.hFy1dg7rPb9cqG'
'user' => '$2y$10$x8PS6i0Sji2Pglyz7SLFruYFpAsz9XAYsdiPyfse6QDkB/QsdShxi'
```
- We end up getting a hit for admin 
![[Pasted image 20260726004721.png]]
- From here we are then able to upload our reverse shell and get a shell as www-data
	- Trying to search for the first flag doesn't work. This makes me assume that www-data is not our user that we will get to jump straight to root. 
	- Switching users (su) to profiler, and then providing the password we cracked (lowprofle), we are then able to get a new shell as user profiler, thus allowing us to find our first flag -> `409719f552aa27514a81be99d7bbaaed`
- sudo -l reveals that we can run the make command as root. 
![[Pasted image 20260726010105.png]]
- There is more to how `make` works. A google search reveals "==**`make` is a command-line build automation tool** that automatically builds executable programs and libraries from source code by following instructions specified in a configuration file called a== `Makefile`"
	- So, in simple words it seems like if we can edit this make file, and run this make command, we can end up changing rules. Similar to if we had a script, that root could run, we could append something like `chmod u+s /bin/bash`, we can end up running bash as root.
- After creating my own Makefile on my local machine, I was able to transfer the file over the profiler, run the sudo command and ended up getting this result:
![[Pasted image 20260726013801.png]]
![[Pasted image 20260726013939.png]]
Thus allowing us to get the final flag -> `c94f7a56a91bd74ec14eadf96fdc5ea4`

