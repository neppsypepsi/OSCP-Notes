My IP: 192.168.45.205
Target IP: 192.168.180.214

# nmap:
```
Not shown: 55531 filtered tcp ports (no-response), 10001 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 9.6p1 Ubuntu 3ubuntu13.9 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 f2:5a:a9:66:65:3e:d0:b8:9d:a5:16:8c:e8:16:37:e2 (ECDSA)
|_  256 9b:2d:1d:f8:13:74:ce:96:82:4e:19:35:f9:7e:1b:68 (ED25519)
80/tcp   open  http    Apache httpd 2.4.58 ((Ubuntu))
|_http-title: Spider Society
|_http-server-header: Apache/2.4.58 (Ubuntu)
2121/tcp open  ftp     vsftpd 3.0.5
Service Info: OSs: Linux, Unix; CPE: cpe:/o:linux:linux_kernel
```

Port 80:
Here on port 80 we find a very basic webpage. We notice in the top right that there is a login button, however clicking brings us to a new page that redirects us back to the home page. See the next two images below.
![[Pasted image 20260809223316.png]]Then 
![[Pasted image 20260809223609.png]]But we notice that at the bottom of the web page there is what appears to be a domain or hint to a host name that is also used to resolve to a webpage. So the next step is to add it to our /etc/hosts file.
![[Pasted image 20260809223633.png]]

- I ended up having to user a bigger word list to run against my nmap scan, and with that said I have now set it to the standard of what I should always be running when running scans against IP's or host names![[Pasted image 20260809234000.png]]
	- There was the concern that because the 2 possible host names would give me two different outputs when running the go-buster script. However it was later determined that when running this scan on both variants that they both show that the `/libspider` directory is in fact something we can resolve to
- After browsing to the new host name, we find a login panel.![[Pasted image 20260809234312.png]]
- admin:admin ends up working.
- After clicking the communications tab we are presented with some credentials that we can use to connect over port 2121.![[Pasted image 20260809234617.png]]
- After connecting as this user, we end up finding a hidden file in the libspiders folder. The file cannot be retrieved and pulled through the ftp session, however it was possible to view the file contents by browsing to it in the webrowser. Additionally, there were hints within some of the other files that there was a directory created and to browse to it, to consider adding a forward slash then the file name to find the credentials file. ![[Pasted image 20260810001137.png]]![[Pasted image 20260810001231.png]]
- http://offsec.lab/libspider/.fuhfjkzbdsfuybefzmdbbzdcbhjzdbcukbdvbsdvuibdvnbdvenv
- I only able to browse to it by placing http before hand the IP. and here we find more credentials. ![[Pasted image 20260810001249.png]]
- For safety measure I decided to try the first credentials with ssh and it did not work, however for this other user spidey:WithGreatPowerComesGreatSecurity99! , we are able to get a shell. 
	- Thus allowing me to find the first flag of ->``
- Here we find that we can run a few things as sudo. The exclamation mark indicates that we actually cannot run /bin/bash as root.![[Pasted image 20260810001849.png]]
- I ended up finding that I couldn't do much just but sudo and running the command. however that does say service, so if we could be able to tweak a service file that we can start and stop then we have a good chance.![[Pasted image 20260810002720.png]]
- As we can see there is a file that we can edit. I ended up changing one of the ExecStart lines to changing the bit set for the /bin/bash file. ![[Pasted image 20260810004425.png]]
- Thus allowing us to find the last flag of -> `266221d1b5325f320656f4568a30a515`