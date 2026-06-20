# winPEAS — Windows Local Enumeration 

Purpose:
- Identify privilege escalation paths
- Highlight misconfigurations
- Surface credentials
- Reduce manual enumeration time


## When to Run winPEAS

Run winPEAS when:
- You have any Windows shell (cmd, PowerShell, RDP)
- You are NOT SYSTEM yet
- You want privesc paths

## Where winPEAS Lives on Kali

Always serve from the installed package path — never use stale copies:

```
/usr/share/peass/winpeas/winPEASx64.exe     ← 64-bit (most targets)
/usr/share/peass/winpeas/winPEASx86.exe     ← 32-bit
/usr/share/peass/winpeas/winPEASany.exe     ← any arch
/usr/share/peass/winpeas/winPEAS.bat        ← if .exe is blocked by AV
/usr/share/peass/linpeas/linpeas.sh         ← Linux targets
```

Serve it:
```bash
cd /usr/share/peass/winpeas && python3 -m http.server 8000
```

## Transferring winPEAS
See:
- [[File_Transfer]]
- [[UNC_Execution]]

## Running winPEAS

From writable directory (recommended):
C:\Users\Public\

`.\winPEASx64.exe`

Notes:

- Expect noisy output
    
- Antivirus may block it
    
- If blocked → rename file






## Things to Watch

##  **Domain Name (AD Context)**
If winPEAS shows:
`Domain Name: OSCP.LAB`
### **Why this matters**
	- Lateral movement becomes possible
    
	- Domain tools (Mimikatz, Kerberoasting) are now valid

### **Next steps**
whoami
whoami /groups
net user /domain


## **Cached Credentials (Very Important)**
### **What winPEAS is telling you**

Windows may have **stored credentials** from:

- Logged-in users
    
- Services
    
- Scheduled tasks
    
### **Where creds usually live**

- Registry
    
- LSASS memory
    
- Config files
    
- PowerShell history
    
### **Immediate next steps**
`cmdkey /list`
then
`dir C:\Users\*\AppData\Roaming\Microsoft\Credentials /s`

If you have admin or SeDebug:
👉 **Run Mimikatz**



## **PowerShell History**
Users often typed **passwords, scripts, or commands** directly into PowerShell.

```cmd
type %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```
### **What you’re hunting**

- Plaintext passwords
    
- Network paths
    
- Admin scripts
    
- Backup jobs

## **SeImpersonatePrivilege (🔥 HUGE)**
### **What this means**

If you see:
SeImpersonatePrivilege Enabled
run:
`whoami /priv`

Later tools:

- PrintSpoofer
    
- JuicyPotato (depends on OS)

## **Scheduled Applications / Tasks**

### **What winPEAS found**

- Tasks that run automatically
    
- Often run as SYSTEM
    
- Sometimes writable by users (bad)

### **What to do next**
```cmd
schtasks /query /fo LIST /v
```
Then check:

- **Task runs as** SYSTEM?
    
- **Executable path writable?**
    
- **Script writable?**



## **AutoLogon Credentials (Plaintext in Registry)**

One of the most reliable credential finds in AD environments.
Windows stores AutoLogon passwords in plaintext under:
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`

winPEAS output looks like:
```
Looking for AutoLogon credentials (T1552.002)
    Some AutoLogon credentials were found
    DefaultDomainName  :  DOMAIN
    DefaultUserName    :  DOMAIN\username
    DefaultPassword    :  PlaintextPasswordHere
```

**Critical gotcha:** `DefaultUserName` may show the display name or a slightly different string from the real sAMAccountName.
Always verify the actual username before assuming it's correct:

```bash
netexec smb <IP> -u <guessed_user> -p '<password>'
```

Once confirmed → try WinRM, SMB, NTDS dump depending on account rights.
See → [[Active_Directory_Attacks]]

---

## **Related Notes**

- [[Windows_Priv_Esc]]
- [[Active_Directory_Attacks]]
- [[Mimikatz]]
- [[UNC_Execution]]
- [[File_Transfer]]
  

