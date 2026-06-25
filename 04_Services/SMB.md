# 🧠 SMB (Server Message Block) — OSCP Notes
#tags: #smb #enum #windows #loot #oscp

## What SMB Is

**SMB = shared folders over a network.**  
A machine exposes folders to other machines on the network. Those folders are called **shares**.

Common share names you’ll see:
- `Public`
- `Backups`
- `Users`
- `HR`
- `C$` (admin share)
- `ADMIN$` (admin share)

**Main question every time SMB is open:**
> “Can I access any shares, and what permissions do I have (read / write)?”

---

## When to Use SMB 

Use this note when:
- Nmap shows **139/tcp or 445/tcp**
- You got creds and want to test SMB access
- You need loot (configs, scripts, backups)
- You want a path to execution (only if there is a trigger)
---

## Why SMB Is Valuable (What It Usually Gives You)

- Files with useful information
- Backups left accessible
- Scripts that are writable
- Credentials stored for convenience
- Paths / hostnames / internal network info

---

## What to Look For in Shares (and What to Do Next)

### Config files (`.xml .ini .config .conf`)
**Why:** often contain plaintext creds or connection strings.  
**What to do:**
- Download
- Read them
- Extract usernames/passwords/hosts
- Immediately test creds on SMB/RDP/WinRM/FTP

### Scripts (`.ps1 .bat .vbs .sh`)
**Why:** scripts may run automatically via tasks/services/backup jobs.  
**What to do:**
- Check if you can write/replace them
- If writable, identify the trigger (task/service/reboot)
- Do NOT assume upload = execution

### Backups (`.bak .zip .tar` + database dumps)
**Why:** backups often contain old creds / secrets / registry dumps.  
**What to do:**
- Download and unzip on Kali
- Hunt for creds, hashes, configs inside

### Obvious creds / notes (`password.txt`, `notes.txt`)
**Why:** quick wins → immediate reuse.  
**What to do:**
- Test creds everywhere (SMB/RDP/WinRM/Web/FTP/SSH)

---
## 5️⃣ SMB Enumeration Workflow (OSCP)

Run these in order. Stop when you get new info.

---
### STEP 1 — Confirm SMB Is Open
```bash
nmap -p 139,445 -sV <target>
```

### **STEP 2 — Try Anonymous / Guest 
```bash
smbclient -L //<IP>/ -N
```
- -L = list shares
- -N = no password (anonymous)
**Success looks like:** shares listed.
**Failure looks like:** NT_STATUS_ACCESS_DENIED → creds needed


### **STEP 3 — Check Share Permissions (Fast)**
```bash
nxc smb <target ip> -u '' -p '' --shares
```
**Why:** shows share list + whether you have **READ / WRITE**.

### **STEP 4 — Deeper Enumeration (Confirmation)**
```bash
enum4linux -a <IP>
```
**Why:** can reveal users/shares/domain info. Use as supporting evidence.
```bash
crackmapexec smb <IP>
```
**Why:** quick visibility into:

- OS
- domain/workgroup
- SMB signing
- auth behavior


### **STEP 5 — How to Connect to a Share**

```bash
smbclient //<IP>/<share> -U user%password

#or anonymously 

smbclient //<IP>/<share> -N

```

Once Inside smbclient:
```bash
ls
cd <dir>
get <file>
```

## **How to List shares as a User**
This will work if you have obtained some sort of potential user name and password

```bash
smbclient -L //<ip>/ -U domain/username
```

You will then be asked for a password and you will enter it there


## **How to connect to a share as a User**
After you have verified that there indeed is shares, you may then begin to connect to the share and see whats inside using this command:
```bash
impacket-smbclient user:'pass'@<ip>
```

## **How to move around after connected**
After you connected to the user, you should then refer back to the shares that are available to then interact with the share. From here you will want to see whats there and if there is loot pull it back to your machine:

```bash
use <share>
```
This is to actually enter the share. Once in then you can "ls" to see whats in there


After moving around and if you see some files that you like and want to download over to your machine you can use these commands:
```bash
get <file>
#or 
mget * #which grabs all
```




### **STEP 6 — Mount a Share (Better for Searching)**

Mounting with `mount -t cifs` lets you use `find`, `grep`, and standard Linux tools across the whole share — much faster than navigating smbclient manually when you need to search for files or strings.

```bash
# anonymous / null session — use `guest` 
sudo mount -t cifs //<IP>/<share> /mnt -o guest

# with credentials
sudo mount -t cifs //<IP>/<share> /mnt -o username=user,password=pass

# then search normally
grep -Ri password /mnt              # recurse + case-insensitive, show matching lines
find /mnt -name "*.xml" 2>/dev/null

# unmount when done
sudo umount /mnt
```

> **Null session gotcha:** `-o "username=,password="` throws `username specified with no parameter` — mount.cifs rejects the empty username. Use **`-o guest`** for anonymous instead.
>
> **If you get `Unable to find suitable address` / mount error(115):** the target isn't reachable — check the VPN (`ip addr show tun0`) and `ping <IP>` first. For an SMBv1-only host, add `vers=1.0`.

**Why mount over smbclient:** `grep`/`find` work on the full tree. Use smbclient to browse; mount when you need to search or pull multiple files.

> **Reading the grep output:** real secrets live in structured config under `/etc/` (`.yaml`, `.xml`, `.conf`, `.ini`). Treat hits under `doc/`, `lang/`, and `binary file matches` as noise — those are bundled docs/examples (e.g. Cassandra's CQL.html showing `alice`/`bob` example passwords), not live creds. A **backup config ≠ the live config** — a default like FreeSWITCH's `ClueCon` in the backup may not be what the running service uses.

---

### **STEP 7 — Write Tests (Only if Writable)**
```bash
put <file>
del <file>
```
IMPORTANT: uploading the file does nothing as you will need to find another way to get the file to execute


## **🔗 Related Notes**

- [[Nmap]]
- [[enum4linux]]
- [[CrackMapExec]]
- [[NetExec]]
- [[Password_Spraying]]
- [[Hydra]]
- [[RDP_and_WinRM]]
- [[File_Transfer]]
- [[UNC_Execution]]