# GitHub Repos — Pulling and Navigating (OSCP Context)

## When to Use GitHub in a Pentest

- You identified a CVE and need a PoC exploit
- You found a version number and want to check if a public exploit exists
- You need a tool or script not installed on Kali by default

**Workflow:** You find the CVE first → then search GitHub for a PoC. Never the other way around.

---

## Searching GitHub for Exploits

Go to `github.com` and search:

```
CVE-2021-XXXX PoC
PDFKit exploit
<software> <version> exploit
```

What to look for in results:
- Stars → more stars usually means more tested/reliable
- Recent commits → maintained and likely working
- README that explains usage clearly
- Issues tab → check if people report it working or broken

---

## Cloning a Repo

```bash
git clone <repo-url>
```

Example:
```bash
git clone https://github.com/user/CVE-2021-12345.git
```

This downloads the entire repo into a folder in your current directory.

**Best practice — clone into your working directory:**
```bash
cd ~/Desktop
git clone https://github.com/user/exploit.git
cd exploit
```

---

## Navigating a Repo After Cloning

```bash
# See all files in the repo
ls -la

# Read the README first — always
cat README.md

# Find the main script
ls *.py
ls *.sh
ls *.rb
```

### Key files to look for:

| File | What it is |
|---|---|
| `README.md` | Usage instructions — read this first |
| `exploit.py` | Main exploit script |
| `requirements.txt` | Python dependencies needed |
| `setup.sh` | Setup script — read before running |
| `*.rb` | Metasploit module |

---

## Installing Dependencies

If the exploit needs Python libraries:
```bash
pip3 install -r requirements.txt
```

If it's a bash script:
```bash
chmod +x exploit.sh
```

---

## Running the Exploit

Always read the README first. Most PoCs follow this pattern:

```bash
python3 exploit.py <target-ip> <port>
python3 exploit.py --url http://192.168.x.x:3000
```

Check the top of the script for usage:
```bash
head -30 exploit.py
```

---

## Checking Commit History

If you want to understand what changed or when something was added:
```bash
git log --oneline
```

---

## Related Notes

- [[SearchSploit]]
- [[ReverseShells]]
- [[Netcat]]
