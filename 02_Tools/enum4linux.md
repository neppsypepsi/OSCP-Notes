# 🧠 enum4linux — SMB / AD Enumeration (OSCP)
#tags: #enum4linux #smb #ad #enum #oscp
#CrackMapExec #smbmap #smbclient

---

## What enum4linux Is

**enum4linux** is an **SMB-focused enumeration tool**.

It wraps multiple SMB/RPC queries into one command to extract:
- Users
- Groups
- Shares
- Domain info
- Password policy
- OS details

It does **not exploit anything**.
It is purely **information gathering**.

---

## When You Use enum4linux (Real OSCP Triggers)

Use enum4linux when:
- Ports **139/445** are open
- SMB is confirmed reachable
- You want **confirmation or expansion** of SMB findings
- You suspect **Active Directory**
- You want usernames for spraying or later attacks

enum4linux is **not always required**, but it’s useful when:
- Anonymous SMB works
- SMB access is partially restricted
- You want to validate what smbclient/smbmap already showed

---

## What enum4linux Is Best At

enum4linux is good for:
- Finding **usernames**
- Identifying **domain/workgroup**
- Listing **shares**
- Seeing **password policy**
- Confirming **OS type**

It is **not good** for:
- Exploitation
- Getting shells
- Testing credentials at scale

Think of it as **context + confirmation**.

---

## Core Commands You Actually Need (OSCP)

### Full Enumeration (Most Common)
```bash
enum4linux -a <IP>
```

Use this when:

- SMB is open
- You don’t know much about the host yet


## **🔗 Related Notes**

- [[SMB]]
- [[Password_Spraying]]
- [[CrackMapExec]]
- [[NetExec]]