My IP: 192.168.45.164
Target IP: 192.168.193.186

# nmap:
```
PORT     STATE  SERVICE    VERSION
22/tcp   open   ssh        OpenSSH 9.6p1 Ubuntu 3ubuntu13.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 f2:5a:a9:66:65:3e:d0:b8:9d:a5:16:8c:e8:16:37:e2 (ECDSA)
|_  256 9b:2d:1d:f8:13:74:ce:96:82:4e:19:35:f9:7e:1b:68 (ED25519)
80/tcp   open   http       Apache httpd
|_http-server-header: Apache
|_http-title: Did not follow redirect to http://bitforge.lab/
| http-git: 
|   192.168.193.186:80/.git/
|     Git repository found!
|     .git/config matched patterns 'user'
|     Repository description: Unnamed repository; edit this file 'description' to name the...
|_    Last commit message: created .env to store the database configuration 
3306/tcp open   mysql      MySQL 8.0.40-0ubuntu0.24.04.1
|_ssl-date: TLS randomness does not represent time
| mysql-info: 
|   Protocol: 10
|   Version: 8.0.40-0ubuntu0.24.04.1
|   Thread ID: 135
|   Capabilities flags: 65535
|   Some Capabilities: Support41Auth, SupportsTransactions, LongPassword, ConnectWithDatabase, Speaks41ProtocolOld, IgnoreSigpipes, DontAllowDatabaseTableColumn, SwitchToSSLAfterHandshake, LongColumnFlag, FoundRows, SupportsLoadDataLocal, InteractiveClient, ODBCClient, Speaks41ProtocolNew, SupportsCompression, IgnoreSpaceBeforeParenthesis, SupportsMultipleResults, SupportsAuthPlugins, SupportsMultipleStatments
|   Status: Autocommit
|   Salt: \x01G\x08r\x01\x1D~C2+?\x0BT1t8\x16B\x19a
|_  Auth Plugin Name: caching_sha2_password
| ssl-cert: Subject: commonName=MySQL_Server_8.0.40_Auto_Generated_Server_Certificate
| Not valid before: 2025-01-15T14:38:11
|_Not valid after:  2035-01-13T14:38:11
9000/tcp closed cslistener
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```


Port 80:
- Trying to resolve to the webpage normally does not work, however it does show that it does show that it tries to reach "bitforge.lab". it would then be a good idea to add this domain to our etc hosts to see if there are further domains we should know about.
- Observing our nmap scan, there is a http-git at -> `192.168.193.186:80/.git/`
	- Clicking through logs we find a user and more info as to where credentials may be located.![[Pasted image 20260727125151.png|639]]
	- After searching all of the folders under this directory I couldn't find anything
		- I learned that I can pull the git logs along with content with git-dumper. Using the commit ID, I was able to view the commit and find credentials. ![[Pasted image 20260727144624.png]]
- Resolving to Bitforge.lab we can see when hovering over Employee Planning Portal there is a new domain of "plan.bitforge.lab". ![[Pasted image 20260727132225.png]]
	- Additionally this could have been found by running the correct ffuf command to follow redirects. The first run without `-r` failed because every Host returned an empty `302` (Size 0), so `plan` looked identical to every fake host. Adding `-r -ac` follows the redirect (real sizes appear) and auto-filters the boring default page, leaving `plan`: `ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u http://192.168.193.186 -H "Host: FUZZ.bitforge.lab" -r -ac` ![[Screenshot From 2026-07-27 13-34-05.png]]
- Adding it to our /etc/hosts, we arrive at a new login page, which even reveals a version number -> `Simple Online Planning v1.52.01` . We can use this to find possible exploits. 
	- All exploits require for us to be already logged into the dashboard. So far we haven't found valid creds. I tried all of the ones we came accross so far and still no.
- Using the credentials we found from the Git push, we can use them to log in to the MySQL service. Also this line -> ` $dsn = "mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4";` hints try MySQL.
- ![[Pasted image 20260727155401.png]]
- Logging in we can see there are 4 databases to observe. The one with interesting information ends up being `soplanning`.
![[Screenshot From 2026-07-27 16-10-09 1.png]]
"planning_user" catches my eye -> `describe planning_user;`
![[Pasted image 20260727161116.png]]
![[Pasted image 20260727161250.png]]
- Typically passwords wouldn't be that long, and after verfying first by trying them with the login page, and with the ssh service i came to the conclusion that its indeed hashed.
- Sure enough...![[Pasted image 20260727161412.png]]

---
# Where I got stuck
- After not being able to crack this hashed password, and after NOT being apply this hashed password directly into the password field to the login page, we can infer that the login page does not take a hashed password as a possible value, and that the default password was likely changed (admin:admin). The next best step would be to use the info we know, the default creds (admin:admin), to then use this to try and find the hashed version of the default creds in source code somewhere online. 
	- This would of course only work if the this hashed mechanism in the code was standard and not secondhandedly implemented by some web dev.
- The smarter probably more reliable option would be to find the [github](https://github.com/Worteks/soplanning/tree/master) of the code online.
	- Or a long shot could be just searching for the hashed password version of the default creds for the web page service (soplanning)
- Download the github repo, then do a grep search for admin, or something similar in hopes for a line that reveals the hashed password for the default creds![[Screenshot From 2026-07-29 22-39-39.png]]
- Luckily we do end up finding the hashed default password to admin/ADM, and we can use this to then try and and place the hashed password in the SQL database in hopes that the login page pulls creds directly from the SQL db, and that we have write access over the sql server as the user we are signed in as. ![[Screenshot From 2026-07-29 23-47-14.png]]
- Now after being able to login, we can see that we can add a task. There is the option to "Join a file", and there I uploaded a rev shell, and hovering over it provides me a new url, so I know I can browse to it.![[Pasted image 20260730182133.png]]
- Doing so I was able to get a shell as `www-data`. After trying to find the local.txt file, I was given no file path so I was sure that there was another user to bounce to, and sure enough reading the /etc/passwd file reveals another user named jack. ![[Pasted image 20260730182640.png]]****
- After greping for jacks password from the home directory i found nothing. Linpeas revealed nothing of interest and typically linpeas would be the step to get to root. So, I was left trying pspy. I found a mysqldump revealing the creds of jack, allowing us to find our first flag -> `a8dc9fa1e00b7c8f01d9f733089f9a02` ![[Pasted image 20260730192000.png]]
	- jack:j4cKF0rg3@445
- Running sudo -l as jack we find that we can run `/usr/bin/flask_password_changer` as root.![[Pasted image 20260730194752.png]]
- Reading what the file does ->![[Pasted image 20260730194823.png]]
- We learn that this is a directory and not a file. Changing directories we find a file called app.py. We end up having write permissions over the file so we can create our own malicious python code. ![[Pasted image 20260730194946.png]]![[Pasted image 20260730195014.png]]
- thus allowing us to run bash as root![[Pasted image 20260730195204.png|675]]
	- allowing me to find the last flag `b6154fcf0564e96139ff96436fdcbabe`