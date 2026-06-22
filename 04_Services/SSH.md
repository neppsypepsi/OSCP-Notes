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
# write contents of mykey.pub into target's ~/.ssh/authorized_keys (any way you can)
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

## Post-Foothold Enumeration — `~/.ssh/`

```bash
ls -la ~/.ssh/
cat ~/.ssh/config          # Host aliases → can lead to privesc
cat ~/.ssh/id_*            # private keys you can reuse on other accounts/boxes
cat ~/.ssh/known_hosts     # boxes this user reaches → pivoting
cat ~/.ssh/authorized_keys
```

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
