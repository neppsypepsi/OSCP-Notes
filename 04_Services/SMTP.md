# SMTP — Port 25

---

## When It Shows Up

Nmap shows `25/tcp open smtp` (Postfix / Exim / Sendmail). On OSCP, SMTP is almost never exploited directly — it's a **username enumeration** service. You use it to build a list of valid users, then take those usernames elsewhere (SSH brute-force, web login, password reset).

Check the nmap `smtp-commands` line — if it advertises **`VRFY`** or **`EXPN`**, enumeration is on the table.

---

## The Three Enumeration Verbs

| Command | Asks | Valid user | Invalid user |
|---|---|---|---|
| `VRFY bob` | "Is `bob` a real user?" | `250` / `252` | `550` |
| `EXPN list` | "Expand this mailing list" | member addresses | error |
| `RCPT TO:<bob>` | (inside a `MAIL FROM` transaction) | `250` | `550` |

`RCPT TO` is the fallback when `VRFY`/`EXPN` are disabled — the server still has to say whether it'll accept mail for that user, which leaks the same info.

---

## Manual Session

```bash
nc -nv <IP> 25          # or: telnet <IP> 25
```

```
EHLO x                  # greet; lists supported commands
VRFY root
250 2.0.0 root          # <-- exists
VRFY nonexistentuser
550 5.1.1 <nonexistentuser>: Recipient address rejected: User unknown   # <-- does not exist
```

The **difference** between the two responses is the whole game — that's how you separate real users from noise.

RCPT-based check when VRFY is off:
```
MAIL FROM:<test@test.com>
RCPT TO:<bob>
```

---

## Automated

```bash
smtp-user-enum -M VRFY -U users.txt -t <IP>     # -M mode: VRFY, EXPN, or RCPT
nmap -p25 --script smtp-enum-users,smtp-commands,smtp-open-relay <IP>
```

Username wordlists:
```
/usr/share/seclists/Usernames/top-usernames-shortlist.txt
/usr/share/seclists/Usernames/Names/names.txt
```

---

## What to Do With Found Users

- Brute-force SSH with the usernames (`hydra`)
- Try them against any web login on the box
- Feed them into password-reset / login-enumeration flows

---

## Edge Cases (Know They Exist)

- **Open relay** — will it relay mail to an external domain? Rare on OSCP. Test with `smtp-open-relay` or manual `MAIL FROM` / `RCPT TO` to an outside address.
- **STARTTLS** — session can go encrypted, but plaintext enumeration still works.
- **Version CVEs** — matter for old **Exim / Sendmail**, generally *not* Postfix (hardened). Confirm the version before hunting an exploit.
- **Domain leak** — the SMTP banner / TLS cert CN often exposes a domain name. Feed it into [[Vhost_Enum]].

---

## Related Notes

- [[Vhost_Enum]]
- [[SSH]]
- [[Web_Enum]]
