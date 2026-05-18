My Ip: 192.168.45.216
IP: 192.168.125.26
NMAP:
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 b9:bc:8f:01:3f:85:5d:f9:5c:d9:fb:b6:15:a0:1e:74 (ECDSA)
|_  256 53:d9:7f:3d:22:8a:fd:57:98:fe:6b:1a:4c:ac:79:67 (ED25519)
9666/tcp open  http    CherryPy wsgiserver
| http-title: Login - pyLoad 
|_Requested resource was /login?next=http://192.168.125.26:9666/
| http-robots.txt: 1 disallowed entry 
|_/
|_http-server-header: Cheroot/8.6.0
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```
