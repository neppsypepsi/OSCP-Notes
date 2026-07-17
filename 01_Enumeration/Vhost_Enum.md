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
After finding a vhost, append it to the same line: `<TARGET_IP> onlyrands.com teams.onlyrands.com`

> Entries are permanent — clean up stale ones between boxes (`sudo nano /etc/hosts`), the target IP changes each session.

---

## Step 2 — Fuzz the Host header

```bash
ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
     -u http://<TARGET_IP> \
     -H "Host: FUZZ.onlyrands.com" \
     -fs <default_page_size>
```
`-fs` filters out the default page (every fake vhost returns it) so real vhosts stand out. Get the size from `curl -s http://<IP> | wc -c`. If noisy, filter words `-fw` or lines `-fl`.

```bash
gobuster vhost -u http://onlyrands.com \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt --append-domain
```

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
