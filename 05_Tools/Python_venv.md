# Python venv — Running PoCs That Need `pip install`

→ Many GitHub exploits need extra Python libraries (`pip3 install -r requirements.txt` or `pip install <pkg>`). On current Kali, installing those system-wide **fails** — you isolate them in a venv instead, then throw it away when done.

---

## Why You Need This

Modern Kali blocks system-wide pip with:
```
error: externally-managed-environment
```
This is PEP 668 — the OS protects its own Python packages. A **venv** is a throwaway sandbox: pip installs go *inside it*, never touching your system Python. Enter it to install/run, leave it when finished.

> This is **opt-in**. Your normal terminal is the default state. You only step into a venv when a PoC needs dependencies.

---

## Lifecycle (Enable → Use → Disable)

```bash
# 1. CREATE the sandbox (once per exploit/project)
python3 -m venv ~/exploit-venv

# 2. ENABLE — step into it (prompt changes to (exploit-venv))
source ~/exploit-venv/bin/activate

# 3. INSTALL deps inside it
pip install -r requirements.txt        # or: pip install <package>

# 4. RUN the exploit (while still inside the venv)
python3 exploit.py --master <TARGET>

# 5. DISABLE — return to normal
deactivate
```

---

## Understanding What Each State Means

| Action | What actually happens |
|---|---|
| `source .../activate` | Enter sandbox — pip + python now point inside the venv |
| `deactivate` | Leave sandbox — back to system Python. **Nothing is deleted** |
| Open a new terminal tab | Automatically "normal" — venvs are per-shell |
| `source .../activate` again | Re-enters the *same* venv; installed packages are still there — no reinstall |
| `rm -rf ~/exploit-venv` | The only true "uninstall" — removes the sandbox + everything in it |

Key idea: **`deactivate` ≠ delete.** The venv folder stays on disk; you just step out of it. There is nothing polluting your system to clean up — that's the whole point.

---

## If `python3 -m venv` Fails

The venv module may not be installed:
```bash
sudo apt install python3-venv -y
```

---

## Naming Tip

Name the venv after the job so you can find it later:
```bash
python3 -m venv ~/salt-venv        # for the Salt exploit
python3 -m venv ~/impacket-venv    # for an impacket-based PoC
```

---

## Related Notes

- [[GitHub_Repos]] — cloning PoCs (their `requirements.txt` step needs this venv)
- [[SearchSploit]]
- [[ReverseShells]]
