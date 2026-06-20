IP: 192.168.187.24
nmap:
```
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 b9:bc:8f:01:3f:85:5d:f9:5c:d9:fb:b6:15:a0:1e:74 (ECDSA)
|_  256 53:d9:7f:3d:22:8a:fd:57:98:fe:6b:1a:4c:ac:79:67 (ED25519)
8000/tcp open  http    WSGIServer 0.2 (Python 3.10.6)
|_http-title: Gerapy
|_http-cors: GET POST PUT DELETE OPTIONS PATCH
|_http-server-header: WSGIServer/0.2 CPython/3.10.6
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Steps:
	- check to see whats on webpage
		- There is a login page - admin admin works
	- Version: Gerapy v0.9.7
		- Check exploits 
	- ssh is open for connections with users