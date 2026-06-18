# AD Username Generation — Building a Wordlist from Names

## Why This Matters

Active Directory accounts follow predictable naming conventions.
When you find **real employee names** (About Us page, LinkedIn, email signatures, etc.) but don't know the actual AD username format — generate all common variations and test them.

One valid username lets you:
- ASREPRoast to get a hash without credentials
- Password spray with common/default passwords
- Confirm the domain's naming convention for all future guesses

---

## Common AD Username Formats

Given a name like **Fergus Smith**:

| Format | Example |
|--------|---------|
| firstname | fergus |
| lastname | smith |
| firstnamelastname | fergussmith |
| f+lastname | fsmith |
| firstname.lastname | fergus.smith |
| firstname-lastname | fergus-smith |
| lastname+firstinitial | smithf |
| l+firstname | sfergus |
| firstname+lastinitial | ferguss |

Most corporate AD environments use one of: `fsmith`, `fergus.smith`, or `fergussmith`.
The fastest way to find the format is to test all variations — let the DC tell you which one exists.

---

## Tool: username-anarchy

`username-anarchy` generates all common username permutations from a list of names.

```bash
# Install
sudo apt install username-anarchy -y

# Generate from a single name
username-anarchy Fergus Smith

# Generate from a file of "First Last" names (one per line)
username-anarchy -i names.txt > users.txt
```

`names.txt` example:
```
Fergus Smith
Hugo Bear
Shaun Coins
Steven Kerb
Sophie Driver
Bowie Taylor
```

Output covers: `fergus`, `fsmith`, `fergus.smith`, `smith.fergus`, `sfergus`, etc.

---

## Manual Python One-Liner

If username-anarchy isn't available, generate quickly with Python:

```python
#!/usr/bin/env python3
names = [
    ("Fergus", "Smith"),
    ("Hugo", "Bear"),
    ("Shaun", "Coins"),
]

for first, last in names:
    f, l = first.lower(), last.lower()
    print(f)
    print(l)
    print(f"{f}{l}")
    print(f"{f[0]}{l}")
    print(f"{f}.{l}")
    print(f"{f}-{l}")
    print(f"{l}{f[0]}")
    print(f"{l[0]}{f}")
```

```bash
python3 gen_users.py > users.txt
```

---

## Validate Usernames Against the DC

Use nxc with Kerberos (`-k`) to check which usernames actually exist.
Kerberos returns `KDC_ERR_C_PRINCIPAL_UNKNOWN` for invalid users and a hash (or different error) for valid ones.

```bash
netexec ldap <DC_IP> -u users.txt -p "" -k
```

> `/etc/hosts` must have the domain mapped first. See [[Active_Directory_Attacks]].

Valid user with pre-auth disabled → `[+] account vulnerable to asreproast attack`
Valid user with pre-auth enabled → different error (not `C_PRINCIPAL_UNKNOWN`)
Invalid user → `KDC_ERR_C_PRINCIPAL_UNKNOWN`

---

## Kerbrute (Username Enumeration Only)

`kerbrute` is faster for pure username validation — it doesn't need a password, just tests if the account exists.

```bash
kerbrute userenum -d DOMAIN.LOCAL --dc <DC_IP> users.txt
```

---

## Where to Find Names

- **Company website** — About Us, Meet the Team, Leadership, Contact pages
- **LinkedIn** — search the company + filter by employees
- **Email footers** — often expose the naming convention directly (e.g. `fsmith@company.com`)
- **Job postings** — sometimes include hiring manager names
- **Google dorking** — `site:company.com filetype:pdf` often surfaces employee names in documents

Once you find **one valid credential** or confirm the naming format → generate a clean targeted list and stop guessing.

---

## Related Notes

- [[Active_Directory_Attacks]]
- [[NetExec]]
- [[Password_Spraying]]
- [[Suana]] ← Sauna HTB — real example of this technique leading to ASREPRoast
