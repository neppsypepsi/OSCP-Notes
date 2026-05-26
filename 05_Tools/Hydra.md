# Hydra — Credential Brute Force (OSCP)

Hydra brute forces **login services** by trying username/password combinations automatically.

> **Important:** For JSON-based login APIs (modern web apps), Hydra often struggles with formatting.
> Use the Python `requests` approach instead — see [[Web_Login_Brute_Force]].

---

## When to Use Hydra

Use Hydra when:
- You have a list of usernames (or a single known username)
- You have a password list
- The service accepts repeated login attempts (no lockout)
- The login uses a **standard protocol** (SSH, FTP, RDP) or a **standard HTML form**

---

## General Syntax

```bash
hydra -l <single_user> -p <single_pass> <IP> <service>
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt <IP> <service>
```

- `-l` = single username
- `-L` = file of usernames
- `-p` = single password
- `-P` = file of passwords
- `-t` = number of threads (default 16, reduce if unstable)
- `-V` = verbose (show every attempt)
- `-f` = stop on first valid login found

---

## SSH Brute Force

```bash
hydra -L users.txt -P /usr/share/wordlists/rockyou.txt ssh://<IP>
```

Single user:
```bash
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://<IP>
```

With port:
```bash
hydra -l admin -P passwords.txt -s 2222 ssh://<IP>
```

---

## FTP Brute Force

```bash
hydra -L users.txt -P passwords.txt ftp://<IP>
```

---

## RDP Brute Force

```bash
hydra -L users.txt -P passwords.txt rdp://<IP>
```

---

## SMB Brute Force

```bash
hydra -L users.txt -P passwords.txt smb://<IP>
```

> For SMB, CrackMapExec / NetExec (`nxc`) is more reliable.

---

## HTTP Login Form (POST — Standard HTML Form)

First you need to know:
1. The form's action URL (e.g. `/login`)
2. The field names for username and password (view page source)
3. What text appears on a failed login

```bash
hydra -L users.txt -P passwords.txt <IP> http-post-form \
  "/login:username=^USER^&password=^PASS^:F=Invalid credentials"
```

With a port:
```bash
hydra -L users.txt -P passwords.txt -s 8080 <IP> http-post-form \
  "/login:username=^USER^&password=^PASS^:F=Invalid credentials"
```

Format breakdown:
```
"/path:field1=^USER^&field2=^PASS^:F=failure_text"
```
- `^USER^` = replaced with each username
- `^PASS^` = replaced with each password
- `F=` = text that appears on FAILURE (hydra skips these)

---

## HTTP Login Form (GET)

```bash
hydra -L users.txt -P passwords.txt <IP> http-get-form \
  "/login:username=^USER^&password=^PASS^:F=Invalid"
```

---

## JSON API Login (Hydra Limitation)

Hydra **cannot reliably** send JSON POST bodies with custom Content-Type headers.

If the login sends JSON (check the page source / JS files for `fetch()` or `XMLHttpRequest`):
→ Use the Python requests approach in [[Web_Login_Brute_Force]] instead.

---

## Useful Wordlists on Kali

| Wordlist | Use Case |
|----------|----------|
| `/usr/share/wordlists/rockyou.txt` | General passwords |
| `/usr/share/dirb/wordlists/common.txt` | Web directories |
| `/usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt` | Top 10k passwords |
| `/usr/share/seclists/Usernames/Names/names.txt` | Common usernames |

Install SecLists if missing:
```bash
sudo apt install seclists -y
```

---

## Related Notes

- [[Web_Login_Brute_Force]]
- [[Password_Spraying]]
- [[NetExec]]
- [[Web_Enum]]
