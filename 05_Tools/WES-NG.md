# WES-NG (Windows Exploit Suggester – NG)

→ Turns a Windows target's `systeminfo` into a ranked list of **missing-patch CVEs** (kernel/privesc route). Runs **on Kali against a text file** — never touches the target, so it's **OSCP-allowed** (a suggester, not an exploit tool).

## Use it
1. On the target: run `systeminfo`, copy the **whole** output.
2. On Kali: save it to a file, e.g. `~/labs/<box>/loot/systeminfo.txt`.
3. Run:
```bash
wes --definitions ~/tools/wesng/definitions.zip ~/labs/<box>/loot/systeminfo.txt -i "Elevation of Privilege" --exploits-only
```
- `--definitions ~/tools/wesng/definitions.zip` → where the CVE DB lives (always the same; it's outside the vault so you pass the path).
- `-i "Elevation of Privilege"` → privesc only (exact spelling — it's a substring match, a typo silently matches nothing).
- `--exploits-only` → show only CVEs with public exploit code (cuts the noise hard).

## Read the output right
- The list is **candidates, not confirmed hits** — WES-NG doesn't test anything. It just lists every vuln that could affect this build given the **missing** patches.
- If `Installed hotfixes: None`, it assumes *nothing* is patched and dumps everything — expect a long list.
- **Skip `Exploit: n/a`** (no public code). Go for entries with an `Exploit:` link, then verify by trying.

## Setup (already done on `kali`)
- Installed via **pipx** (not apt/pip — pip is blocked system-wide on Kali): `pipx install wesng` → `~/.local/bin/wes`.
- CVE DB staged at `~/tools/wesng/definitions.zip`. Refresh occasionally:
```bash
cd ~/tools/wesng && wes --update    # drops definitions.zip in CWD — run from here to keep it out of the vault
```

## Related
- [[Potato_Attacks]] · [[Windows_Priv_Esc]] · [[SearchSploit]]
