My IP: 192.168.45.211
Target IP: 192.168.166.91

# nmap:
```
PORT    STATE  SERVICE VERSION
22/tcp  open   ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 62:36:1a:5c:d3:e3:7b:e1:70:f8:a3:b3:1c:4c:24:38 (RSA)
|   256 ee:25:fc:23:66:05:c0:c1:ec:47:c6:bb:00:c7:4f:53 (ECDSA)
|_  256 83:5c:51:ac:32:e5:3a:21:7c:f6:c2:cd:93:68:58:d8 (ED25519)
25/tcp  open   smtp    Postfix smtpd
|_smtp-commands: onlyrands.com, PIPELINING, SIZE 10240000, VRFY, ETRN, STARTTLS, ENHANCEDSTATUSCODES, 8BITMIME, DSN, SMTPUTF8, CHUNKING
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=onlyrands.com
| Subject Alternative Name: DNS:onlyrands.com
| Not valid before: 2024-06-07T09:33:24
|_Not valid after:  2034-06-05T09:33:24
80/tcp  open   http    nginx 1.18.0 (Ubuntu)
|_http-title: OnlyRands
|_http-server-header: nginx/1.18.0 (Ubuntu)
443/tcp closed https
Service Info: Host:  onlyrands.com; OS: Linux; CPE: cpe:/o:linux:linux_kernel

```