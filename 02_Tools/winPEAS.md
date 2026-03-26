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

## Transferring winPEAS
See:
- 02_Tools/File_Transfer.md
- 02_Tools/UNC_Execution.md

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



## **Related Notes**

- [[Priv_Esc]]
- [[Mimikatz]]
- [[UNC_Execution]]
- [[File_Transfer]]
  

