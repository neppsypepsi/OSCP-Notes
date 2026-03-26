
# **Linux Project Structure (OSCP)**

**Purpose:**

Create a repeatable directory structure **immediately after VPN connection** so enumeration, loot, and exploits never get messy.

This is done **before any scanning**.

---

## **When to Use This**

- Right after VPN is connected
    
- Before running nmap, gobuster, etc.
    
- Every new box / lab / exam target



## **Base Directory**

```bash
cd ~/Desktop
mkdir <box-name>
cd <box-name>
```
Example
```bash
mkdir ms01
cd ms01
```

## **Standard Folder Layout**
Create these **every time**:
```bash
mkdir enum loot staging exploits
```

### **What each folder is for**
- **enum/**
    All scan output
    
    - nmap
        
    - gobuster
        
    - enum4linux
        
    
- **loot/**
    Anything valuable you find
    
    - creds
        
    - hashes
        
    - config files
        
    - notes.txt
        
    
- **staging/**
    Files you will transfer to target
    
    - winPEAS
        
    - linPEAS
        
    - rev shells
        
    - mimikatz
        
    
- **exploits/**
    Modified or copied exploits
    
    - searchsploit -m output
        
    - edited scripts

## **Enumeration Subfolders**
```bash
mkdir nmap web smb
```
Example
```bash
enum/nmap/full.txt
enum/web/gobuster.txt
enum/smb/enum4linux.txt
```


## **🔗 Related Notes**

- [[Attack-Workflow]]
- [[File_Transfer]]
- [[winPEAS]]
- [[SearchSploit]]