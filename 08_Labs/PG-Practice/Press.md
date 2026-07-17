My IP: 192.168.45.250
Target IP: 192.168.243.29
nmap:
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 c9:c3:da:15:28:3b:f1:f8:9a:36:df:4d:36:6b:a7:44 (RSA)
|   256 26:03:2b:f6:da:90:1d:1b:ec:8d:8f:8d:1e:7e:3d:6b (ECDSA)
|_  256 fb:43:b2:b0:19:2f:d3:f6:bc:aa:60:67:ab:c1:af:37 (ED25519)
80/tcp   open  http    Apache httpd 2.4.56 ((Debian))
|_http-title: Lugx Gaming Shop HTML5 Template
|_http-server-header: Apache/2.4.56 (Debian)
8089/tcp open  http    Apache httpd 2.4.56 ((Debian))
|_http-server-header: Apache/2.4.56 (Debian)
|_http-title: FlatPress
|_http-generator: FlatPress fp-1.2.1
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```


- For these images we find proof that one of our php commands end up working and the other doesnt. The reason being is because the web page blocks the `$_GET` token however ends up accepting ``, allowing us to get rce through the search bar.
- 
![[Pasted image 20260716112214.png]]
![[Pasted image 20260716112103.png]]