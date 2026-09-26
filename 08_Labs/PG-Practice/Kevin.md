My IP:
```
192.168.45.207
```

Target IP:
```
192.168.207.45
```

# nmap:
```
PORT      STATE    SERVICE       VERSION
80/tcp    open     http          GoAhead WebServer
| http-title: HP Power Manager
|_Requested resource was http://192.168.207.45/index.asp
|_http-server-header: GoAhead-Webs
135/tcp   open     msrpc         Microsoft Windows RPC
139/tcp   open     netbios-ssn   Microsoft Windows netbios-ssn
364/tcp   filtered aurora-cmgr
395/tcp   filtered netcp
445/tcp   open     microsoft-ds  Windows 7 Ultimate N 7600 microsoft-ds (workgroup: WORKGROUP)
1094/tcp  filtered rootd
1176/tcp  filtered indigo-server
3389/tcp  open     ms-wbt-server Microsoft Terminal Service
| rdp-ntlm-info: 
|   Target_Name: KEVIN
|   NetBIOS_Domain_Name: KEVIN
|   NetBIOS_Computer_Name: KEVIN
|   DNS_Domain_Name: kevin
|   DNS_Computer_Name: kevin
|   Product_Version: 6.1.7600
|_  System_Time: 2026-09-26T05:11:36+00:00
| ssl-cert: Subject: commonName=kevin
| Not valid before: 2026-09-25T04:41:56
|_Not valid after:  2027-03-27T04:41:56
|_ssl-date: 2026-09-26T05:11:44+00:00; 0s from scanner time.
3573/tcp  open     tag-ups-1?
5371/tcp  filtered unknown
6484/tcp  filtered sun-sr-jms
12700/tcp filtered unknown
17823/tcp filtered unknown
18473/tcp filtered unknown
19758/tcp filtered unknown
20804/tcp filtered unknown
21158/tcp filtered unknown
22715/tcp filtered unknown
35981/tcp filtered unknown
36201/tcp filtered unknown
39436/tcp filtered unknown
42765/tcp filtered unknown
43838/tcp filtered unknown
45457/tcp filtered unknown
45598/tcp filtered unknown
49152/tcp open     msrpc         Microsoft Windows RPC
49153/tcp open     msrpc         Microsoft Windows RPC
49154/tcp open     msrpc         Microsoft Windows RPC
49155/tcp open     msrpc         Microsoft Windows RPC
49158/tcp open     msrpc         Microsoft Windows RPC
49159/tcp open     msrpc         Microsoft Windows RPC
58361/tcp filtered unknown
61461/tcp filtered unknown
Service Info: Host: KEVIN; OS: Windows; CPE: cpe:/o:microsoft:windows
```

Port 139/445 (SMB):
- Anonymous access approved, however unable to list out shares. 
- Off rip we can see that this machine is likely older given the smb response (Windows 7)



Port 80:
We find a login page. Off the header `HP POWER MANAGER` I then search up for a default password and google gave me back admin:admin. Sure enough this worked ![[Pasted image 20260925224014.png]]
- Login page
![[Pasted image 20260925224430.png]]
- In the help tab, we find a version number for the HP Power Manager (4.2) 
- A google search for public CVE's, we end up coming across [CVE-2009-3999](https://github.com/AC8999/CVE-2009-3999-HP-Power-Manager-4.2-Build-7-Buffer-Overflow)


- After running the exploit we get a shell immediatley as SYSTEM -> ![[Pasted image 20260925230004.png]]
![[Pasted image 20260925230051.png]]
- Thus allowing me to find the flag (2d1b859c0b2541e71a74b42872c64b17)