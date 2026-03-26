
# RDP & WinRM — Remote Access (OSCP)

RDP and WinRM are **remote access services**.




## **When You Use RDP**

Use RDP when:
- You have **valid user credentials**
- Port **3389** is open
- You want a **full desktop session**
- You need easier file browsing or GUI actions

## **Start an RDP Session (Kali → Windows)**
```bash
xfreerdp /v:<IP> /u:<user> /p:<password> /cert:ignore +clipboard
```


- /v: target host
- /u /p credentials
- /cert:ignore avoids cert errors
- +clipboard copy/paste files & commands



## **When You Use WinRM**


Use WinRM when:
- You have credentials
- RDP is blocked or disabled
- You want **command execution without GUI**
- You want **cleaner shells** than SMB exec
- Ports - 5985 → HTTP or 5986 → HTTPS

  

WinRM often works when SMB exec is restricted.

## **WinRM via Evil-WinRM (Most Common)**
```bash
evil-winrm -i <IP> -u <user> -p <password>
```
With NTLM hash:
```bash
evil-winrm -i <IP> -u <user> -H <NTLM_HASH>
```

## **Related Notes**

- [[CrackMapExec]]
- [[NetExec]]
- [[Password_Spraying]]
- [[Impacket]]