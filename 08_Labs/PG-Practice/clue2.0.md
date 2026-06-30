
My IP: 192.168.45.158
Target IP: 192.168.102.240

nmap:
```
PORT     STATE SERVICE          VERSION
22/tcp   open  ssh              OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 74:ba:20:23:89:92:62:02:9f:e7:3d:3b:83:d4:d9:6c (RSA)
|   256 54:8f:79:55:5a:b0:3a:69:5a:d5:72:39:64:fd:07:4e (ECDSA)
|_  256 7f:5d:10:27:62:ba:75:e9:bc:c8:4f:e2:72:87:d4:e2 (ED25519)
80/tcp   open  http             Apache httpd 2.4.38
|_http-server-header: Apache/2.4.38 (Debian)
|_http-title: 403 Forbidden
139/tcp  open  netbios-ssn      Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp  open  netbios-ssn      Samba smbd 4.9.5-Debian (workgroup: WORKGROUP)
3000/tcp open  http             Thin httpd
|_http-server-header: thin
|_http-title: Cassandra Web
8021/tcp open  freeswitch-event FreeSWITCH mod_event_socket
Service Info: Hosts: 127.0.0.1, CLUE; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.9.5-Debian)
|   Computer name: clue
|   NetBIOS computer name: CLUE\x00
|   Domain name: pg
|   FQDN: clue.pg
|_  System time: 2026-06-26T14:10:56-04:00
|_clock-skew: mean: 1h20m01s, deviation: 2h18m37s, median: 0s
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-time: 
|   date: 2026-06-26T18:10:52
|_  start_date: N/A

```

## Port 22: 
Find id_rsa keys if possible, or use known creds to try and sign is as user. Or could simply use this as a method to transfer files to and from.


## Port 139/445: 
Try anonymous access with smb to see if we find any avail shares
```
Sharename       Type      Comment
	---------       ----      -------
	print$          Disk      Printer Drivers
	backup          Disk      Backup web directory shares
	IPC$            IPC       IPC Service (Samba 4.9.5-Debian)

-------------------------------------------------------------------------

SMB         192.168.102.240 445    CLUE             -----           -----------     ------
SMB         192.168.102.240 445    CLUE             print$                          Printer Drivers
SMB         192.168.102.240 445    CLUE             backup          READ            Backup web directory shares
SMB         192.168.102.240 445    CLUE             IPC$                            IPC Service (Samba 4.9.5-Debian)


```

- Lets find our permissions as for what we can do against this smb shares. 
	- We have the read permission over the backup share. Lets mount it to our /mnt folder and see what we can see.
- We mounted the share to my local mnt folder. We grepped inside all of the files within the freeswitch and cassandra folders for the mention of "Password".
- We know the two services running on this web server are cassandra (web) and freeswitch. To minimize getting caught in noise for output, a quick google search as for what file path the config file lives in could help us focus more on which files to look in.
- Additionally searching for what is the default credentials are for the services can help us determine whether what we are seeing is a new password or the default password. Likely, passwords in a backup folder such as default credentials are not the same password for what is running live but we can never assume
Location for where we can find the password:
/etc/freeswitch/autoload_configs/event_socket.conf.xml & /etc/freeswitch/autoload_configs/hash.conf.xml: -> ClueCon

/etc/cassandra/cassandra.yaml -> cassandra


## Port 80/3000: 
Observe/enumerate webpage 
Gobuster
- 80 Doesnt resolve
- 3000 (Cassandra Web)
	- cql version 3.4.4 
	- Release Version 3.11.13
	- User Cassie
Lets try and search for exploits related to either of the two versions for cassandra web
No CQL commands work, not even the ones they provide us initially
	- https://www.exploit-db.com/exploits/49362
		- Here we find an exploit that exploits file path traversal. I tried putting the code into a file, ran it with python 3 however kept encountering this specific error
```
python3 cassandra.py 192.168.102.24 -n 8 /etc/passwd    
Error: HTTPConnectionPool(host='192.168.102.24', port=3000): Max retries exceeded with url: / (Caused by NewConnectionError("HTTPConnection(host='192.168.102.24', port=3000): Failed to establish a new connection: [Errno 113] No route to host"))

```
Not giving up on this exploit soley because of the fact it is file path traversal, I decided to take it to burpsuite. Here I was successfully able to read the /etc/passwd file and the recommended (in my notes and in usage description) file path of /proc/self/cmdline to see who is running in the background using the cassandra web service. 
- We found user: cassie pass: SecondBiteTheApple330, user: anthony, and user: freeswitch as possible users to sign in to. We learn that cassandra is not someone we can log into.
- With these creds lets try logging in as cassie via the ssh service. 
	- Unsuccessful signing in as cassie. We hit a permission denied message even with the correct password. This is likley the same for the rest of the users we can potentially sign in as however we can keep testing. 
Given that we have LFI we can exploit this to find the real password that is running on the freeswitch service. Perhaps, if we obtain a live password for the service we can then see if we can login as the freeswitch. 
- Success! we were able to use the file path that we originally found in the backup share, that contained a folder with a file that had the default password inside of it. 
![[Pasted image 20260626125948.png]]

Here we find the password to the freeswitch account; StrongClueConEight021
- Going to try again and try ssh with this user.
	- Again denied.
Now lets search online for exploits related to the freeswitch service.
- Found: https://www.exploit-db.com/exploits/47799
	- In order for it to work it requires a password to the service. By default there is the default`ClueCon` password we earlier found. However because we have the actual password to the service we can use that one instead in order to get this to work. 
		- It works. 

![[Pasted image 20260626133547.png]]


- We can then use this as way to get a reverse shell. We will base 64 encode a reverse shell since we dont know the way the user account interprets commands let alone bin bash commands.
	- We were able to get a reverseshell working and we are now logged in as freeswitch. It is now time to upgrade our shell. So we can initiate normal commands
Because earlier we found out from /etc/passwd that we can sign in as other users such as cassie. Now would be a great time to switch to them given that we are "internal" now...

Now that we switched over to cassie, we can then 





---
## Services:
Freeswitch & Cassandra (web)