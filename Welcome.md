# OSCP Notes — Vault Index

Personal notes for OSCP prep and HTB practice.

---

## Core Workflow

- [[Attack-Workflow]] — Master playbook, Step 0 through root
- [[Priv_Esc]] — Windows privilege escalation order of operations
- [[VPN-Connections]] — Lab setup and VPN connection steps
- [[Linux_Project_Structure]] — Folder layout to use on every box

---

## Enumeration Tools

- [[Recon_with_NMAP]] — Port scanning workflow
- [[Web_Enum]] — Web enumeration: gobuster, source review, upload testing
- [[SMB]] — SMB share enumeration and access
- [[enum4linux]] — SMB/AD enumeration
- [[Port-Overview-and-Priorities]] — Port → service → what to try next

---

## Credential Attacks

- [[Hydra]] — Brute force SSH, FTP, RDP, and standard HTML login forms
- [[Web_Login_Brute_Force]] — Python requests brute force for JSON API logins
- [[Password_Spraying]] — One password across many users (low and slow)
- [[NetExec]] — Credential validation, pass-the-hash, lateral movement (modern CME)
- [[CrackMapExec]] — Legacy reference (use NetExec instead)

---

## Exploitation Tools

- [[SearchSploit]] — Finding and adapting public exploits
- [[Msfvenom]] — Payload generation for reverse shells
- [[htaccess_Bypass]] — PHP execution via .htaccess upload bypass
- [[HTA_Files]] — Windows HTA execution payloads

---

## Post-Exploitation Tools

- [[winPEAS]] — Windows local enumeration for privesc
- [[Mimikatz]] — Credential extraction after getting admin/SYSTEM
- [[Impacket]] — Remote execution (wmiexec, psexec, secretsdump, Kerberoasting)
- [[Hashcat]] — Offline hash cracking
- [[JohntheRipper]] — Offline hash cracking (alternative)
- [[RDP_and_WinRM]] — Remote access with valid creds
- [[File_Transfer]] — Getting files onto/off the target
- [[UNC_Execution]] — Running files directly from your SMB share
- [[Ligolo]] — Tunneling into internal networks after foothold

---

## Core Skills & Reference

- [[Netcat]] — Raw TCP connections, reverse shell listener, banner grabbing
- [[Windows_Common_Commands]] — Post-access Windows commands
- [[PowerShell]] — PowerShell commands for enumeration and file ops
- [[Nano]] — Terminal text editor shortcuts

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
