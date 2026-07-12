# Claude Code — Session Guide for Kali

## Who I Am
I am studying for the OSCP. I use this machine (Kali Linux) for labs, CTFs, and building my notes vault. When I ask questions about commands, tools, or techniques, frame answers in an OSCP/pentesting context.

---

## My OSCP Notes Vault

**Local vault:** `/home/nepps1/OSCP-Notes/`
**GitHub repo:** `https://github.com/neppsypepsi/OSCP-Notes.git`

The vault is an Obsidian markdown vault. All files are `.md`. Always edit files directly in the local vault path above.

### Vault Structure
```
OSCP-Notes/
├── 01_Enumeration/      # Finding things — nmap, gobuster, SMB enum, web enum
├── 02_Exploitation/     # Getting initial access — LFI, RFI, web attacks, reverse shells
├── 03_Post-Exploitation/# After shell — Linux privesc, file transfer, common commands
├── 04_Services/         # One file per service/protocol — FTP, SMB, MySQL
├── 05_Tools/            # Pure tool references — Burp, Hydra, Hashcat, Netcat
├── 06_Windows/          # Windows-specific — privesc, PowerShell, Mimikatz, Ligolo
├── 07_Attack-Chains/    # Full attack chain walkthroughs
├── 08_Labs/             # Lab notes
│   └── PG-Practice/
├── scripts/             # Synced tooling — oscp-toolcheck.sh (the /lab checklist) + SETUP-lab-command.md (bootstraps /lab on a new machine)
├── Attack-Workflow.md   # Master playbook — Step 0 through root
├── When_In_Doubt.md     # Methodology Q&A reference
├── CLAUDE.md
├── Session-Guide-Boxes.md
├── VPN-Connections.md
└── Welcome.md
```

---

## How to Update Notes

1. **Edit files directly** in `/home/nepps1/OSCP-Notes/`
2. **Never create a new file** unless I explicitly ask for one
3. **Match the existing style** — short descriptions after `→`, code blocks for commands, `---` section dividers
4. After edits, **remind me to push to GitHub** if I haven't already

### Pushing to GitHub
```bash
cd /home/nepps1/OSCP-Notes
git add -A
git commit -m "update notes"
git push
```

> If the vault has no git remote set up, clone fresh from the repo and work from there:
> ```bash
> git clone https://github.com/neppsypepsi/OSCP-Notes.git /home/nepps1/OSCP-Notes
> ```

---

## Finding My Notes (Don't Ask — Just Look)

- Check GitHub CLI: `gh repo list neppsypepsi`
- Vault is always at `/home/nepps1/OSCP-Notes/`
- Read files with the Read tool before editing — never edit blind

---

## Helping With OSCP Boxes and Labs

Read `/home/nepps1/OSCP-Notes/Session-Guide-Boxes.md` at the start of any session involving an OffSec lab or PG Practice machine. That file defines exactly how to assist — follow it strictly.

The short version:
- Do not search for exploits or suggest attack chains unprompted
- Recommend the next logical step based on confirmed enumeration data only
- Explain every command before suggesting it
- Let me identify the CVE — then help me understand and execute it

---

## Essential Tools Checklist

Before starting any lab session, verify these are present. Missing any of these can block an attack chain.

> **⚠️ Install status is PER-MACHINE — do not share it across machines.** Whether a tool is installed depends on the specific box you are on. If this Claude session is running on a *different* machine than the one logged below, **re-run the checks locally** and log that machine separately. Never assume another machine's results apply here — that's how you end up thinking a tool is present when it isn't.
>
> **Log discipline: keep AT MOST 4 dated entries here.** When adding a 5th, delete the oldest so this section never overflows. One entry per machine — if a machine is re-checked, update its existing entry in place (new date) rather than adding another.
>
> **Why this log exists (read before trusting it):** each dated entry is a stamp meaning *"this exact machine — matched by hostname — was verified all-clear on this date."* If your hostname matches an entry and nothing's changed, trust it and skip re-staging. If your hostname isn't listed, treat this machine as unverified: run the checklist and add your own entry. Never apply another machine's entry to yours.
>
> **Machines checked:**
> - **`Defalt` (Kali 2026.1), user `nepps1` — fully checked 2026-07-11.** All tools now present. `feroxbuster` + `ligolo-ng` installed via apt (`ligolo-ng` provides the `ligolo-proxy` and `ligolo-agent` binaries — there is no `ligolo-ng` binary). `pspy` 403'd from `kali.download` (same mirror issue as the `kali` box), so it was staged as a GitHub static binary → `/home/nepps1/tools/pspy/pspy64` (v1.2.1, `chmod +x` done). SecLists + plaintext rockyou.txt both present.
> - **`kali` (Kali 2026.2), user `nepps1` — fully checked 2026-07-12 (all clear, 26/26).** Every tool + wordlist present. `pspy` and `ligolo-ng` are not from apt (the `kali.download` mirror 403'd on 2026-07-10) — both staged as GitHub static binaries under `/home/nepps1/tools/`:
>   - `pspy` → `/home/nepps1/tools/pspy/pspy64` — `chmod +x` set 2026-07-12 (had no execute bit, so the checklist read it as MISSING until fixed)
>   - `ligolo-ng` → `/home/nepps1/tools/ligolo/{proxy, agent_linux, agent_windows.exe}`

### Core Recon
| Tool | Check | Install if missing |
|---|---|---|
| `nmap` | `which nmap` | `apt install nmap` |
| `gobuster` | `which gobuster` | `apt install gobuster` |
| `feroxbuster` | `which feroxbuster` | `apt install feroxbuster` |
| `ffuf` | `which ffuf` | `apt install ffuf` |
| `enum4linux` | `which enum4linux` | `apt install enum4linux` |
| `smbclient` | `which smbclient` | `apt install smbclient` |
| `nikto` | `which nikto` | `apt install nikto` |

### Exploitation
| Tool | Check | Install if missing |
|---|---|---|
| `msfconsole` / `msfvenom` | `which msfvenom` | `apt install metasploit-framework` |
| `searchsploit` | `which searchsploit` | `apt install exploitdb` |
| `python3-venv` | `python3 -m venv --help` | `apt install python3-venv` |
| `sqlmap` | `which sqlmap` | `apt install sqlmap` |
| `hydra` | `which hydra` | `apt install hydra` |
| `burpsuite` | `which burpsuite` | `apt install burpsuite` |

> **Python PoC needs `pip install`?** Modern Kali blocks system-wide pip (`externally-managed-environment`). Use a venv — full enable/install/disable lifecycle is in `05_Tools/Python_venv.md`.

### Post-Exploitation & Privesc
| Tool | Check | Install if missing |
|---|---|---|
| `linpeas` | `which linpeas` | `apt install peass` |
| `winpeas` | `which winpeas` | `apt install peass` |
| `pspy` | `which pspy` | `apt install pspy` |

> **PEASS files live at `/usr/share/peass/`** — always serve from there, never from stale copies elsewhere.
> - Linux target: `/usr/share/peass/linpeas/linpeas.sh`
> - Windows 64-bit: `/usr/share/peass/winpeas/winPEASx64.exe`
> - Windows any arch: `/usr/share/peass/winpeas/winPEASany.exe`
> - No .exe execution: `/usr/share/peass/winpeas/winPEAS.bat`
| `evil-winrm` | `which evil-winrm` | `gem install evil-winrm` |
| `impacket-psexec` | `which impacket-psexec` | `apt install python3-impacket` |
| `impacket-secretsdump` | `which impacket-secretsdump` | `apt install python3-impacket` |
| `john` | `which john` | `apt install john` |
| `hashcat` | `which hashcat` | `apt install hashcat` |

### Credential / Network
| Tool | Check | Install if missing |
|---|---|---|
| `netexec` (replaces crackmapexec) | `which netexec` | `apt install netexec` |
| `bloodhound-python` | `which bloodhound-python` | `pip3 install bloodhound` |

### Tunneling / Pivoting (CRITICAL for multi-hop labs)
| Tool | Check | Install if missing |
|---|---|---|
| `ligolo-ng` | `which ligolo-proxy` | `apt install ligolo-ng` |

> ligolo-ng is the current standard for OSCP pivoting. It creates a TUN interface on Kali so all tools work transparently on the routed network — no proxychains needed.

### Wordlists

> **MUST-HAVE — verify BEFORE any lab.** Both of these were confirmed **missing** on a fresh Kali (2026-06-30): SecLists is not installed by default, and `rockyou.txt` ships gzipped so the plaintext path does not exist until you decompress it. Fix both up front — a missing wordlist silently breaks brute-force / fuzzing chains mid-attack.

| Resource | Path | Fix if missing |
|---|---|---|
| SecLists | `/usr/share/seclists/` | `sudo apt install seclists -y` |
| rockyou.txt | `/usr/share/wordlists/rockyou.txt` | `gunzip /usr/share/wordlists/rockyou.txt.gz` (removes the `.gz`, leaves plaintext) |

> **Fallback dir-bust list (always present on Kali):** `/usr/share/wordlists/dirb/common.txt` — use if SecLists isn't installed yet.

> **Burp Intruder file-picker hangs (infinite spinner)?** Burp's Java file chooser stalls on huge dirs — `/usr/share/seclists/` has ~6,000+ files, so browsing it locks up. Fix: keep a small **Burp-friendly copy** of just the lists you need in `/home/nepps1/wordlists/` and load from there. Do NOT move the SecLists files out of `/usr/share` — that breaks gobuster/hydra/ffuf paths; **copy** only.
> - SQLi login-bypass lists (for MySQL web logins): `/home/nepps1/wordlists/SQLi/` — key file `MySQL-SQLi-Login-Bypass.fuzzdb.txt`.

### Quick install for common gaps
```bash
apt install ligolo-ng peass netexec seclists -y
gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null   # decompress rockyou if still gzipped
```

---

## My Preferences

- **No fluff** — keep explanations concise and practical
- **OSCP context always** — explain why something matters in a pentest, not just what it does
- **Keep tool/technique notes lean** — just the necessary info. Don't pad them with box-specific walkthrough examples unless I explicitly ask
- **Don't create files I didn't ask for**
- **Ask before deleting anything**
- When I ask to improve or add to a note, **preserve all existing content** — only add, don't remove unless I say so
- When Obsidian doesn't show changes, remind me to press `Ctrl+P` → "Reload app without saving" or restart Obsidian
