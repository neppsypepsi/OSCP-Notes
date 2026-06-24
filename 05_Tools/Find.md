# Find — Locating Files by Attribute (OSCP)

`find` searches for **files themselves** by name, type, permissions, owner, size, or modify-time — not their contents (that's [[Grep]]). The everyday tool for flag hunting, spotting SUID binaries, and finding writable/recently-changed files during privesc.

> **find vs grep:** `find` searches by **file attributes** (what a file *is* — its name, perms, age). `grep` searches **inside** files (what a file *says*). Library analogy: `find` = search by book title; `grep` = search by the words on the pages.

---

## Core Options

| Option | Meaning |
|---|---|
| `-name "*.conf"` | Match by filename / extension (case-sensitive; `-iname` = case-insensitive) |
| `-type f` / `-type d` | Restrict to **f**iles or **d**irectories |
| `-perm -4000` | Match by permission bits — `-4000` = SUID set |
| `-writable` | Files **you** can write to |
| `-user root` | Files **owned** by a given user |
| `-mtime -1` | Modified in the last 1 day (`-mmin -10` = last 10 min) |
| `-size +10M` | Larger than 10 MB (`-` for smaller) |
| `-exec ... {} +` | Run a command on each match (`{}` = the file) |
| `2>/dev/null` | Suppress "Permission denied" noise (not a find flag — shell redirect) |

---

## Commands

```bash
find / -name "local.txt" 2>/dev/null
find / -name "proof.txt" 2>/dev/null
```
→ Hunt the OffSec flag files across the whole filesystem. `2>/dev/null` hides the permission-error spam so the real hit stands out.

```bash
find / -name "*.conf" -o -name "*.bak" 2>/dev/null
```
→ Locate config and backup files anywhere on disk — common homes for plaintext creds, connection strings, API keys. `-o` = OR.

```bash
find / -perm -4000 -type f 2>/dev/null
```
→ **The SUID privesc sweep.** Every binary with the SUID bit runs as its owner (often root) regardless of who launches it. Check each result against GTFOBins. See [[Linux_Priv_Esc]].

```bash
find / -writable -type f 2>/dev/null
```
→ Files you can modify — look for scripts run by cron/services/root, or config you can poison. Writable ≠ executed; still confirm the trigger.

```bash
find / -mtime -1 -type f 2>/dev/null
```
→ Files changed in the last day. Recently-touched files = where the action is — fresh configs, dropped creds, deployment artifacts.

```bash
find /home -name "id_rsa" 2>/dev/null
find / -name "authorized_keys" 2>/dev/null
```
→ Hunt SSH private keys and the files that trust them. A found key may unlock a different user (incl. root) — see [[SSH]].

---

## Chaining find + grep

`find` filters **which** files; `grep` searches **inside** them. Chain when you want grep to look only at a certain *kind* of file — the noise-killer for big trees:

```bash
# only grep INSIDE .xml configs — skip docs/binaries/lang junk
find /mnt -name "*.xml" -exec grep -i password {} + 2>/dev/null

# grep only files modified in the last day
find / -mtime -1 -type f -exec grep -i password {} + 2>/dev/null

# grep only files you can write to
find / -writable -type f -exec grep -i secret {} + 2>/dev/null
```

> `{}` is each file find found; `+` batches them into one grep call (faster than `\;` which runs grep once per file).

**Which tool when:**

| You know... | Use |
|---|---|
| A content string, location unknown | `grep -R` alone |
| A filename / type, location unknown | `find` alone |
| A content string, but only in certain *kinds* of files | `find ... -exec grep` (chain) |

A plain recursive `grep -R` already walks every subdirectory, so an unusually-placed file is caught **without** chaining. Chaining earns its keep when you filter by something grep can't see — file type, age, permissions, owner.

---

## Gotchas

> **Put `2>/dev/null` at the END.** Running as a low-priv user, `find /` throws "Permission denied" on most of the tree. The redirect drops that noise so you actually see your matches.

> **`-name` is case-sensitive.** `-name "*.PNG"` misses `photo.png`. Use `-iname` when unsure of case.

> **Searching from `/` is slow and loud.** Scope to a likely root when you can (`/home`, `/var/www`, `/opt`, `/mnt`) — faster and less noise.

---

## Related Notes

- [[Grep]]
- [[Linux_Common_Commands]]
- [[Linux_Priv_Esc]]
- [[SSH]]
- [[Juicy_Files]]
