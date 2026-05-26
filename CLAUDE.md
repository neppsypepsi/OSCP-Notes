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

## My Preferences

- **No fluff** — keep explanations concise and practical
- **OSCP context always** — explain why something matters in a pentest, not just what it does
- **Don't create files I didn't ask for**
- **Ask before deleting anything**
- When I ask to improve or add to a note, **preserve all existing content** — only add, don't remove unless I say so
- When Obsidian doesn't show changes, remind me to press `Ctrl+P` → "Reload app without saving" or restart Obsidian
