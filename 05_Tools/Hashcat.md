# Hashcat — Offline Password Cracking (OSCP)

Hashcat is an **offline password cracking tool**.
You use it **after you already have hashes** (NTLM, Kerberos, etc.).
Hashcat does **not** touch the target.
It runs **only on your Kali machine**.


## **Where Hashes Come From (OSCP)**

- secretsdump.py
- mimikatz
- GetUserSPNs.py (Kerberoast)
- GetNPUsers.py (AS-REP Roast)
- Config / backup files


## **Basic Hashcat Workflow**
### **STEP 1 — Save the Hash**
Create a file:

```bash
nano user.hash
```
Paste **only the hash**, one per line.


### **STEP 2 — Identify Hash Type**
Most common OSCP modes:

| **Hash Type** | **Mode** |
|---------------|----------|
| NTLM | -m 1000 |
| AS-REP Roast | -m 18200 |
| Kerberoast | -m 13100 |


### **Crack with Wordlist**
```bash
hashcat -m 1000 user.hash /usr/share/wordlists/rockyou.txt
```
### **Then show results**
```bash
hashcat -m 1000 user.hash --show
```

## **Rules**
```bash
hashcat -m 1000 user.hash rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```








## **What to Do After Cracking**
Immediately try the password for:

- SMB
- RDP
- WinRM
- CME spraying
- Impacket shells
- Domain lateral movement

  

## **🔗 Related Notes**

- [[Impacket]]
- [[CrackMapExec]]
- [[NetExec]]
- [[Mimikatz]]
- [[Password_Spraying]]
- [[JohntheRipper]]
