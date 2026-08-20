# 🗂️ LDAP (Lightweight Directory Access Protocol) — OSCP Notes
#tags: #ldap #enum #windows #activedirectory #domaincontroller #oscp

## What LDAP Is

**LDAP = the query protocol for a directory database.**
On OSCP that directory is almost always **Active Directory** — the central store of every
user, group, and computer in a Windows domain. LDAP is how you *read* that store.

Ports:
- `389/tcp` — **LDAP** (cleartext)
- `636/tcp` — **LDAPS** (LDAP over TLS)
- `3268 / 3269` — **Global Catalog** (LDAP/LDAPS against the whole forest)

**Main question every time LDAP is open:**
> "Can I bind (anonymously or with any creds), and what does the directory tell me
> about users, groups, and the domain?"

---

## 🚩 The Big Signal — LDAP Means Domain Controller

**LDAP (389) + Kerberos (88) open together = this host is a Domain Controller = it's an AD box.**

That single fact reframes the whole target. It is not "a Windows server" — it is the
**heart of a domain**, and the playbook changes:
- LDAP → enumerate the domain (users, groups, computers), often with **no creds**
- Kerberos (88) → AD-specific attacks *once you have a username list* → see [[Active_Directory_Attacks]]
- Feed what you collect into **BloodHound** → [[BloodHound]]

Other DC tells alongside 88/389: `464` (kpasswd), `3268/3269` (Global Catalog), `53` (DNS), `445` (SMB).

---

## When to Use This Note

- Nmap shows **389 / 636 / 3268 / 3269**
- You want to enumerate an AD domain (get a **username list**) before any attack
- You have low-priv creds and want to dump the directory

---

## Why LDAP Is Valuable (What It Usually Gives You)

- A full **username list** (the seed for AS-REP roast / password spray / Kerberoast)
- Group membership → who is Domain Admin, who has interesting rights
- The **domain name** (needed for Kerberos + `/etc/hosts`)
- Descriptions/comments that sometimes **contain passwords**
- Computer names → map the network

---

## Step 1 — Find the Base DN (naming context)

Every query needs the domain's base DN (e.g. `DC=craft,DC=local`). Ask the server for it
via an **anonymous bind to the RootDSE** — no creds required:

```bash
ldapsearch -x -H ldap://<target-ip> -s base namingcontexts
```
→ `-x` = simple (anonymous) auth, `-s base` = read only the root entry.
Look for `defaultNamingContext` / `namingContexts` → that's your `-b` base DN.

---

## Step 2 — Anonymous Dump (no creds)

If anonymous bind is allowed, pull everything:

```bash
ldapsearch -x -H ldap://<target-ip> -b "DC=domain,DC=local"
```

Filter to just users (cleaner username list):

```bash
ldapsearch -x -H ldap://<target-ip> -b "DC=domain,DC=local" "(objectClass=user)" sAMAccountName
```

> **Anonymous bind is often locked down.** If you get `operationsError` / "successful bind
> must be completed", the server wants creds — come back after finding any.

---

## Step 3 — netexec (fast, and great with creds)

`netexec` (formerly crackmapexec) speaks LDAP and automates the useful pulls:

```bash
# Anonymous / null enumeration
netexec ldap <target-ip> -u '' -p ''

# With any valid creds — users, groups, describe accounts
netexec ldap <target-ip> -u <user> -p <pass> --users
netexec ldap <target-ip> -u <user> -p <pass> --groups

# AD attack shortcuts (only run these once you understand them — see AD note)
netexec ldap <target-ip> -u <user> -p <pass> --asreproast asrep.txt
netexec ldap <target-ip> -u <user> -p <pass> --kerberoasting kerb.txt
```
See [[NetExec]] and [[Active_Directory_Attacks]].

---

## Step 4 — Collect for BloodHound

Once you have creds, pull the whole graph and analyse attack paths visually:

```bash
bloodhound-python -u <user> -p <pass> -d domain.local -ns <target-ip> -c all
```
Then load the JSON into the legacy GUI → [[BloodHound]].

---

## Common Gotcha — Kerberos Needs the Domain Name to Resolve

LDAP gives you the domain name; **add it to `/etc/hosts` before any Kerberos tool**:

```
<target-ip>   domain.local   dc01.domain.local
```
Without it: `KDC_ERR_C_PRINCIPAL_UNKNOWN` / `Name or service not known`.
Full pre-flight (hosts + clock skew) is in [[Active_Directory_Attacks]].

---

## 🔁 Where LDAP Fits

1. Nmap shows 389/88 → **it's a DC**
2. LDAP anonymous → base DN + username list
3. Username list → [[Active_Directory_Attacks]] (AS-REP roast, spray, Kerberoast)
4. Any creds → [[BloodHound]] for the path to Domain Admin

LDAP tells you **who exists**. It's the enumeration that unlocks every AD attack.
