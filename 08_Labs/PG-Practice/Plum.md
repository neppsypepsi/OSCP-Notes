My IP: 192.168.45.247
Target IP: 192.168.225.28

# nmap:
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 c9:c3:da:15:28:3b:f1:f8:9a:36:df:4d:36:6b:a7:44 (RSA)
|   256 26:03:2b:f6:da:90:1d:1b:ec:8d:8f:8d:1e:7e:3d:6b (ECDSA)
|_  256 fb:43:b2:b0:19:2f:d3:f6:bc:aa:60:67:ab:c1:af:37 (ED25519)
80/tcp open  http    Apache httpd 2.4.56 ((Debian))
|_http-title: PluXml - Blog or CMS, XML powered !
|_http-server-header: Apache/2.4.56 (Debian)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel


```


- Observing the web page we see a fairly simple article page.
![[Pasted image 20260724160857.png]]
`http://192.168.225.28/core/admin/auth.php?p=/core/admin/`
![[Pasted image 20260724160925.png]]
- However clicking the administration button we end up resolving to a new admin, login page. 
![[Pasted image 20260724161017.png]]
- admin admin ends up working. 
- We then see a version number for this web page -> `PluXml 5.8.7`. We can use this for looking up exploits.
- We end up finding [CVE-2022-25018](https://github.com/erlaplante/pluxml-rce/tree/main) , and after running the script, we end up getting a shell as `www-data`, allowing us to get our first flag -> `16895b5d5fdb6a814e848ba4926f8ad7`
- Observing our Linpeas output, this file path in particular caught my eye.
![[Pasted image 20260724164617.png]]
- Reading this file, we see a message froom root to www-data
![[Pasted image 20260724164756.png]]
- using this password we are then able to log in as root finding our last flag -> `57d17917621328f249d7ecaf84b1428b`
