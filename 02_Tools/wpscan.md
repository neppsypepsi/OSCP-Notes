# WPScan — WordPress Security Scanner (OSCP)

## What is WPScan?

WPScan is a **WordPress-specific enumeration tool**.
Use it **any time nmap or a browser confirms a WordPress site**.
It finds installed plugins, themes, and users — all common attack surfaces on OSCP boxes.

> Do not use gobuster alone on a WordPress target. WPScan is purpose-built for this and finds things gobuster misses.

---

## When to Use

- nmap output shows `http-generator: WordPress`
- Browser shows a WordPress site
- Port 80/443 is open and gobuster finds `/wp-login.php` or `/wp-content/`

---

## Core Commands

### Enumerate Users + Vulnerable Plugins (Standard Starting Point)
```bash
wpscan --url http://<IP> -e u,vp --plugins-detection aggressive
```

| Flag | Meaning | Why |
|---|---|---|
| `-e u` | Enumerate users | Finds valid WordPress usernames via author ID brute force |
| `-e vp` | Vulnerable plugins only | Cross-references against WPScan CVE database — faster and more targeted than all plugins |
| `--plugins-detection aggressive` | Actively probe plugin paths | Passive detection reads page source only and misses most plugins |

### Enumerate All Plugins (Slower, Broader)
```bash
wpscan --url http://<IP> --enumerate ap --plugins-detection aggressive -t 50
```
→ Use if `vp` finds nothing. Brute-forces all 100k+ known plugin paths. Add `-t 50` to speed it up.

### Users Only
```bash
wpscan --url http://<IP> --enumerate u
```

---

## Passive vs Aggressive Detection

| Mode | What it does | When to use |
|---|---|---|
| Passive (default) | Reads page source for plugin fingerprints | Rarely useful — most plugins don't advertise themselves |
| Aggressive | Directly requests plugin paths on the server | Always use this for plugins |

> `--enumerate p` and `--enumerate ap` use passive by default. You must add `--plugins-detection aggressive` separately.

---

## What to Look For in Output

- **Plugin name + version** → look up on WPScan DB or searchsploit
- `[!] Title:` lines → confirmed CVEs attached to the installed version
- **Users identified** → save all of them, try credentials against FTP, SSH, wp-login
- WordPress version flagged as insecure → note but focus on plugins first

---

## Speed Tips

```bash
-t 50    # increase threads (default is 5)
```
→ Use when running `ap` scans — default thread count makes it very slow against 100k+ entries.

---

## Related Notes

- [[Web_Enum]]
- [[Hydra]]
- [[Web_Login_Brute_Force]]
