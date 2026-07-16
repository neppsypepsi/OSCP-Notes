My IP: 192.168.45.211
Target IP: 192.168.108.96

nmap:
```
PORT     STATE SERVICE                VERSION
22/tcp   open  ssh                    OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 51:56:a7:34:16:8e:3d:47:17:c8:96:d5:e6:94:46:46 (RSA)
|   256 fe:76:e3:4c:2b:f6:f5:21:a2:4d:9f:59:52:39:b9:16 (ECDSA)
|_  256 2c:dd:62:7d:d6:1c:f4:fd:a1:e4:c8:aa:11:ae:d6:1f (ED25519)
9090/tcp open  hadoop-datanode        Apache Hadoop
|_http-title: Site doesn't have a title (text/html).
| hadoop-tasktracker-info: 
|_  Logs: jive-ibtn jive-btn-gradient
| hadoop-datanode-info: 
|_  Logs: jive-ibtn jive-btn-gradient
9091/tcp open  ssl/hadoop-tasktracker Apache Hadoop
| ssl-cert: Subject: commonName=localhost
| Subject Alternative Name: DNS:localhost, DNS:*.localhost
| Not valid before: 2024-06-28T07:02:39
|_Not valid after:  2029-06-27T07:02:39
| hadoop-tasktracker-info: 
|_  Logs: jive-ibtn jive-btn-gradient
| hadoop-datanode-info: 
|_  Logs: jive-ibtn jive-btn-gradient
|_ssl-date: TLS randomness does not represent time
|_http-title: Site doesn't have a title (text/html).
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```



Port 9090: Login.jsp web page, we find whats running it. along with a version.
(Openfire, Version: 4.7.3). We can use this to enumerate further with exploits on the web. Meanwhile we will try admin admin to see if we can get in. 
- Creds do not work (admin admin, admin password, and sqli single quote)
Using the open fire version we were able to find this [exploit](https://github.com/K3ysTr0K3R/CVE-2023-32315-EXPLOIT/tree/main) online which bypasses and creats a valid account for us. (**[CVE-2023-32315](https://github.com/K3ysTr0K3R/CVE-2023-32315-EXPLOIT)**)
- Later realized that this exploit only gives us a user account, however we likley need another exploit that can grant us RCE. 
- After searching the web again, we find this [Github repo](https://github.com/miko550/CVE-2023-32315) and its the same exploit that creates another account for us, however this time with a .jar plugin file that will grant us terminal access to the server. 
![[Pasted image 20260714221831.png]] ![[Pasted image 20260714221908.png]]
- I was having terrible trouble getting my reverse shells to work through this plugin terminal, so i resulted to using a tool called busybox. Combining it with nc and a port i got a shell as openfire. 
	- User flag -> `612f4170eac515f8c100dda577e40d6d`
- After trying linpeas, trying to find cron related jobs, hidden files or scripts that we can write too there was nothing. 
- I then resulted to credential digging and referred to my find commands. After a while of looking we find a smtp password.![[Pasted image 20260715232033.png]]The realistic thing would have been if I came across this password but had no clue who for, i would store it in a text file, gather all the usernames i can get (root b99id, openfire), and then run them with nxc with a service on a port I know i can use. For this situation it was ssh. 

![[Pasted image 20260715232924.png]]
- User Flag -> `5ebdfbcbd27df8be0643bc99e26e1ff0`
