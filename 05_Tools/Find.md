# Find — Locating Files by Attribute (OSCP)

`find` searches for files by **attribute** (name, type, perms, owner, age). Contents = [[Grep]].
> `find` = search by book title; `grep` = search the words on the pages.

---

## Core Options

| Option | Meaning |
|---|---|
| `-name "*.conf"` | filename/ext (case-sensitive; `-iname` = insensitive) |
| `-ipath "*svc*"` | match the **whole path** (any file under a folder) |
| `-type f` / `-type d` | files / directories |
| `-perm -4000` | SUID bit set |
| `-writable` | files you can write to |
| `-user root` | owned by a user |
| `-mtime -1` / `-mmin -10` | modified last day / 10 min |
| `-exec ... {} +` | run cmd on matches (`{}` = file, `+` = batch) |
| `2>/dev/null` | hide "Permission denied" (put at END) |

---

## Commands

```bash
# flags
find / -name "local.txt" 2>/dev/null
find / -name "proof.txt" 2>/dev/null

# config / backup files
find / -name "*.conf" -o -name "*.bak" 2>/dev/null

# SUID privesc sweep — check hits vs GTFOBins ([[Linux_Priv_Esc]])
find / -perm -4000 -type f 2>/dev/null

# writable files (cron/service/root scripts to poison)
find / -writable -type f 2>/dev/null

# recently changed
find / -mtime -1 -type f 2>/dev/null

# SSH keys ([[SSH]])
find / -name "id_rsa" -o -name "authorized_keys" 2>/dev/null
```

---

## Chaining find + grep

`find` picks the files, `grep` reads inside them. Chain to filter by something grep can't see (type, age, perms):

```bash
find / -mtime -1 -type f -exec grep -i password {} + 2>/dev/null
find / -writable -type f -exec grep -i secret {} + 2>/dev/null
```

### Loot pattern — scope to one service

Enumeration named a service → hunt only its files. `-ipath` matches the whole path.

```bash
# STEP 1 — MAP: which of the service's files mention creds (swap openfire)
find / -ipath '*openfire*' -type f 2>/dev/null -exec grep -ilIE 'passw|secret|cred|key|token' {} + 2>/dev/null

# STEP 2 — READ: paste a path from step 1 (-n = lines, drop -l; add -C1 for context)
grep -inE 'passw|secret|key' /var/lib/openfire/embedded-db/openfire.script
```

> `-l` maps (which files), `-n` reads (which lines). `.sql` under `resources/database/` = schema templates (ignore). Binary DBs (`.db`/`.sqlite`/`.mv.db`) get skipped by `-I` — find them by name instead.

---

## Gotchas
- `2>/dev/null` goes at the END.
- `-name` is case-sensitive → use `-iname`.
- Searching from `/` is slow/loud → scope to `/home /var/www /opt /etc` when you can.

---

## Related Notes
- [[Grep]]
- [[Juicy_Files]]
- [[Linux_Priv_Esc]]
- [[SSH]]
