# John the Ripper — Offline Password Cracking (OSCP)

## **🧠 When You Use JtR**

- You have **password hashes**
    
- Hashcat didn’t crack them
    
- Or hash type is easier in JtR (Windows creds, Linux /etc/shadow, AS-REP)
    


JtR is **slower**, but:

- More forgiving with formats
    
- Better auto-detection
    
- Easier under pressure



## **File Preparation (MOST IMPORTANT PART)**
### **NTLM (Windows)**
**Input file** (example: ntlm.hash)

`31d6cfe0d16ae931b73c59d7e0c089c0`

No username
No LM hash
No extra fields


### **Linux /etc/shadow** 

**Input file** (example: shadow.hash)
`user:$6$salt$hashvalue`
Leave it **exactly as dumped**

### **AS-REP / Kerberos**
**Input file** (from impacket)
`$krb5asrep$23$user@DOMAIN:hash`
Do **not modify**


## **Basic JtR Usage**
```bash
john --wordlist=/usr/share/wordlists/rockyou.txt ntlm.hash
```

### **Show Cracked Passwords**
```bash
john --show ntlm.hash
```

## **Try Rules**
```bash
john --wordlist=/usr/share/wordlists/rockyou.txt --rules ntlm.hash
```

## **Related Notes**

- [[Hashcat]]
- [[Impacket]]
- [[Mimikatz]]