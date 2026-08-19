My IP: 192.168.45.167
Target IP: 192.168.240.46

# nmap:
```
PORT     STATE SERVICE       VERSION
21/tcp   open  ftp           zFTPServer 6.0 build 2011-10-17
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| total 9680
| ----------   1 root     root      5610496 Oct 18  2011 zFTPServer.exe
| ----------   1 root     root           25 Feb 10  2011 UninstallService.bat
| ----------   1 root     root      4284928 Oct 18  2011 Uninstall.exe
| ----------   1 root     root           17 Aug 13  2011 StopService.bat
| ----------   1 root     root           18 Aug 13  2011 StartService.bat
| ----------   1 root     root         8736 Nov 09  2011 Settings.ini
| dr-xr-xr-x   1 root     root          512 Aug 14 02:57 log
| ----------   1 root     root         2275 Aug 08  2011 LICENSE.htm
| ----------   1 root     root           23 Feb 10  2011 InstallService.bat
| dr-xr-xr-x   1 root     root          512 Nov 08  2011 extensions
| dr-xr-xr-x   1 root     root          512 Nov 08  2011 certificates
|_dr-xr-xr-x   1 root     root          512 Aug 02  2024 accounts
242/tcp  open  http          Apache httpd 2.2.21 ((Win32) PHP/5.3.8)
|_http-server-header: Apache/2.2.21 (Win32) PHP/5.3.8
| http-auth: 
| HTTP/1.1 401 Authorization Required\x0D
|_  Basic realm=Qui e nuce nuculeum esse volt, frangit nucem!
|_http-title: 401 Authorization Required
3145/tcp open  zftp-admin    zFTPServer admin
3389/tcp open  ms-wbt-server Microsoft Terminal Service
| rdp-ntlm-info: 
|   Target_Name: LIVDA
|   NetBIOS_Domain_Name: LIVDA
|   NetBIOS_Computer_Name: LIVDA
|   DNS_Domain_Name: LIVDA
|   DNS_Computer_Name: LIVDA
|   Product_Version: 6.0.6001
|_  System_Time: 2026-08-13T19:57:51+00:00
|_ssl-date: 2026-08-13T19:57:56+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=LIVDA
| Not valid before: 2024-08-01T10:50:21
|_Not valid after:  2025-01-31T10:50:21
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```

Port 21:
- Based on our nmap scan we find that we are able to sign onto the ftp server using anonymous access. ![[Pasted image 20260817232905.png]]
- Doing so we find that we can't really do much like read files or pull them onto our local machine, and that is because of the "root       root" permissions, however what caught my eye was that there was a directory by the name of accounts.![[Pasted image 20260817232934.png]] 
- After seeing this I wondered if it were possible to login to the ftp server using admin admin. Here we find that we have the ability to place files on the ftp server. This comes in handy later.![[Pasted image 20260817232758.png]]
	- The probe file contained contents that would end up proving that php was indeed able to be executed via the web browser, and by simply browsing to it. This also could've been proven by looking at our header response when running our nmap scan -> "http-server-header: Apache/2.2.21 (Win32) **PHP/5.3.8**"
- After being able to log into the ftp server as admin we find 3 files (index.php, .htpasswd, and .htaccess.). We also find that we are also ![[Pasted image 20260817234430.png]]
- The .htaccess file reveal to us a user name and a hash for that user.![[Screenshot From 2026-08-17 23-48-22 1.png]]
- Observing the prefix of the hash -> `$apr1$` we find that this is a APR1-MD5 Hash. And with a google search we find that its able to get cracked with the hashcat mode of `1600`
- I was able to crack the password to the hash![[Pasted image 20260818000347.png]]
Port 242:
- We end up finding that we need credentials to even access the web page. Using the credentials we found from the hashcat crack, we are able to authenticate ourselves. 
- If we remember from our ftp session as admin admin, we end up having the ability to upload files. Since we know that php is executed on the web page, we can upload a php file that will accept cmd inputs through the query (search) bar. (simple-backdoor.php file)
- Here I was able to test the whoami command which lets us know we can then upload a reverse shell to then use the certutil command to pull and execute our reverse shell file. 
![[Screenshot From 2026-08-14 13-17-42.png]]
- I was able to search and find the local.txt flag -> `f1d15547995b8aa589cfbe6315ba2236.`![[Pasted image 20260819144055.png]]
- We then find that after running the `whoami /all` command we see the user account has some privileges that may be exploitable![[Pasted image 20260819144648.png]]
- We then see after running system info that the machine is confirmed x84. This is a potential exploit route however lets see what else we can find. ![[Pasted image 20260819144728.png]]
- I end up finding by searching for exploits relative to the build number `build 6001 windows exploit` and ended up finding an exploitdb page -> [CVE-2011-1249](https://www.exploit-db.com/exploits/40564)
	- I learned that I could've bettered my search by searching up something like:
		- Windows Server 2008 SP1 x86 local privilege escalation exploit
		- Windows Server 2008 SP1 privilege escalation github
		- Server 2008 SP1 kernel exploit SYSTEM
	- I also found by using teh 
