My IP: 10.10.14.5
Target IP: 10.129.229.17

# nmap:
```
PORT     STATE SERVICE       VERSION
53/tcp   open  domain        Simple DNS Plus
88/tcp   open  kerberos-sec  Microsoft Windows Kerberos (server time: 2026-09-09 07:26:38Z)
135/tcp  open  msrpc         Microsoft Windows RPC
389/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: BLACKFIELD.local, Site: Default-First-Site-Name)
445/tcp  open  microsoft-ds?
593/tcp  open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
3268/tcp open  ldap          Microsoft Windows Active Directory LDAP (Domain: BLACKFIELD.local, Site: Default-First-Site-Name)
5985/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2026-09-09T07:26:44
|_  start_date: N/A
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required
|_clock-skew: 6h59m49s

```


Port 139/445:
- We find with anonymous access that we can see the avail shares -> ![[Pasted image 20260908173018.png]]
	- forensic stands out...but denies access
	- `profiles$` is accessible, 
- Here see a ton of different directory folders with each named looking like users, or usernames. The ideal next best step would be to throw this into a `users.txt` file so we can then try more enumeration or password spraying.
![[Pasted image 20260911160617.png]]

- I need notes as for the best way to grab all users without the other fields....when I was doing the box I just used ai but on the real test id need a better alternative.

Port 389(Ldap):
- With the text file we created with  a list of possible users,  we can trying AS-Reproasting. Before we do so, we will need to add the domain name to our /etc/hosts file, and we can find that in our nmap scan. We see under ldap (port 88) it reads `BLACKFIELD.local`. 

- Command I used:
`impacket-GetNPUsers BLACKFIELD.local/ -userfile users.txt -dc-ip <BOX IP> `

- We ended getting back for one of the users, `support@BLACKFIELD.local` that there is an exposed NT hash. We could either do PTH or try and crack it with hashcat. And I tried cracking it cause we can then see about using it for other users later.

![[Pasted image 20260908175926.png]]

- I ended up being able to successfully crack the password -> `#00^BlackKnight`
![[Pasted image 20260908180106.png]]

- From here we have a few options to try. Correct me if I'm wrong but we can try connecting back to the SMB server to see if there are any new shares for this user (or would it be the same for every given account on AD?), and then we can also try all of the impacket tools, WinRM, and Rpcclient to try and get a shell as this user (and this goes for even if something like WinRM werent to show up on the initially nmap scan)
![[Pasted image 20260911162821.png]]
psexec does not work
![[Pasted image 20260911162845.png]]wmiexec does not work
![[Pasted image 20260914144810.png]]smbexec does not work

command that was provided to us in bloodound in order to force change the password for the audit2020 account:
```
└─$ net rpc password "audit2020" "newP@ssword2022" -U BLACKFIELD.local/"support"%"#00^BlackKnight" -S 10.129.229.17

```
- Ends up working...it gave no out put but it worked and we could've tested this with smb or or someother service that would accept creds.


We get lucky for smb being our first try...however we end up now being able to access that forensic share that we once werent able to. 
![[Pasted image 20260915184816.png]]
here  what stands out is the lsass.zip file (its always been important dont over think)


There is a tool called pypykatz that is use to 
pypykatz later download.