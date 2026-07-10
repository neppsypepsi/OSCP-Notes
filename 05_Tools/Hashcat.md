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

#or you can echo it into a file

echo 'hash' > user.hash
```
Paste **only the hash**, one per line.


### **STEP 2 — Identify Hash Type**

Read the hash prefix first — it tells you the type before you even look anything up:

| **Prefix / Pattern** | **Hash Type** | **Mode** |
|----------------------|---------------|----------|
| `$krb5asrep$23$...` | AS-REP Roast | -m 18200 |
| `$krb5tgs$23$...` | Kerberoast | -m 13100 |
| 32 hex chars, no prefix | NTLM | -m 1000 |
| `$2y$` or `$2a$` | bcrypt | -m 3200 |
| `$1$` | MD5 crypt (Linux shadow) | -m 500 |
| `$6$` | SHA-512 crypt (Linux shadow) | -m 1800 |

If the prefix isn't in the table above, use the official reference — paste the prefix in Ctrl+F:
`https://hashcat.net/wiki/doku.php?id=example_hashes`

That page lists every supported mode with an actual example hash next to it.
Match your hash format to the example → use that mode number.


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
