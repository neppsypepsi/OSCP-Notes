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
| nmap finds an **open HTTP proxy on the target** (e.g. Squid on 3128) → browse its localhost-bound apps | **FoxyProxy** → HTTP `<target-ip>:3128` |

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

## Setup — open HTTP proxy ON the target (Specific Port)

When nmap shows a **open HTTP proxy** on the box itself (something like: `3128/tcp open http-proxy Squid`), the proxy runs *on the target*, so it can reach services that would be accessible to that host's **localhost / internal interfaces**. These are ports your external nmap never sees. Just point FoxyProxy straight at it:

```bash
#You will first open foxyproxy. Open options -> Proxies -> Add then set 


Title:        target-httpproxy
Proxy Type:   HTTP
Hostname:     <target-ip>     ← the TARGET, not 127.0.0.1
Port:         3128            ← the open-proxy port from nmap
```

> **Key difference from the Burp profile:** here the **Hostname is the remote target**, not `127.0.0.1`. The proxy you're abusing lives on the box, so every request you make gets fetched *from the box's perspective*.

With the profile on, browse to the box's own services as the box sees them — e.g. `http://127.0.0.1:8080/` or `http://<target-ip>:8080/` — to reach internal-only apps (WAMP, phpMyAdmin, etc.).

> **Don't guess ports — enumerate them.** Before browsing, port-scan the box's localhost *through* the proxy from the CLI (curl `-x` loop / `spose`) to list which internal ports actually answer, then browse only the live ones. See the `for`-loop recipe in [[Linux_Common_Commands]] (**Probing Ports Through an Open HTTP Proxy**).

---

## Quick toggle habit

- One click on the icon switches profiles — keep **burp**, **pivot-socks**, and **off** ready.
- **Symptom you left it on:** normal internet/box pages stop loading → you're still pointed at a dead proxy. Switch to off.

---

## Related Notes

- [[Chisel]]
- [[Ligolo]]
- [[SQL_Injection]]
- [[Linux_Common_Commands]] — CLI port-probe through an open proxy
