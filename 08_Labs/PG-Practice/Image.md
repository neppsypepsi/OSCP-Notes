My IP: 192.168.45.211
Target IP: 192.168.170.178

nmap:
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.7 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 62:36:1a:5c:d3:e3:7b:e1:70:f8:a3:b3:1c:4c:24:38 (RSA)
|   256 ee:25:fc:23:66:05:c0:c1:ec:47:c6:bb:00:c7:4f:53 (ECDSA)
|_  256 83:5c:51:ac:32:e5:3a:21:7c:f6:c2:cd:93:68:58:d8 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title: ImageMagick Identifier
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 22: If we get creds we can exploit this!

Port 80: Lets browse around see what we can find...
- We find that we can upload something...im going to run gobuster to see where it gets caught.
	- No uploads directory. 
- Meanwhile I will try and upload a php file to see what happens
	- Says it only takes jpeg or png..lets try changing the file name to see if that works.
	- Uploading works..and it also kicks back to us a version number -> `Version: 6.9.6-4`
- Using the version I was able to search `ImageMagick 6.9.6 exploit github`, and I initially came across this [github](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://github.com/SudoIndividual/CVE-2023-34152/blob/main/README.md&ved=2ahUKEwjinIz1rMeVAxVMMjQIHW9jL84QFnoECBwQAQ&usg=AOvVaw0srI3omY5y0bRnuh-TJ3Fr)(CVE-2016-5118) , however after reading it they were saying there was some error, and then they said the better one is this [one](https://github.com/SudoIndividual/CVE-2023-34152/tree/main)(CVE-2023-34152).
	- Nevertheless running the script works and we are in as www-data, thus finding the first flag -> 364b8288d8164d12d8a51f07ad4702ec
- /etc/passwd gives us no other users to login/pivot to other than root. From here I will run linpeas
- Linpeas shows us an suid binary that is vulnerable. 
	- -rwsr-sr-x 1 root root 1.6M Apr 16  2020 /usr/bin/strace
- Browsing [gtfobins](https://gtfobins.org/gtfobins/strace/#shell) we find that this command ends up giving us a root shell on the box.
- `strace -o /dev/null /bin/sh -p`
	- Root flag: 
