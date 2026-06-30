# OSCP Notes — Vault Index

Personal notes for OSCP prep and HTB practice.

---

## Core Workflow

- [[Attack-Workflow]] — Master playbook, Step 0 through root
- [[When_In_Doubt]] — Methodology Q&A for when you're stuck mid-box
- [[Session-Guide-Boxes]] — How Claude should help during labs
- [[VPN-Connections]] — Lab setup and VPN connection steps
- [[Labs-Index]] — Index of every box attempted with status

---

## Enumeration

**Techniques**
- [[Web_Enum]] — gobuster (with `-x`), source review, upload testing
- [[Port-Overview-and-Priorities]] — Port → service → what to try next

**Tools**
- [[Nmap]] — Port scanning workflow
- [[enum4linux]] — SMB/AD enumeration
- [[wpscan]] — WordPress enumeration
- [[BurpSuite]] — HTTP interception, Repeater, Decoder
- [[Curl]] — Raw HTTP requests for enum and probing

---

## Exploitation

**Techniques**
- [[LFI_RFI]] — Local/Remote File Inclusion (PHP filter, log poisoning)
- [[Web_Template_RCE]] — Template injection (LSP, PHP, ASP)
- [[htaccess_Bypass]] — PHP execution via `.htaccess` upload bypass
- [[Web_Login_Brute_Force]] — Python requests for JSON API logins
- [[Password_Spraying]] — One password across many users
- [[SQL_Injection]] — SQL injection (manual detection, auth bypass, UNION)
- [[ReverseShells]] — Payload library by language

**Tools**
- [[SearchSploit]] — Finding and adapting public exploits
- [[Msfvenom]] — Payload generation for reverse shells
- [[GitHub_Repos]] — Pulling and adapting PoCs from GitHub
- [[Hydra]] — Brute force SSH, FTP, RDP, standard HTML logins

---

## Post-Exploitation

**Linux**
- [[Linux_Priv_Esc]] — Order of operations: sudo → SUID → cron → creds → passwd → kernel
- [[Linux_Common_Commands]] — Shell tricks, base64, file edits

**Cross-platform**
- [[File_Transfer]] — Getting files on/off the target
- [[Juicy_Files]] — What to hunt and why

**Hash Cracking**
- [[Hashcat]] — Offline hash cracking
- [[JohntheRipper]] — Alternative cracker

---

## Services

- [[FTP]] — Anonymous login, file transfer, passive mode gotchas
- [[SMB]] — Share enumeration, anonymous access, mounting
- [[MySQL]] — Connection, navigation, LOAD_FILE, INTO OUTFILE

---

## Windows (everything Windows in one place)

**Privesc / Enum**
- [[Windows_Priv_Esc]] — Privilege escalation order of operations
- [[Windows_Common_Commands]] — Post-access commands
- [[PowerShell]] — Enumeration and file ops
- [[winPEAS]] — Automated privesc enumeration

**Credential / Lateral Movement**
- [[NetExec]] — Modern CrackMapExec — credential validation, PTH, spraying
- [[Mimikatz]] — Credential extraction (admin/SYSTEM required)
- [[Impacket]] — wmiexec, psexec, secretsdump, Kerberoasting

**Execution & Pivoting**
- [[HTA_Files]] — Windows HTA payloads
- [[UNC_Execution]] — Run files from your SMB share
- [[RDP_and_WinRM]] — Remote access with valid creds
- [[Ligolo]] — Tunneling into internal networks

---

## Reference

- [[HTML_Basics]] — Reading HTML for web enum
- [[Netcat]] — Raw TCP, reverse shell listener, banner grabbing
- [[Exiftool]] — Metadata extraction

---

## Attack Chains

- [[Exhibitor-ZooKeeper-RCE-to-Root]] — Worked example, end to end

---

## Attack Path (Quick Mental Model)

```
VPN → Nmap (all ports) → Service enum → Web/SMB/FTP enum
→ SearchSploit / brute force / upload → Foothold
→ winPEAS / linPEAS → Privesc → SYSTEM/root → Proof
```

---

## Credential Attack Decision Tree

```
Got usernames?
├── Yes → Password spray with NetExec (nxc smb <IP> -u users.txt -p 'Password1')
│         Brute force with Hydra (SSH/FTP/RDP)
│         Python script for JSON web logins → Web_Login_Brute_Force
└── No  → Enumerate first (SMB, web, enum4linux)

Got a hash?
├── Try pass-the-hash first (nxc smb <IP> -u user -H <hash>)
└── Crack it (hashcat -m 1000 hash.txt rockyou.txt)
```
