My IP:  192.168.45.166
Target IP: 192.168.201.240

nmap:
```
PORT     STATE SERVICE          VERSION
22/tcp   open  ssh              OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 74:ba:20:23:89:92:62:02:9f:e7:3d:3b:83:d4:d9:6c (RSA)
|   256 54:8f:79:55:5a:b0:3a:69:5a:d5:72:39:64:fd:07:4e (ECDSA)
|_  256 7f:5d:10:27:62:ba:75:e9:bc:c8:4f:e2:72:87:d4:e2 (ED25519)
80/tcp   open  http             Apache httpd 2.4.38
|_http-title: 403 Forbidden
|_http-server-header: Apache/2.4.38 (Debian)
139/tcp  open  netbios-ssn      Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn      Samba smbd 4.9.5-Debian (workgroup: WORKGROUP)
3000/tcp open  http             Thin httpd
|_http-title: Cassandra Web
|_http-server-header: thin
8021/tcp open  freeswitch-event FreeSWITCH mod_event_socket
Service Info: Hosts: 127.0.0.1, CLUE; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.9.5-Debian)
|   Computer name: clue
|   NetBIOS computer name: CLUE\x00
|   Domain name: pg
|   FQDN: clue.pg
|_  System time: 2026-06-23T20:04:31-04:00
| smb2-time: 
|   date: 2026-06-24T00:04:27
|_  start_date: N/A
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
|_clock-skew: mean: 1h20m01s, deviation: 2h18m36s, median: 0s

```

Port 22: Can be good if we have creds or the ability to drop our key into an authorized key folder. Also good to transfer data to and from.

port 139/445: SMB can be good to see if we have access to shares. We can try anonymous first then if we get any user creds we can use this service to login as them to enumerate some more. 
-  Server doesn't allow session using username '', password ''.

Port 3000: HTTP, try to visit
	- Able to vist via web 
	- Cassandra Web (potential type of web page) Version 3.11.13

Port 8021: Could be a port servicing a product. "freeswitch-event FreeSWITCH mod_event_socket"

~~port 80: Web page~~ 
- Enumeration on the front and back end.
	-  Forbidden splash page when reaching port 80
	- Backup Directory (there but not accessible)