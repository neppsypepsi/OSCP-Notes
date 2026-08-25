# 🌐 Common Ports & Services — Possible Entry Points

This note maps **open ports → services → what to try next**.

Use this after port scanning to quickly decide:
- What to enumerate
- What tools to run
- Where footholds usually come from

---

## 21 — FTP

**Service:** File Transfer Protocol

### What it might mean
- Anonymous login enabled
- Exposed files
- Writable directories
- Old/vulnerable FTP service

### First things to try
- Anonymous login
- Directory listing
- File upload/download

### Why it matters
FTP misconfigs often lead to:
- Credential leaks
- Web shell upload
- Direct file access

---

## 22 — SSH

**Service:** Secure Shell

### What it might mean
- Valid user accounts exist
- Password or key-based auth
- Possible brute-force (only if creds found)

### First things to try
- Banner/version check
- Look for creds from other services
- Try known users/passwords

### Why it matters
SSH is rarely the initial foothold, but:
- Very strong once creds are found
- Often leads directly to user shell

---

## 23 — Telnet

**Service:** Telnet (plaintext)

### What it might mean
- Old system
- Weak or default credentials
- No encryption

### First things to try
- Default creds
- Anonymous access

### Why it matters
Telnet is almost always a **security issue**.

---

## 25 — SMTP

**Service:** Mail Transfer

### What it might mean
- User enumeration possible
- Internal email services
- Potential phishing paths

### First things to try
- User enumeration
- Mail commands without auth

### Why it matters
Can reveal:
- Valid usernames
- Internal naming schemes

---

## 53 — DNS

**Service:** Domain Name System

### What it might mean
- Internal domain present
- Possible zone transfers

### First things to try
- Zone transfer attempts
- Subdomain enumeration

### Why it matters
DNS leaks structure of the environment.

---

## 80 / 443 — HTTP / HTTPS

**Service:** Web Server

### What it might mean
- Web application present
- File uploads
- Login pages
- API endpoints

### First things to try
- Manual browsing
- Directory brute forcing
- Source code inspection

### Why it matters
Web is the **most common initial foothold**.

---

## 88 — Kerberos

**Service:** Windows/AD Authentication

### What it might mean
- 🚩 **This host is a Domain Controller** (AD box)
- A Windows domain exists
- Usernames become high-value (roasting, spraying)

### First things to try
- Pair with LDAP (389) to enumerate the domain
- Build a username list first, THEN think Kerberos attacks
- Add the domain name to `/etc/hosts` before any Kerberos tool

### Why it matters
Kerberos + LDAP open together = **Domain Controller**. That changes the whole
playbook toward AD enumeration. See [[LDAP]] and [[Active_Directory_Attacks]].

---

## 110 / 143 — POP3 / IMAP

**Service:** Mail Access

### What it might mean
- User mailboxes accessible
- Credential reuse potential

### First things to try
- Banner grabbing
- Login attempts (if creds found)

### Why it matters
Emails often contain:
- Passwords
- Reset links
- Sensitive info

---

## 139 / 445 — SMB

**Service:** Windows File Sharing

### What it might mean
- Windows host
- Domain or standalone
- Shares and users exist

### First things to try
- Anonymous share listing
- User enumeration
- Share access

### Why it matters
SMB is one of the **highest-value services** in OSCP.

---

## 389 / 636 / 3268 / 3269 — LDAP / LDAPS / Global Catalog

**Service:** Active Directory Directory Service

### What it might mean
- 🚩 **Domain Controller** (especially with 88/Kerberos also open)
- The AD directory — every user, group, computer
- Anonymous bind may leak the whole domain

### First things to try
- Anonymous bind for the base DN: `ldapsearch -x -H ldap://<ip> -s base namingcontexts`
- Dump users → username list
- `netexec ldap <ip> -u '' -p ''`

### Why it matters
LDAP tells you **who exists** in the domain — the seed for every AD attack.
Full workflow in [[LDAP]].

---

## 3306 — MySQL

**Service:** Database

### What it might mean
- Backend database exposed
- Weak credentials
- App misconfiguration

### First things to try
- Login attempts
- Default creds
- DB enumeration

### Why it matters
Databases often store:
- Passwords
- App configs
- Hashes

---

## 3389 — RDP

**Service:** Remote Desktop

### What it might mean
- Windows GUI access
- Valid users exist

### First things to try
- Credential reuse
- Password spraying (only if allowed)

### Why it matters
RDP = direct interactive access if creds are found.

---

## 5900 — VNC

**Service:** Virtual Network Computing

### What it might mean
- Remote desktop exposed
- Weak or no auth

### First things to try
- Connect without password
- Try default creds

### Why it matters
Unauthenticated VNC = instant GUI access.

---

## 5985 / 5986 — WinRM

**Service:** Windows Remote Management

### What it might mean
- Remote command execution **if you have creds** (5985 HTTP / 5986 HTTPS)
- Common on Windows servers and Domain Controllers

### First things to try
- Validate creds: `nxc winrm <ip> -u u -p p` → look for `(Pwn3d!)`
- Get a shell: `evil-winrm -i <ip> -u u -p p`

### Why it matters
Valid creds + WinRM = **interactive shell** — the classic AD foothold once you
recover a credential. See [[RDP_and_WinRM]].

---

## 8080 / 8000 / 8443 — Alternate Web Ports

**Service:** Web / Admin Panels

### What it might mean
- Admin interfaces
- Dev apps
- APIs

### First things to try
- Browse directly
- Look for admin panels
- Default credentials

### Why it matters
Alt web ports often hide **juicy interfaces**.

---

## 🚩 Recognizing a Domain Controller (read the ports as a group)

Don't attack ports one-by-one — read the **set** to classify the box first:

| Ports seen together | Verdict |
|---|---|
| 88 + 389 (+ 3268, 464, 53) | **Domain Controller → Active Directory box** |
| 80/443 + 445, no 88/389 | Standalone Windows server |

A DC changes your first moves: LDAP/SMB enumeration for a **username list** becomes a
first-class path right alongside web/gobuster. See [[LDAP]] → [[Active_Directory_Attacks]] → [[BloodHound]].

---

## 🔁 How to use this note

After a port scan:
1. Identify open ports
2. Look them up here
3. Decide which enumeration note to open next

This note tells you **where to go**, not how to exploit.