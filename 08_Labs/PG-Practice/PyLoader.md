My IP: 192.168.45.247
Target IP: 192.168.225.26


# nmap:
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

- Here we find a very basic login page with not much to do.
	- I tried admin admin, and admin password with no luck.
- A google search with the potential version number of the web page we find a hit for [CVE-2023-0297](https://github.com/overgrowncarrot1/CVE-2023-0297).
- Running the script gets us root allowing us to find the flag -> `15f32d2f6e34ee1d4a1691662095d2be`




