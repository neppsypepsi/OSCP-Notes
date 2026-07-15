My IP: 192.168.45.206
Target  IP: 192.168.224.210

nmap:

```
PORT      STATE SERVICE VERSION
22/tcp    open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.9 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 62:36:1a:5c:d3:e3:7b:e1:70:f8:a3:b3:1c:4c:24:38 (RSA)
|   256 ee:25:fc:23:66:05:c0:c1:ec:47:c6:bb:00:c7:4f:53 (ECDSA)
|_  256 83:5c:51:ac:32:e5:3a:21:7c:f6:c2:cd:93:68:58:d8 (ED25519)
8000/tcp  open  http    ttyd 1.7.3-a2312cb (libwebsockets 3.2.0)
|_http-title: ttyd - Terminal
|_http-server-header: ttyd/1.7.3-a2312cb (libwebsockets/3.2.0)
65432/tcp open  http    Uvicorn
|_http-server-header: uvicorn
|_http-title: Site doesn't have a title (text/plain; charset=utf-8).
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 22: If we get creds we can abuse this !

Port 8000: Supposed to be a webpage, lets see what we can find

Port 65432: Supposed to be a webpage, lets see what we can find