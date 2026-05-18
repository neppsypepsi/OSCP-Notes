# Juicy Files — What to Hunt and Why (OSCP)

**Purpose:** Every file type you might come across during enumeration that could give you credentials, escalation paths, or pivoting info. Sorted from most likely to least likely to encounter on OSCP.

---

## 🔴 Almost Every Box

### `.txt`
Catch-all. Admins constantly leave password files, notes, and instructions in plaintext. Always check `Desktop`, `Documents`, and root directories first.
> Common names: `passwords.txt`, `creds.txt`, `notes.txt`, `todo.txt`, `readme.txt`
```cmd
type C:\Users\bob\Desktop\creds.txt
```
> **Scenario:** You check `C:\Users\bob\Desktop` and find `creds.txt`. Bob wrote down the shared admin password so he wouldn't forget it. One line, plaintext — game over.
> **Example file:** `C:\Users\bob\Desktop\creds.txt`

---

### `ConsoleHost_history.txt`
**PowerShell command history.** Users frequently type passwords directly into PowerShell and this file captures every command — always check it immediately after landing.
```cmd
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```
> **Scenario:** You land on a box as a low-priv user. You read the history file and find the admin ran `net user administrator NewPass99!` a week ago — that password still works.
> **Example file:** `C:\Users\bob\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt`

---

### `.config` / `web.config`
Usually `web.config` on IIS (Windows web server). Contains database connection strings — often with plaintext username and password baked in.
```cmd
type C:\inetpub\wwwroot\web.config
```
Look for: `connectionString`, `password=`, `User Id=`
> **Scenario:** You land a shell on a Windows box running IIS. You navigate to `C:\inetpub\wwwroot` and spot `web.config`. You read it and find `Password=db_pass123` — database credentials that reuse for the admin account.
> **Example file:** `C:\inetpub\wwwroot\web.config`

---

### `wp-config.php`
WordPress database config. Always contains MySQL username and password in plaintext. If you find a WordPress install, this is your first read.
```cmd
type C:\xampp\htdocs\wordpress\wp-config.php
```
> **Scenario:** Port 80 is open, gobuster shows `/wordpress/`. You find `wp-config.php` and read the MySQL credentials — those same creds work for the admin panel or the database directly.
> **Example file:** `C:\xampp\htdocs\wordpress\wp-config.php`

---

### `.ps1` / `.bat`
Admin automation scripts. Frequently hardcode credentials for mapped drives, backups, and scheduled tasks.
```cmd
type C:\Scripts\backup.ps1
```
> **Scenario:** winPEAS flags a scheduled task running as SYSTEM that calls `backup.ps1`. You read it and find `net use \\server\share /user:admin Password123` — plaintext credentials right in the script.
> **Example file:** `C:\Scripts\backup.ps1` / `C:\Scripts\nightly_backup.bat`

---

### `.php`
PHP source code. Developers hardcode database credentials, API keys, and admin logic directly in PHP files.
```bash
grep -r "password" /var/www/html/
```
> **Scenario:** You get a shell on a Linux web server. You grep the web root for "password" and find `config.php` with `$db_pass = "S3cur3Pass!"` hardcoded. That password reuses for SSH.
> **Example file:** `/var/www/html/config.php`

---

## 🟠 Common

### `.xml`
Used everywhere — app configs, Windows setup files, scheduled task definitions.
- `Unattend.xml` / `sysprep.xml` → Windows auto-setup files, plaintext admin password under `<Password>`
- Task XML files → may reveal scripts running as SYSTEM
> **Scenario:** You check `C:\` and find `Unattend.xml` left over from OS setup. Inside the `<Password>` tag is the local Administrator password in plaintext or base64.
> **Example file:** `C:\Unattend.xml`

---

### `.bak` / `.old` / `.orig`
Backup copies of sensitive files. Devs create these before making changes and forget to delete them — may contain credentials that were removed from the live version.
> **Scenario:** Gobuster finds `web.config.bak`. The live `web.config` has credentials removed but the backup still has the original database password.
> **Example file:** `C:\inetpub\wwwroot\web.config.bak`

---

### `id_rsa` / `id_ecdsa` / `id_ed25519`
SSH private keys. If found, you can SSH into another machine without a password.

**Check if SSH is running:**
```bash
ss -tlnp | grep 22        # Linux
netstat -ano | findstr :22  # Windows
```

**Where to look:**
```bash
ls -la /home/*/.ssh/      # Linux
ls -la /root/.ssh/
dir C:\Users\*\.ssh\ /a   # Windows
```

**Copy to Kali and use:**
```bash
# Option 1 — cat and paste into a new file on Kali
cat /home/bob/.ssh/id_rsa

# Option 2 — host and download
python3 -m http.server 8080          # on victim
wget http://<VICTIM_IP>:8080/id_rsa  # on Kali

chmod 600 id_rsa
ssh -i id_rsa bob@<IP>
```

**If passphrase protected:**
```bash
ssh2john id_rsa > id_rsa.hash
john id_rsa.hash --wordlist=/usr/share/wordlists/rockyou.txt
```
→ John converts the key to a crackable format, cracks the passphrase offline. Enter it when SSH prompts.
> **Scenario:** You're on a Linux box as `www-data`. You find `/home/bob/.ssh/id_rsa` is world-readable. You copy it to Kali, chmod 600, and SSH into another box in the network as bob.
> **Example file:** `/home/bob/.ssh/id_rsa`

---

### `.sh`
Linux shell scripts used in cron jobs and automation. Frequently contain hardcoded credentials.
> **Scenario:** You find a cron job running `/opt/scripts/monitor.sh` as root. The script contains a hardcoded MySQL password — that password reuses for the root account.
> **Example file:** `/opt/scripts/monitor.sh`

---

### `SAM` + `SYSTEM`
`SAM` stores local Windows user password hashes. `SYSTEM` holds the boot key to decrypt them. Need both — useless without each other.
```
C:\Windows\System32\config\SAM
C:\Windows\System32\config\SYSTEM
```
> Cannot be read while Windows is running — requires SYSTEM + volume shadow copy.
> **Scenario:** You have SYSTEM on a Windows box. You copy both files via volume shadow copy, transfer to Kali, and run `secretsdump.py` to extract the local admin NTLM hash — then pass the hash to other machines.
> **Example files:** `C:\Windows\System32\config\SAM` + `C:\Windows\System32\config\SYSTEM`

---

### `.ini`
Old-style config format. Still used by many installed apps and services to store settings including credentials.
> **Scenario:** You find a network monitoring tool under `C:\Program Files`. Its `settings.ini` contains the database username and password the app uses to connect.
> **Example file:** `C:\Program Files\SolarWinds\settings.ini`

---

### `.db` / `.sqlite`
SQLite database — entire database stored as a single file. Common in lightweight apps and internal tools.
```bash
sqlite3 database.db
.tables
SELECT * FROM users;
```
> **Scenario:** You find a helpdesk app on the box. Its data is in a single SQLite file. You query the users table and find MD5 hashed passwords — crack them with hashcat.
> **Example file:** `C:\Program Files\Helpdesk\data\tickets.db`

---

## 🟡 Situational

### `.env`
Common in Node.js, Python, PHP web apps. Stores environment variables — API keys, database passwords, secret tokens. Devs forget to exclude it from production.
```
DB_PASSWORD=Sup3rS3cr3t
SECRET_KEY=abc123xyz
```
> **Scenario:** You find a Node.js app directory with a `.env` file the dev forgot to remove. It contains the database password which reuses as the user's system password.
> **Example file:** `C:\inetpub\wwwroot\app\.env`

---

### `.py`
Python scripts with hardcoded credentials — common in internal tools and web apps.
> **Scenario:** You find a Python script in the web app directory. The developer hardcoded `db_password = "Welc0me123"` directly instead of using environment variables.
> **Example file:** `/var/www/html/app/db_connect.py`

---

### `.sql`
Database dump file. May contain INSERT statements with usernames and password hashes or plaintext passwords.
> **Scenario:** A developer ran a database export for backup and left it on the server. The `.sql` file has INSERT statements with plaintext passwords.
> **Example file:** `C:\Backups\users_export.sql`

---

### `.json`
Config files for Node.js apps. May contain database connection strings and secrets.
> **Scenario:** You find a Node.js app and read `config.json` — it has the MongoDB connection string with username and password in plaintext.
> **Example file:** `/opt/app/config.json`

---

### `.kdbx`
KeePass password manager database. If you find one, crack the master password and you get every stored credential at once.
```bash
keepass2john database.kdbx > keepass.hash
hashcat -m 13400 keepass.hash rockyou.txt
```
> **Scenario:** You find a KeePass database on the Desktop. The master password cracks to `letmein1`. Inside are 30 stored passwords including the Domain Admin credentials.
> **Example file:** `C:\Users\bob\Desktop\passwords.kdbx`

---

### `.xlsx` / `.docx` / `.pdf`
Office documents. IT docs and HR files often contain default passwords, network diagrams, or employee info useful for password guessing.
> **Scenario:** You find `IT_Onboarding.docx` in a shared folder. It includes the default password all new accounts are created with — you spray it and get a hit.
> **Example file:** `\\fileserver\HR\IT_Onboarding.docx`

---

## 🔵 Less Common in OSCP

### `.pem` / `.key`
Private key files used for SSL certs, SSH, and VPNs. Same value as `id_rsa` if it's an SSH key.
```bash
find / -name "*.pem" -o -name "*.key" 2>/dev/null
chmod 600 server.pem
ssh -i server.pem user@<IP>   # if it's an SSH key
```
> **Scenario:** An admin set up HTTPS and left the private key in the web root. You download it — if it's also used for SSH, you can authenticate with it directly.
> **Example file:** `/etc/ssl/private/server.key`

---

### `.rdp`
Saved Remote Desktop connection files. May contain target hostname, username, and sometimes cached credentials.
> **Scenario:** You find a `.rdp` file on a user's Desktop they use to connect to an internal server. Windows has cached the password — you use it to pivot to that machine.
> **Example file:** `C:\Users\bob\Desktop\dc01.rdp`

---

### `.mdf` / `.ldf`
SQL Server database files. Pull these to your own machine, attach to a local SQL Server instance, and read the contents directly.
> **Scenario:** You find SQL Server installed and locate the database files. You copy them to Kali, attach them, and query the user tables.
> **Example file:** `C:\Program Files\Microsoft SQL Server\MSSQL\DATA\app.mdf`

---

### `.pfx` / `.p12`
Certificate bundled with its private key. Can be cracked with John if password protected.
```bash
pfx2john cert.pfx > cert.hash
john cert.hash --wordlist=/usr/share/wordlists/rockyou.txt
```
> **Scenario:** You find a `.pfx` in a user's Documents — a certificate used to authenticate to an internal portal. You crack the password and import it to authenticate as them.
> **Example file:** `C:\Users\bob\Documents\bob_cert.pfx`

---

### `.js`
JavaScript source files. Sometimes contains hardcoded API keys, tokens, or hidden endpoint paths.
> **Scenario:** You download the site's JS and find a hardcoded API key and an internal endpoint `/admin/api/users` not linked anywhere — you hit it directly and get a full user list.
> **Example file:** `/var/www/html/assets/js/app.js`

---

### `.ovpn`
VPN config file. May contain embedded certs, private keys, or credentials for connecting to another network segment — useful for pivoting.
> **Scenario:** You find an `.ovpn` file for an isolated internal network you can't reach directly. You import it on Kali and pivot into that subnet.
> **Example file:** `C:\Users\bob\Documents\internal-vpn.ovpn`

---

### `NTDS.dit`
**Active Directory database.** Located on Domain Controllers only. Contains all domain user password hashes — extracting this = full domain compromise.
> Requires SYSTEM on the DC + volume shadow copy. Pair with the `SYSTEM` registry hive to extract hashes.
> **Scenario:** You escalate to SYSTEM on the DC. You extract `NTDS.dit` via volume shadow copy and dump every domain user's NTLM hash including the Domain Admin.
> **Example file:** `C:\Windows\NTDS\NTDS.dit`

---

## **Quick Reference**

| Extension | Usually Contains | Likelihood |
|---|---|---|
| `.txt` | Admin notes, plaintext passwords | 🔴 High |
| `ConsoleHost_history.txt` | Typed PS commands, passwords | 🔴 High |
| `.config` / `web.config` | DB connection strings, creds | 🔴 High |
| `wp-config.php` | WordPress DB credentials | 🔴 High |
| `.ps1` / `.bat` | Scripts with hardcoded creds | 🔴 High |
| `.php` | DB creds, API keys | 🔴 High |
| `.xml` | App configs, setup passwords | 🟠 Common |
| `.bak` / `.old` / `.orig` | Copies of sensitive files | 🟠 Common |
| `id_rsa` / SSH keys | SSH private keys | 🟠 Common |
| `.sh` | Linux scripts with hardcoded creds | 🟠 Common |
| `SAM` + `SYSTEM` | Local Windows password hashes | 🟠 Common |
| `.ini` | App settings, sometimes creds | 🟠 Common |
| `.db` / `.sqlite` | Full databases, user tables | 🟠 Common |
| `.env` | API keys, DB passwords | 🟡 Situational |
| `.py` | Hardcoded DB creds | 🟡 Situational |
| `.sql` | DB dumps with hashes | 🟡 Situational |
| `.json` | Connection strings, secrets | 🟡 Situational |
| `.kdbx` | KeePass — all stored passwords | 🟡 Situational |
| `.xlsx` / `.docx` | Default passwords, diagrams | 🟡 Situational |
| `.pem` / `.key` | SSL/SSH private keys | 🔵 Less Common |
| `.rdp` | Saved RDP creds | 🔵 Less Common |
| `.mdf` / `.ldf` | SQL Server database files | 🔵 Less Common |
| `.pfx` / `.p12` | Cert + private key | 🔵 Less Common |
| `.js` | API keys, hidden endpoints | 🔵 Less Common |
| `.ovpn` | VPN creds / pivot paths | 🔵 Less Common |
| `NTDS.dit` | All AD domain hashes | 🔵 Less Common |

---

## **Related Notes**

- [[Windows_Common_Commands]]
- [[PowerShell]]
- [[Linux_Common_Commands]]
- [[Hashcat]]
- [[JohntheRipper]]
