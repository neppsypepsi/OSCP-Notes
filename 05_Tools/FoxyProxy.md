# FoxyProxy — Route the Browser Through a Proxy (OSCP)

Firefox extension that sends **browser traffic** through a SOCKS/HTTP proxy. In OSCP you use it to **browse an internal web app** that you can only reach through a pivot (a SOCKS tunnel from [[Chisel]] or [[Ligolo]]) or through Burp.

> **FoxyProxy ≠ proxychains.** FoxyProxy proxies the **browser only**; [[Chisel]]/proxychains proxies **CLI tools** (nmap, curl, netexec). Same tunnel, two different clients — pick the one for the traffic you're sending.

---

## When you need it (and when you don't)

| Situation | Use |
|---|---|
| Plain **port-forward** (`R:8082:127.0.0.1:8080`) → app is at `http://127.0.0.1:8082` | **Nothing** — browse it directly, no proxy |
| Reach a **range of internal web hosts** via a SOCKS tunnel (`R:1080:socks`) | **FoxyProxy** → SOCKS5 `127.0.0.1:1080` |
| Route the browser through **Burp** to intercept | **FoxyProxy** → HTTP `127.0.0.1:8080` |

---

## Setup — SOCKS proxy (pivot)

1. FoxyProxy icon → **Options** → **Add**.
2. Fill in:
   ```
   Title:        pivot-socks
   Proxy Type:   SOCKS5
   Hostname:     127.0.0.1
   Port:         1080          ← match your chisel/ligolo SOCKS port
   ```
3. Save. Click the FoxyProxy icon → select **pivot-socks** to turn it on (toolbar icon shows the active profile).
4. Browse the internal host by IP: `http://10.10.20.5/`.
5. Flip back to **Turn Off / Use Enabled Proxies By Patterns** when done, or direct traffic breaks.

> **SOCKS5 + remote DNS:** SOCKS5 resolves DNS through the proxy (target-side), so internal hostnames resolve correctly. SOCKS4 does not — prefer SOCKS5 for pivots.

---

## Setup — Burp proxy (intercept)

```
Title:        burp
Proxy Type:   HTTP
Hostname:     127.0.0.1
Port:         8080
```
→ Toggle **burp** on, then all browser traffic flows through Burp Proxy → HTTP history. See [[SQL_Injection]] (Part 1 — Burp).

---

## Quick toggle habit

- One click on the icon switches profiles — keep **burp**, **pivot-socks**, and **off** ready.
- **Symptom you left it on:** normal internet/box pages stop loading → you're still pointed at a dead proxy. Switch to off.

---

## Related Notes

- [[Chisel]]
- [[Ligolo]]
- [[SQL_Injection]]
