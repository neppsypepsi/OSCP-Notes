# Burp Suite — OSCP Reference

---

## What It Is

Burp Suite sits between your browser and the target as a proxy. Every HTTP request your browser makes passes through Burp first, giving you full visibility and control over the traffic.

Core value in OSCP:
- See every parameter being sent, including ones not visible in the browser
- Modify requests before they reach the server
- Replay and fuzz requests without retyping in the browser

---

## Setup — FoxyProxy + Burp

**In Burp:**
1. Proxy tab → Proxy settings → confirm listener is `127.0.0.1:8080`

**In Firefox (FoxyProxy):**
1. Click FoxyProxy icon → Proxies → Add
2. Title: `Burp`, Type: `HTTP`, Host: `127.0.0.1`, Port: `8080`
3. Save → click FoxyProxy icon → select Burp profile to activate

**Test it:** browse to the target — requests should appear in Burp → Proxy → HTTP history.

Turn FoxyProxy off when done to restore normal browsing.

---

## Proxy Tab

**HTTP history** — logs every request passively without stopping traffic. Leave Intercept off and use history to review what the browser sent.

**Intercept** — pauses each request mid-flight so you can read and modify it before forwarding. Turn it on only when you want to catch and edit a specific request. Your browser freezes until you forward or drop it.

When to use each:
- Browsing and reviewing → HTTP history (Intercept off)
- Modifying a specific request once → Intercept on, edit, forward, turn off
- Repeated testing with modifications → send to Repeater instead

---

## Repeater

Repeater lets you manually craft and resend HTTP requests as many times as you want, changing parameters between each send.

**How to load a request into Repeater:**
- In HTTP history, right-click any request → Send to Repeater
- Or open Repeater tab and type a request manually

**Layout:** Request panel on the left, Response panel on the right. Edit the request, hit Send, read the response.

**Key rule:** the GET line, Host header, and a blank line after the headers must all be correct or the server returns 400/408.

Correct format:
```
GET /image.php?img=../../../../../etc/passwd HTTP/1.1
Host: 192.168.213.58
User-Agent: Mozilla/5.0
Connection: keep-alive

```
The blank line after `Connection: keep-alive` is required.

**Common OSCP uses:**
- Testing LFI payloads — change the `img=` value and resend without touching the browser
- Log poisoning — change User-Agent to PHP payload, send, then switch back and include the log
- Modifying POST parameters for login bypass or injection
- Fuzzing file paths without scripting

---

## Intruder — Automated Fuzzing / Brute Force

Intruder takes one request and resends it many times, substituting values from a **payload set** (a wordlist) into positions you mark. Main OSCP use: fuzzing login forms for SQLi auth bypass, and parameter brute forcing.

### Workflow
1. In the browser, **submit the form with junk creds** (e.g. `admin`/`test`). This generates the **POST** request that actually carries `username=...&password=...`. (Just reloading the page only captures the GET — useless here.)
2. Proxy → HTTP history → right-click that POST → **Send to Intruder**.
3. Intruder → **Positions** tab → click **Clear §** (it auto-marks everything).
4. Mark only the field(s) you want to fuzz (see markers below).
5. **Payloads** tab → load your wordlist → **Start attack**.
6. Read the results (see "Spotting a hit" below).

### Payload position markers — the `§` (section sign)

The `§` markers tell Intruder **where** to insert each payload. Placement matters:

- **Wrap a selection** (select the value → **Add §** → `§admin§`) → each payload **replaces** the whole selection. Field becomes *just the payload*.
- **Place at a single point** (select nothing, click **Add §** → `§§`) → each payload is **inserted at that exact spot**, surrounding text stays. So `admin§§` becomes `admin` + payload (appended).

Which to use depends on your wordlist format:
- Lines are **complete field values** (`' or 1=1 -- -`) → **wrap** the field (replace).
- Lines are **tails** meant to follow a known username → type `admin`, mark right after it (`admin§§`) so each payload **appends** → `admin' or 1=1 -- -`.

### Attack types

| Type | Payload sets | Behavior |
|---|---|---|
| **Sniper** | 1 | One position at a time. With two marked fields, it fuzzes username (password fixed), then fuzzes password (username fixed) — never both at once. Best with a small list, or when you already know one field (delete the other field's marker so only one is fuzzed → much faster). |
| **Battering ram** | 1 | Puts the **same** payload into **all** marked positions at once. Use when username and password should be identical (e.g. the Cockpit query reuses one value for both). |
| **Pitchfork** | multiple (1 per position) | Walks lists in parallel — payload set 1 → position 1, set 2 → position 2, in lockstep. Use with paired username:password lists. |
| **Cluster bomb** | multiple (1 per position) | Tries **every combination** across all lists. Use for true cred brute forcing (every user × every password). |

> A "payload set" is just a wordlist assigned to a position.

### Spotting a hit

Results appear **right in Intruder** — you don't need to retype on the page. Sort the table by:
- **Status code** — a successful login bypass is often a **302 redirect** to a dashboard.
- **Length** — the winning response is usually a different size than the failures.
- Optionally add a **Grep – Match** rule (Options tab) on a string like `invalid` / `welcome` to flag the row automatically.

To actually *use* the access, reproduce the winning payload in the browser login form so your browser gets the authenticated session cookie.

> SQLi auth-bypass workflow and local wordlist paths: **[[SQL_Injection]]**.

---

## Target Tab — Site Map

Burp builds a site map from all proxied traffic. Found under Target → Site map.

Shows every URL, file, and parameter Burp has seen. Useful for finding paths that gobuster missed — if the browser loaded it, Burp logged it.

---

## Decoder Tab

Encode and decode strings — base64, URL encoding, HTML encoding, hex.

```
Paste string → select encoding type → Decode/Encode
```

Useful for decoding base64 blobs found in responses without switching to the terminal.

---

## Raw vs Pretty View

- **Pretty** — formatted, readable. Cannot edit directly.
- **Raw** — editable plain text. Use this for Repeater modifications.

Always switch to Raw before editing a request in Repeater.

---

## Related Notes

- [[LFI_RFI]]
- [[Web_Enum]]
- [[ReverseShells]]
- [[SQL_Injection]]
