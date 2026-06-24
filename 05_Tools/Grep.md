# Grep — Searching Text & Files (OSCP)

Grep searches for a pattern inside files or piped output. The everyday tool for sifting credentials, config values, and flags out of large amounts of text. The flags only change **what gets printed** — not what gets searched.

---

## Core Flags

| Flag | Meaning |
|---|---|
| `-i` | **Ignore case** — `Password`, `PASSWORD`, `password` all match |
| `-r` / `-R` | **Recursive** — search every file in a directory tree, not one file |
| `-n` | Print the **line number** of each match |
| `-l` | Print **only the filenames** that contain a match (lowercase L) |
| `-v` | **Invert** — show lines that do NOT match |
| `-E` | Extended regex — multiple patterns with `|` as OR |
| `-a` | Treat **binary files as text** (so grep doesn't skip them) |
| `-A` / `-B` / `-C` | Lines of context **A**fter / **B**efore / both sides of a match |

---

## Commands

```bash
grep "password" config.txt
```
→ Searches a single file for the word "password" and prints every matching line. Case-sensitive by default.

```bash
grep -i "password" config.txt
```
→ Same search but case-insensitive — catches "Password", "PASSWORD", etc. Use this when you're not sure how it was written.

```bash
grep -r "password" /var/www/
```
→ Recursively searches every file under `/var/www/` for the pattern. Use this to hunt credentials across an entire web root.

```bash
grep -n "password" config.txt
```
→ Shows matching lines along with their line numbers. Helpful when you want to jump directly to the match in nano or less.

```bash
grep -v "nologin" /etc/passwd
```
→ Inverts the match — shows every line that does NOT contain "nologin". Good for filtering out service accounts to see only real users.

```bash
grep -E "root|admin|password" config.txt
```
→ Extended grep lets you search for multiple patterns at once using `|` as OR. Returns any line that matches any of the terms.

```bash
grep -i -A3 -B1 "password" file
```
→ **Context flags — the most important grep trick for dumps/logs.** The value you want is often on the line *next to* the keyword, not on it. `-A3` = 3 lines **A**fter, `-B1` = 1 line **B**efore, `-C2` = 2 lines of **C**ontext both sides. Always add these when hunting a secret next to a label like `Password:`.

> **Habit:** when searching unknown data, use `grep -i` (case-insensitive — `Password` ≠ `password` without it) **and** a context flag. You lose nothing and stop missing matches over a capital letter or a line break.

---

## Filenames vs Content — when to use `-l`

Same search, three different outputs:

```bash
grep -Ri password /etc/freeswitch/
# → filename:the whole matching line          (file + content)

grep -Ril password /etc/freeswitch/
# → /etc/freeswitch/autoload_configs/x.xml     (JUST the filenames, no content)

grep -Rin password /etc/freeswitch/
# → filename:42:the matching line              (file + line number + content)
```

Grepping for the **content** is the default first move. `-l` (filename-only) is for two specific jobs:

1. **Build a list to feed another command.** You can't loop over "matching lines" — you loop over **filenames**. `grep -Ril` gives a clean list to drop into a file and iterate:
   ```bash
   grep -Ril password /mnt > tmp
   for i in $(cat tmp); do curl -s --path-as-is "http://<IP>/path/../../$i" >> carve; done
   ```
   This is the bridge between "which files mention it" and "fetch each one." See [[Curl]].
2. **Noise reduction.** When a recursive search returns hundreds of matching lines across logs and binaries, `-l` collapses it to *which files even matter* so you know what to open.

> **Gotcha — carving the filename out of grep output.** `grep -R` prints `filename:matchtext`. The field separator is the **colon**, not whitespace — so `awk '{print $1}'` grabs the wrong chunk. Use `-l` to get filenames directly, or `cut -d: -f1` if you must parse:
> ```bash
> grep -Ria "ClueCon" /mnt | cut -d: -f1 | sort -u
> ```

> **Gotcha — no path = hang.** `grep -Ri password` with no file/dir argument reads from **stdin** and just sits there. Always give it a path (`grep -Ri password .`) or pipe something in.

---

## Related Notes

- [[Curl]]
- [[Linux_Common_Commands]]
- [[JohntheRipper]]
