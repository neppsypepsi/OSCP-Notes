# 🧠 SMB (Server Message Block) — OSCP Notes
#tags: #smb #enum #windows #loot #oscp

## What SMB Is

**SMB = shared folders over a network.**  
**Main question every time SMB is open:**
> “Can I access any shares, and what permissions do I have (read / write)?”


---

### **STEP 1 — Try Anonymous / Guest 
```bash
smbclient -L //<IP>/ -N
```
- -L = list shares
- -N = no password (anonymous)
**Success looks like:** shares listed.
**Failure looks like:** NT_STATUS_ACCESS_DENIED → creds needed


### **STEP 2 — Check Share Permissions (Fast)**
```bash
nxc smb <target ip> -u '' -p '' --shares
```
**Why:** shows share list + whether you have **READ / WRITE**.

#### Default shares — ❌ X these out, they're standard on every Windows host / DC

| Share | Normal perms | What it is | Verdict |
|---|---|---|---|
| `ADMIN$` | admin only | Remote admin (`C:\Windows`) | ❌ default — access = you're **local admin** |
| `C$` | admin only | Whole C: drive | ❌ default — access = you're **local admin** |
| `IPC$` | READ | RPC named-pipe channel, **no files** | ❌ default — used for null-session enum, not loot |
| `NETLOGON` | READ | Logon scripts (DC only) | ❌ default — peek for stray scripts, usually empty |
| `SYSVOL` | READ | GPOs / domain policy (DC only) | ❌ default — quick look for GPP creds, else skip |
| `print$` | READ | Printer drivers | ❌ default |
#### Quick check on SYSVOL — GPP passwords

`SYSVOL` is a default share, but before you X it out, scan it for **GPP passwords**:
old Group Policy Preferences stored a `cpassword` in XML files (`Groups.xml`, etc.),
"encrypted" with a **key Microsoft published** — so anyone who can read SYSVOL can
decrypt it. Needs any valid domain cred.

```bash
nxc smb <IP> -u <user> -p <password> -M gpp_password   # auto-find + decrypt in SYSVOL
```
Manual equivalent (find the file, then decrypt the hash):
```bash
gpp-decrypt <cpassword-string>
```
- **Hit** → plaintext creds for another (often privileged) account → test everywhere.
- **Nothing found** → this box left no GPP cred; move on. (Not a miss — just absent.)

### **STEP 3 — Deeper Enumeration (Confirmation)**
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

## profiles$ dump
- If in the scenario where you have valid creds or anonymous access and there is an avail `profiles$` share to which you can read and you just want to dump it without the other columns run ->

```bash
smbclient -N '//<ip>/profiles$' -c 'ls' | awk '$2=="D" && $1!="." && $1!=".." {print $1}' >  users.txt
```
### **STEP 4 — How to Connect to a Share**

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




### **Mount a Share (Better for Searching)**

Mount the share so `grep`/`find` work on the whole tree. Use smbclient to browse, mount to search/pull many files.

```bash
sudo mount -t cifs //<IP>/<share> /mnt -o guest                          # anonymous / null session
sudo mount -t cifs //<IP>/<share> /mnt -o username=user,password=pass    # with creds
grep -Ri password /mnt                                                   # search across the tree
find /mnt -name "*.xml" 2>/dev/null
sudo umount /mnt
```

> **Null session:** use `-o guest`. `-o "username=,password="` throws `username specified with no parameter`.
>
> **`Unable to find suitable address` / error(115):** target unreachable — check VPN (`ip addr show tun0`) and `ping <IP>`. SMBv1-only host → add `vers=1.0`.
>
> **Reading hits:** real creds = structured config (`.yaml .xml .conf .ini`). Noise = `doc/`, `lang/`, binary matches (bundled examples like CQL's `alice`/`bob`). **Backup ≠ live** — a default like FreeSWITCH `ClueCon` in the backup may not be the running value.

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