# SSH (Port 22)

Encrypted remote shell. Two auth methods: **password** and **public-key**. Key-based auth is the one that matters for exploitation — a file-write primitive on a target becomes a shell.

---

## Key-Based Auth — The Model

Generate a key pair on Kali:
- **Private key** (`id_ed25519`) → stays on your box, secret, never leaves.
- **Public key** (`id_ed25519.pub`) → the `ssh-ed25519 AAAA...` string, safe to share.

**The rule:** if your *public* key is in a user's `~/.ssh/authorized_keys`, you log in as that user with your *private* key — no password.

```
~/.ssh/authorized_keys   → list of public keys allowed to log in as this user (one per line)
```

So the whole game: **get your public key written into a target user's `authorized_keys`.** Any write primitive (file upload, path traversal, Redis file-write, LFI→write) turns into SSH access as that user.

---

## Workflow

```bash
ssh-keygen -t ed25519 -f mykey          # -> mykey (private), mykey.pub (public)
# write contents of mykey.pub into target's ~/.ssh/authorized_keys (any way you can). If you can upload, but are limited to cwd as a way to traverse, then make your .pub file, and use mv to move it into a new file called authorized_keys. From there you can ssh



ssh -i mykey <user>@<target>            # log in with the private key
```

---

## Permission Gotcha (wastes hours)

`sshd` rejects key auth if perms are too loose (StrictModes). On the target:

| Path | Mode |
|---|---|
| `~/.ssh` | `700` |
| `~/.ssh/authorized_keys` | `600` |
| home dir | not group/other-writable |

Key must be **one line**, valid format (`ssh-ed25519 AAAA... comment`), trailing newline. If a web upload mangles format/perms → silent `Permission denied (publickey)`. Suspect perms/format before the key itself.

---

## Forcing a Single Key — `-o IdentitiesOnly=yes` (fixes "Too many authentication failures")

`-i mykey` does **not** mean "use only this key." By default ssh offers *every* identity it knows — your agent's loaded keys plus `~/.ssh/id_rsa`, `id_ed25519`, etc. Each rejected key burns an attempt, and the server caps attempts at `MaxAuthTries` (default **6**):

```
Received disconnect ... Too many authentication failures
```

…and it falls back to a password prompt you can't answer. Force ssh to use **only** the key you name:

```bash
ssh -o IdentitiesOnly=yes -i mykey <user>@<target>
```

Other `-o` flags worth keeping for labs:
```bash
-o PreferredAuthentications=publickey            # skip password entirely (fail fast instead of prompting)
-o PubkeyAcceptedAlgorithms=+ssh-rsa             # needed for OLD ssh-rsa keys — newer OpenSSH disables SHA-1 RSA by default
-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null   # skip host-key prompts/warnings
-v   /   -vv                                      # verbose — shows which key is offered and whether the server accepts it
```

**Gotcha — `-i` takes a *relative* path.** `-i root` points at a file named `root` **in your current directory**. If you found a key at `/home/user/.ssh/keys/root` on the box, run the ssh command from that directory (or give the full path) — otherwise ssh has no key to offer and drops straight to a password prompt.

> When a key login is refused against the target's external IP, **try `127.0.0.1` from your foothold shell too** (and vice-versa). Root is often reachable over loopback when the external attempt is blocked — costs nothing to test both. See [[#SSH Config Aliases → Privesc]] for the `ssh -i ... root@127.0.0.1` pattern. Use `-vv` to see whether the server *accepted* or *rejected* the key.

---

## Post-Foothold Enumeration — `~/.ssh/`

```bash
ls -la ~/.ssh/
cat ~/.ssh/config          # Host aliases → can lead to privesc
cat ~/.ssh/id_*            # private keys you can reuse on other accounts/boxes
cat ~/.ssh/known_hosts     # boxes this user reaches → pivoting
cat ~/.ssh/authorized_keys
```

---

## Reusing a Found Private Key

You find an `id_rsa`/`id_ed25519` on the box (in `~/.ssh/`, a home dir, a backup share, an LFI read). Copy it to Kali, `chmod 600`, then use it. Two things people get wrong:

**1. Where the key sits tells you NOTHING about which user it logs in as.** A private key authenticates you as whoever has the matching *public* key in their `authorized_keys` — that may be a **different** account than the one whose home you found it in. So **try it against every known user, including root:**

```bash
chmod 600 found_key
ssh -o IdentitiesOnly=yes -i found_key anthony@target   # may fail...
ssh -o IdentitiesOnly=yes -i found_key root@target      # ...and root works
```

> Clue: a key found in a user's home failed for `anthony` but logged straight into **root** — root's `authorized_keys` trusted it. The shell you launch from is irrelevant; only `-i <key>` + `<user>@host` decide success.

**2. Is the key even encrypted? Check before bothering to crack:**

- Open the key — an **encrypted old-format** key shows `Proc-Type: 4,ENCRYPTED`; a **new OpenSSH-format** encrypted key will **prompt for a passphrase** when you `ssh -i`.
- If `ssh -i found_key user@target` logs in **without** asking for a passphrase, the key is **unencrypted** — nothing to crack, just use it.

If it *is* passphrase-protected, crack it:

```bash
ssh2john found_key > hash.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show hash.txt        # prints the passphrase IF it cracked
```

Cracked = john prints the plaintext (use it at the passphrase prompt). Exhausts rockyou with nothing = not the intended path with this wordlist — move on. See [[JohntheRipper]].

---

## SSH Config Aliases → Privesc

`~/.ssh/config` defines shortcut hosts:

```
Host myroot
    HostName 127.0.0.1
    User root
    IdentityFile /home/someuser/.ssh/id_ed25519
```

`ssh myroot` then logs in as **root** using the referenced key — *if that key is already trusted in root's `authorized_keys`*. The config doesn't grant access; it just documents/uses an existing trust. Equivalent without the alias:

```bash
ssh -i /home/someuser/.ssh/id_ed25519 root@127.0.0.1
```

**Always read `~/.ssh/config` after a foothold** — a pre-staged alias + a readable key trusted by root = straight to root.

---

## Tunneling / Pivoting

```bash
ssh -L 8080:127.0.0.1:80 user@target    # local forward → reach internal service on your localhost:8080
ssh -D 1080 user@target                 # dynamic SOCKS proxy
ssh -J jumpuser@jumphost user@target    # ProxyJump → hop through a box
```

(For OSCP multi-hop, ligolo-ng is usually preferred — but know SSH can do it.)

---

## Related Notes

- [[Linux_Priv_Esc]]
- [[Netcat]]
- [[Port-Overview-and-Priorities]]
