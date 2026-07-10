# SSH (Port 22)

Encrypted remote shell. Auth = **password** or **key**. Key auth is the exploit path: a write primitive on a target → shell.

---

## Flags

| Flag | Meaning |
|---|---|
| `-i <key>` | use this private key (relative path — see gotcha) |
| `-o <opt>` | set a config option inline (see table below) |
| `-p <port>` | non-standard port |
| `-L l:host:r` | local forward (reach internal service on your localhost) |
| `-D 1080` | dynamic SOCKS proxy |
| `-J user@host` | ProxyJump — hop through a box |
| `-v` / `-vv` | verbose — shows which key is offered + accept/reject |

### `-o` options worth keeping

| `-o` option | Why |
|---|---|
| `IdentitiesOnly=yes` | offer ONLY the `-i` key → fixes "Too many authentication failures" |
| `PreferredAuthentications=publickey` | skip password prompt, fail fast |
| `PubkeyAcceptedAlgorithms=+ssh-rsa` | needed for OLD ssh-rsa keys (new OpenSSH disables SHA-1 RSA) |
| `StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null` | skip host-key prompts |

---

## File locations (target)

| Path                           | What                                                          |
| ------------------------------ | ------------------------------------------------------------- |
| `~/.ssh/id_rsa` / `id_ed25519` | **private** key — reusable, loot it                           |
| `~/.ssh/id_rsa.pub`            | public key                                                    |
| `~/.ssh/authorized_keys`       | **public** keys allowed to log in as this user (one per line) |
| `~/.ssh/config`                | host aliases → can lead to privesc                            |
| `~/.ssh/known_hosts`           | boxes this user reaches → pivoting                            |
| `/etc/ssh/sshd_config`         | server config (e.g. `PermitRootLogin`)                        |

---

## Found a private key → reuse it

```bash
chmod 600 found_key
ssh -o IdentitiesOnly=yes -i found_key user@target
ssh -o IdentitiesOnly=yes -i found_key root@target      # ALSO try root
```
→ Where you found the key tells you **nothing** about which user it logs in as — it authenticates as whoever trusts the matching public key. Try every user **incl. root**.

> **`-i` is a relative path.** `-i root` = a file named `root` in your cwd. Run from the key's dir or give the full path, or ssh silently drops to a password prompt.

> **Key login refused on the external IP?** Try `root@127.0.0.1` from your foothold shell. Root is often reachable over loopback when blocked externally. `-vv` shows accept vs reject.

### Encrypted key? Crack it
```bash
ssh2john found_key > hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show hash.txt
```
→ If `ssh -i` logs in without asking a passphrase, it's unencrypted — skip this. `Proc-Type: 4,ENCRYPTED` in the key (or a passphrase prompt) = encrypted. See [[JohntheRipper]].

---

## Can write to a user's home → plant YOUR key

```bash
#step 1:
ssh-keygen -t ed25519 -f mykey                          # -> mykey + mykey.pub

#or create a key towhich it wont ask for a passphrase

ssh-keygen -t ed25519 -f mykey -N ''

#step 2:

cat mykey.pub 


ssh -o IdentitiesOnly=yes -i mykey <user>@<target>
```



> **Limited to cwd on upload?** Make `mykey.pub`, `mv` it into a file named `authorized_keys`, then ssh.

---

## StrictModes perms (wastes hours)

| Path | Mode |
|---|---|
| `~/.ssh` | `700` |
| `~/.ssh/authorized_keys` | `600` |
| home dir | not group/other-writable |

→ Key must be one line, valid format (`ssh-ed25519 AAAA... comment`), trailing newline. Bad perms/format = silent `Permission denied (publickey)`. Suspect perms before the key.

---

## Post-foothold enum

```bash
ls -la ~/.ssh/
cat ~/.ssh/id_*            # private keys to reuse
cat ~/.ssh/config          # Host aliases → privesc
cat ~/.ssh/known_hosts     # pivot targets
cat ~/.ssh/authorized_keys
```

### Config alias → privesc
```
Host myroot
    HostName 127.0.0.1
    User root
    IdentityFile /home/someuser/.ssh/id_ed25519
```
→ `ssh myroot` logs in as root **if that key is trusted in root's authorized_keys**. Same thing without the alias:
```bash
ssh -i /home/someuser/.ssh/id_ed25519 root@127.0.0.1
```
Always read `~/.ssh/config` after a foothold.

---

## Tunneling / pivoting

```bash
ssh -L 8080:127.0.0.1:80 user@target    # local forward → internal svc on localhost:8080
ssh -D 1080 user@target                 # SOCKS proxy
ssh -J jumpuser@jumphost user@target    # hop through a box
```
→ For OSCP multi-hop ligolo-ng is usually preferred, but SSH can do it.

---

## Related Notes

- [[Linux_Priv_Esc]]
- [[Netcat]]
- [[JohntheRipper]]
- [[Port-Overview-and-Priorities]]
