# Virtual Host / Subdomain Enumeration

Directory busting changes the **path** (`/admin`). Vhost busting changes the **`Host:` header** — one IP serves many sites, picked by `Host`. A dir scan never finds another vhost. **Run both.**

On OSCP/PG use **Host-header fuzzing** (boxes have no real DNS, so `gobuster dns` is usually a dead end).

---

## Where Domains Leak (Your Cue to Fuzz)

The trigger is: **any service echoes a hostname/domain.** 

- **TLS cert CN / SAN — on ANY port**, not just 443: HTTPS, SMTP STARTTLS (25/465/587), IMAPS/POP3S, RDP (3389), LDAPS.
- **Service banners** repeating the FQDN: 
- **HTTP redirect** to a hostname (`301/302 Location:`):
  ```bash
  curl -I http://<IP>                            # check Location header
  ```
- **HTTP page content** — links, emails, cookie Domain=, canonical tags:
  ```bash
  curl -s http://<IP> | grep -Eo '[a-z0-9.-]+\.(com|net|local|htb)'
  ```
  > This only finds hostnames **literally written in the source**. Always view-source / read the raw HTML too — the useful one often hides in an `href` (e.g. a **Login button** → `<a href="http://teams.onlyrands.com">`) that the rendered page buries behind a button. Ignore external CDNs in the output (`fonts.googleapis.com`, etc.).
- **Port 53 open → zone transfer** dumps all subdomains directly, no fuzzing:
  ```bash
  dig axfr @<IP> onlyrands.com
  ```

> Sources 1–4 give a **base domain** → then fuzz subdomains. A zone transfer hands you the subdomains outright.

---

## Step 1 — Map the domain in /etc/hosts

```bash
echo "<TARGET_IP> onlyrands.com" | sudo tee -a /etc/hosts
```
- Don't take emails that you may find on a web page that look like it could hint to what the host name could be for an IP for granted.

---

## Step 2 — Fuzz the Host header

```bash
ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u http://<TARGET_IP> -H "Host: FUZZ.hostname.com" -fs <default_page_size>
```
`-fs` filters out the default page (every fake vhost returns it) so real vhosts stand out. If noisy, filter words `-fw` or lines `-fl` instead.

**Getting `<default_page_size>` — two reliable ways:**
1. Ask for a vhost that definitely doesn't exist and measure the catch-all response:
   ```bash
   curl -s -H "Host: nope123.onlyrands.com" http://<IP> | wc -c
   ```
2. Look at the **Size** column: the value thats the most common→ plug it into `-fs` and re-run.

```bash
gobuster vhost -u http://hostname.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt --append-domain
```

**Every Host returns same 301/302, Size 0?** `-fs` fails (real vhost redirects too). Follow the redirect:
```bash
ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u http://<IP> -H "Host: FUZZ.hostname.com" -r -ac
gobuster vhost -u http://<IP> -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt --append-domain --exclude-length 0
```

Got a hit → add it to `/etc/hosts` (own explicit entry, no wildcards) so you can browse to it on the web

---

## Step 3 — Browse the vhost

Add to `/etc/hosts`, then dir-bust the **new** vhost:
```bash
gobuster dir -u http://teams.onlyrands.com -w /usr/share/dirb/wordlists/common.txt -x php,txt,bak
```

---

## Related Notes

- [[Web_Enum]]
- [[SMTP]]
