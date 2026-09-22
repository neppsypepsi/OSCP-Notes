
## **🧠 What is Nmap?**

nmap is an **active reconnaissance tool** used to:

- Discover live hosts
- Scan for open TCP/UDP ports
- Detect service versions and OS types
- Map firewall rules
---
**🧪 Typical OSCP Workflow**

**1. Initial full port scan (fast/broad):**

```bash
nmap -sS -T4 -p- -oN full_scan.txt <target>
```
### **What each flag means (decode it mentally)**
| **Flag** | **Meaning**                      | **Why you use it**                         |
| -------- | -------------------------------- | ------------------------------------------ |
| -sS      | **TCP SYN scan**                 | Stealthy, fast, doesn’t complete handshake |
| -T4      | **Timing template (aggressive)** | Faster scans, acceptable for OSCP          |
| -p-      | **Scan all 65,535 TCP ports**    | Finds services on non-standard ports       |
| -oN      | **Normal output to file**        | Save results for reference                 |

**2. Version scan only on open ports:** Once you know which ports are open:

```bash
nmap -sV -sC -p <open_ports> -oN version_scan.txt <target>
```

|**Flag**|**Meaning**|**Why it matters**|
|---|---|---|
|-sV|**Service version detection**|Identifies exact software versions|
|-sC|**Default NSE scripts**|Safe scripts: banners, users, shares|
|-p|**Specific ports only**|Faster + cleaner results|
|-oN|**Save output**|Needed for reporting & review|


---

# **🔬 Section 2: NSE Scripts (`--script`)**


## Ole-Reliable Commands
```bash
# Run every vuln-category check (service-aware -> keep -sV)
nmap -sV -p<port> --script vuln <IP>

# See what scripts EXIST for a service (find the exact name)
ls /usr/share/nmap/scripts/ | grep <service>

# Run ONE specific script by name
nmap -sV -p<port> --script <script-name> <IP>

# Read what a script does BEFORE running it
nmap --script-help <script-name>
```

## Service -> Script Family (examples)
| Open service  | Script family to grep |
| ------------- | --------------------- |
| SMB (445)     | `smb-vuln-*`          |
| RDP (3389)    | `rdp-*`               |
| HTTP (80/any) | `http-*`              |
| DNS (53)      | `dns-*`               |
| FTP (21)      | `ftp-*`               |

> All scripts live in `/usr/share/nmap/scripts/`

## 🔗 Related Notes
- [[SMB]]
- [[smbmap]]
- [[enum4linux]]
- [[Port-Overview-and-Priorities]]
