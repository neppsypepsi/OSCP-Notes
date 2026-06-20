IP: 192.168.231.96  → note: box redeploys with a new IP each session (earlier run was 192.168.111.96)

nmap:
```
PORT     STATE SERVICE                VERSION
22/tcp   open  ssh                    OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 51:56:a7:34:16:8e:3d:47:17:c8:96:d5:e6:94:46:46 (RSA)
|   256 fe:76:e3:4c:2b:f6:f5:21:a2:4d:9f:59:52:39:b9:16 (ECDSA)
|_  256 2c:dd:62:7d:d6:1c:f4:fd:a1:e4:c8:aa:11:ae:d6:1f (ED25519)
9090/tcp open  hadoop-tasktracker     Apache Hadoop
|_http-title: Site doesn't have a title (text/html).
| hadoop-datanode-info: 
|_  Logs: jive-ibtn jive-btn-gradient
| hadoop-tasktracker-info: 
|_  Logs: jive-ibtn jive-btn-gradient
9091/tcp open  ssl/hadoop-tasktracker Apache Hadoop
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=localhost
| Subject Alternative Name: DNS:localhost, DNS:*.localhost
| Not valid before: 2024-06-28T07:02:39
|_Not valid after:  2029-06-27T07:02:39
| hadoop-datanode-info: 
|_  Logs: jive-ibtn jive-btn-gradient
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

Notes: 
- Observed that there is a webpage on port 9090 - login screen
Found:
- Openfire, Version: 4.7.3

Websearch for Github exploit Openfire 4.7.3; Found commonly mentioned CVE:
CVE-2023-32315.

Tried the first one - Link to Github (https://github.com/K3ysTr0K3R/CVE-2023-32315-EXPLOIT)
and was able to get the script to run. Was able to log into the admin panel with user&pass hugme, HugmeNOW

> Session artifacts are per-deployment (re-grab after each redeploy). Example from one run:
> `node0oq37ry6r3sxcekoi963iwkih52.node0; csrf=pLVPMczyLubI6qI`


Further Known Ports revealed by webpage:

7070|HTTP Binding|The port used for unsecured HTTP client connections.

7777|File Transfer Proxy|The port used for the proxy service that allows file transfers to occur between two entities on the XMPP network.|

- This could be important for future file transfers


In the nav bar, we find users/Groups. There are now three users. admin, hugme, and b99aid. 

The main point of interest the the ability to upload a malicious plugin with the .jar extension.
