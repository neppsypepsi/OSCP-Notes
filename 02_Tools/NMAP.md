# **🛠️ Section 1: General Nmap Commands & Cheat Sheet**

## **🧠 What is Nmap?**

nmap is an **active reconnaissance tool** used to:

- Discover live hosts
- Scan for open TCP/UDP ports
- Detect service versions and OS types
- Map firewall rules

## **🔧 Basic Syntax**

```bash
nmap <scan types> <options> <target>
```
Think of it as:

- **Scan type** → _How_ Nmap talks to the target
    
- **Options** → _What extra info_ you want
    
- **Target** → IP / range / hostname


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

