# 🧠 smbmap — SMB Share Access Enumeration (OSCP)
#tags: #smbmap #smb #enum #oscp
#enum4linux #smbclient #CrackMapExec #NetExec

---

## What smbmap Is

**smbmap** enumerates **SMB shares and your access level to each** (READ / WRITE / NO ACCESS) in a single command — its edge over `smbclient`, which only tells you a share exists, not what you can do with it. Pure enumeration, not exploitation. **Not banned on OSCP.**

---

## Ole-Reliable Default (run this first)
```bash
smbmap -H <IP>
```
Lists every share + your permission on each as a **null/anonymous** session. Any share marked READ = somewhere to start browsing.

```bash
# if the bare form doesn't attempt null, force it:
smbmap -u '' -p '' -H <IP>
smbmap -u guest -p '' -H <IP>
```

---

## Core Commands
```bash
# Authenticated (once you have creds)
smbmap -u <user> -p <pass> -H <IP>

# Domain creds
smbmap -d <domain> -u <user> -p <pass> -H <IP>

# Pass-the-Hash (LM:NT)
smbmap -u <user> -p <LMHASH:NTHASH> -H <IP>

# Recurse a share to list files/dirs
smbmap -H <IP> -r <share>          # one level down
smbmap -H <IP> -R <share>          # deep recursive

# Pull / push files
smbmap -H <IP> --download '<share>\path\to\file'
smbmap -H <IP> --upload <localfile> '<share>\path\to\dest'

# Run a command (needs admin access to ADMIN$ / C$)
smbmap -u <user> -p <pass> -H <IP> -x 'whoami'
```

---

## smbmap vs enum4linux (keep both)

| Want to know...                          | Reach for      |
| ---------------------------------------- | -------------- |
| **What shares + can I READ/WRITE them?** | smbmap         |
| Users / groups / password policy / RID   | enum4linux     |
| Broad "everything" sweep                 | enum4linux -a  |
| Modern all-in-one (creds, spray, exec)   | netexec (`nxc smb`) |

Run **smbmap first** for a fast access map, then **enum4linux** for deeper context. They complement each other.

---

## 🔗 Related Notes
- [[SMB]]
- [[enum4linux]]
- [[NetExec]]
- [[CrackMapExec]]
