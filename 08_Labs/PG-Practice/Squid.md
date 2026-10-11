My IP:
```
192.168.45.225
```

Target IP:
```
192.168.149.189
```

# nmap:
```
PORT      STATE SERVICE       VERSION
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds?
3128/tcp  open  http-proxy    Squid http proxy 4.14
|_http-server-header: squid/4.14
|_http-title: ERROR: The requested URL could not be retrieved
49666/tcp open  msrpc         Microsoft Windows RPC
49667/tcp open  msrpc         Microsoft Windows RPC
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required
| smb2-time: 
|   date: 2026-10-10T20:33:15
|_  start_date: N/A
```

Port 139/445:
- Here we try anonymous access but fail
![[Pasted image 20261010170529.png]]

Port 135:
- We try anonymous access as well here but fail ![[Pasted image 20261010170612.png]]


Port 3128:
- What we do notice is that the service listed for this port is the "http-proxy", and we try browsing to this ports http page (if any), and we see an error page. ![[Pasted image 20261010171027.png]]

- We do see that there is a version number listed. This ended up being a dead end as I tried to find exploits for this service but found nothing
- But the thing is http proxy's could be configured incorrectly to which ports behind it could be accessed as the web user, through localhost. This is possible if all HTTP traffic is routed through that specific port is allowed, as we can then set up our own proxy to do that. 
- The two ways we can test for this is by using this command found in [[Linux_Common_Commands]] -> 
```bash
for port in 80 443 3128 8080 8000 8081 8443 3306 5985 9090; do
  echo -n "port $port: "
  curl -s -o /dev/null -w "%{http_code}\n" -x http://192.168.149.189:3128 http://127.0.0.1:$port
```

- Anything with a 200 response means that it is accessible if all our http traffic is routed through port 3128. And here was my Output:
```
done
port 80: 503
port 443: 503
port 3128: 400
port 8080: 200
port 8000: 503
port 8081: 503
port 8443: 503
port 3306: 200
port 5985: 404
port 9090: 503
```
- We find that port 8080 ends up coming back to us with a 200 response,  meaning its accessible. The reason why it would spark more interest instead of port 3306 since typically port 8080 and http have correlation, and a google search reveals `Port 3306 is the default TCP network port used for client-server communication by MySQL, MariaDB, and Percona Server relational databases.` So probably not intractable.
- And what do you know, after we configure our foxy proxy to then try and query this port we find this when we try and reach port 8080.![[Pasted image 20261010172133.png]]
	- The importance of this is that we have new things to interact with. We can take a look at the phpinfo page, adminer, and phpmyadmin. 
	- I tried looking up default creds for this phpmyadmin service and ended up finding out root, with then the password field left blank ends up letting us get in.  ![[Pasted image 20261010172516.png]]
	- Here is what it looks like after we authenticated 
	- ![[Pasted image 20261010172636.png]]
		- I tried adminer and we end up finding a what appears to be a new service also revealing an entirley new version number, but I was not able to find any relevant exploits. Also looked up default creds and found nothing, and lastly there is info like `Database`, which we don't know based on the info we have. 
		- I also looked at phsysinfo and there wasn't anything to really interact with. 
		![[Pasted image 20261010173821.png]]![[Pasted image 20261010172430.png]]
	- We end up finding two potential methods to try and use this service to get a reverse shell. ![[Pasted image 20261010172913.png]]
		- or
	![[Pasted image 20261010172928.png]]
	- I tried creating my own test file with nothing in it just to see if the file upload is strict about file extensions and then to see if there hints to where the file lands after uploaded. I couldn't figure out any of that, so sql ended up being the next method. 
	- The idea was to create a file that uses php to make arbitrary actions. We know the web server runs php, and with the help of the phpinfo page, we can find out which directory the web root lives in, so that we can browse to it later.![[Pasted image 20261010180416.png]]
- Now we know we are going to create a file in the web root file path -> `C:/wamp/www/`
![[Pasted image 20261010174633.png]]

- Her we see the file go pulled over successfully
![[Pasted image 20261010175712.png]]
- Proof it worked. 
![[Pasted image 20261010175653.png]]
- The last thing we need to do is run the php script by specifying the file path, and as you can see we have a shell
![[Pasted image 20261010175750.png]]

- Here we find out that the user we are currently in as has the `seImpersonatePrivlege`, and that this server is running at least win10 based on the OS Version field. ![[Pasted image 20261010182750.png]]
- So the next best step from here would be to pull over the appropriate Potato attack tool to then use to get a shell as system![[Pasted image 20261010182847.png]]
- Here I was able to get both local and proof flags -> `5ab1e8b86539aa67eabdc680883a5bc8` and `8530970232b237803e0573c322a7bb04`