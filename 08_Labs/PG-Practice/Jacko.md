My IP
```
192.168.45.207
```

Target IP
```
192.168.207.66
```

# nmap:
```
PORT      STATE SERVICE       VERSION
80/tcp    open  http          Microsoft IIS httpd 10.0
| http-methods: 
|_  Potentially risky methods: TRACE
|_http-server-header: Microsoft-IIS/10.0
|_http-title: H2 Database Engine (redirect)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds?
5040/tcp  open  unknown
7680/tcp  open  tcpwrapped
8082/tcp  open  http          H2 database http console
|_http-title: H2 Console
9092/tcp  open  XmlIpcRegSvc?
49664/tcp open  msrpc         Microsoft Windows RPC
49665/tcp open  msrpc         Microsoft Windows RPC
49666/tcp open  msrpc         Microsoft Windows RPC
49667/tcp open  msrpc         Microsoft Windows RPC
49668/tcp open  msrpc         Microsoft Windows RPC
49669/tcp open  msrpc         Microsoft Windows RPC
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port9092-TCP:V=7.99%I=7%D=9/23%Time=6AB42075%P=x86_64-pc-linux-gnu%r(NU
SF:LL,516,"\0\0\0\0\0\0\0\x05\x009\x000\x001\x001\x007\0\0\0F\0R\0e\0m\0o\
SF:0t\0e\0\x20\0c\0o\0n\0n\0e\0c\0t\0i\0o\0n\0s\0\x20\0t\0o\0\x20\0t\0h\0i
SF:\0s\0\x20\0s\0e\0r\0v\0e\0r\0\x20\0a\0r\0e\0\x20\0n\0o\0t\0\x20\0a\0l\0
SF:l\0o\0w\0e\0d\0,\0\x20\0s\0e\0e\0\x20\0-\0t\0c\0p\0A\0l\0l\0o\0w\0O\0t\
SF:0h\0e\0r\0s\xff\xff\xff\xff\0\x01`\x05\0\0\x024\0o\0r\0g\0\.\0h\x002\0\
SF:.\0j\0d\0b\0c\0\.\0J\0d\0b\0c\0S\0Q\0L\0N\0o\0n\0T\0r\0a\0n\0s\0i\0e\0n
SF:\0t\0C\0o\0n\0n\0e\0c\0t\0i\0o\0n\0E\0x\0c\0e\0p\0t\0i\0o\0n\0:\0\x20\0
SF:R\0e\0m\0o\0t\0e\0\x20\0c\0o\0n\0n\0e\0c\0t\0i\0o\0n\0s\0\x20\0t\0o\0\x
SF:20\0t\0h\0i\0s\0\x20\0s\0e\0r\0v\0e\0r\0\x20\0a\0r\0e\0\x20\0n\0o\0t\0\
SF:x20\0a\0l\0l\0o\0w\0e\0d\0,\0\x20\0s\0e\0e\0\x20\0-\0t\0c\0p\0A\0l\0l\0
SF:o\0w\0O\0t\0h\0e\0r\0s\0\x20\0\[\x009\x000\x001\x001\x007\0-\x001\x009\
SF:x009\0\]\0\r\0\n\0\t\0a\0t\0\x20\0o\0r\0g\0\.\0h\x002\0\.\0m\0e\0s\0s\0
SF:a\0g\0e\0\.\0D\0b\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\.\0g\0e\0t\0J\0d\0b\0c\0
SF:S\0Q\0L\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\(\0D\0b\0E\0x\0c\0e\0p\0t\0i\0o\0n
SF:\0\.\0j\0a\0v\0a\0:\x006\x001\x007\0\)\0\r\0\n\0\t\0a\0t\0\x20\0o\0r\0g
SF:\0\.\0h\x002\0\.\0m\0e\0s\0s\0a\0g\0e\0\.\0D\0b\0E\0x\0c\0e\0p\0t\0i\0o
SF:\0n\0\.\0g\0e\0t\0J\0d\0b\0c\0S\0Q\0L\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\(\0D
SF:\0b\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\.\0j\0a\0v\0a\0:\x004\x002\x007\0\)\0\
SF:r\0\n\0\t\0a\0t\0\x20\0o\0r\0g\0\.\0h\x002\0\.\0m\0e\0s\0s\0a\0g\0e\0\.
SF:\0D\0b\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\.\0g\0e\0t\0\(\0D\0b\0E\0x\0c\0e\0p
SF:\0t\0i\0o\0n\0\.\0j\0a\0v\0a\0:\x002\x000\x005\0\)\0\r\0\n\0\t\0a\0t\0\
SF:x20\0o\0r\0g\0\.\0h\x002\0\.\0m\0e\0s\0s\0a\0g\0e\0\.\0D\0b")%r(informi
SF:x,516,"\0\0\0\0\0\0\0\x05\x009\x000\x001\x001\x007\0\0\0F\0R\0e\0m\0o\0
SF:t\0e\0\x20\0c\0o\0n\0n\0e\0c\0t\0i\0o\0n\0s\0\x20\0t\0o\0\x20\0t\0h\0i\
SF:0s\0\x20\0s\0e\0r\0v\0e\0r\0\x20\0a\0r\0e\0\x20\0n\0o\0t\0\x20\0a\0l\0l
SF:\0o\0w\0e\0d\0,\0\x20\0s\0e\0e\0\x20\0-\0t\0c\0p\0A\0l\0l\0o\0w\0O\0t\0
SF:h\0e\0r\0s\xff\xff\xff\xff\0\x01`\x05\0\0\x024\0o\0r\0g\0\.\0h\x002\0\.
SF:\0j\0d\0b\0c\0\.\0J\0d\0b\0c\0S\0Q\0L\0N\0o\0n\0T\0r\0a\0n\0s\0i\0e\0n\
SF:0t\0C\0o\0n\0n\0e\0c\0t\0i\0o\0n\0E\0x\0c\0e\0p\0t\0i\0o\0n\0:\0\x20\0R
SF:\0e\0m\0o\0t\0e\0\x20\0c\0o\0n\0n\0e\0c\0t\0i\0o\0n\0s\0\x20\0t\0o\0\x2
SF:0\0t\0h\0i\0s\0\x20\0s\0e\0r\0v\0e\0r\0\x20\0a\0r\0e\0\x20\0n\0o\0t\0\x
SF:20\0a\0l\0l\0o\0w\0e\0d\0,\0\x20\0s\0e\0e\0\x20\0-\0t\0c\0p\0A\0l\0l\0o
SF:\0w\0O\0t\0h\0e\0r\0s\0\x20\0\[\x009\x000\x001\x001\x007\0-\x001\x009\x
SF:009\0\]\0\r\0\n\0\t\0a\0t\0\x20\0o\0r\0g\0\.\0h\x002\0\.\0m\0e\0s\0s\0a
SF:\0g\0e\0\.\0D\0b\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\.\0g\0e\0t\0J\0d\0b\0c\0S
SF:\0Q\0L\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\(\0D\0b\0E\0x\0c\0e\0p\0t\0i\0o\0n\
SF:0\.\0j\0a\0v\0a\0:\x006\x001\x007\0\)\0\r\0\n\0\t\0a\0t\0\x20\0o\0r\0g\
SF:0\.\0h\x002\0\.\0m\0e\0s\0s\0a\0g\0e\0\.\0D\0b\0E\0x\0c\0e\0p\0t\0i\0o\
SF:0n\0\.\0g\0e\0t\0J\0d\0b\0c\0S\0Q\0L\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\(\0D\
SF:0b\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\.\0j\0a\0v\0a\0:\x004\x002\x007\0\)\0\r
SF:\0\n\0\t\0a\0t\0\x20\0o\0r\0g\0\.\0h\x002\0\.\0m\0e\0s\0s\0a\0g\0e\0\.\
SF:0D\0b\0E\0x\0c\0e\0p\0t\0i\0o\0n\0\.\0g\0e\0t\0\(\0D\0b\0E\0x\0c\0e\0p\
SF:0t\0i\0o\0n\0\.\0j\0a\0v\0a\0:\x002\x000\x005\0\)\0\r\0\n\0\t\0a\0t\0\x
SF:20\0o\0r\0g\0\.\0h\x002\0\.\0m\0e\0s\0s\0a\0g\0e\0\.\0D\0b");
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time: 
|   date: 2026-09-23T18:57:28
|_  start_date: N/A
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required

```


Port 139/445 (SMB):
- Was denied anonymous access


Port 80:
![[Pasted image 20260924102845.png]]
- Seems informational if not anything (more like a rabbit hole)

Port 8082:
![[Pasted image 20260924103024.png]]

Forgot to mention that just by hitting connect logs us in. No need to put in a password...like there is no password. I had tried admin admin initially and admin password and that didn't work, only what was already there works. 


![[Pasted image 20260924103041.png]]
- Here it seems like we can execute sql commands. Now (for claude) im not too familiar on how to use sql to my advantage then other than brute forcing my way past login pages, or trying to use a search bar to dump hidden info with sql commands (both with burpsuite), however here we have legit command execution with sql in this box above. What I think the intended method is, is to create a file to which we can browse to it and thats our reverse shell, or to create a new user, that we can then use to login via smb. Only issue with the second idea is idk where the password field would be based on our available things we can query with sql. 
- ![[Pasted image 20260924104005.png]]
	- One thing I do notice is at the bottom there apears to be some version number. I will try an see if I can find vulnerabilities with that. 
- ![[Pasted image 20260924104126.png]]
- Ahh what do you know. I end up finding this specific [exploit db](https://www.exploit-db.com/exploits/49384) page that says its vulnerable to RCE
![[Pasted image 20260924110543.png]]
- Here is after running the first sql command
![[Pasted image 20260924110649.png]]
- Here is after running the second
![[Pasted image 20260924110910.png]]
- Here is after running the third, and as you can see we end up seeing the whoami command worked and we see the user logged into this webserver is `jacko\tony` (backslash another indicator that we are on a windows machine.)
- I ended up not being able to execute dir and the reason why in simple terms is because the command `exec()` tries to look for a binary called dir on the machine. So the way to get around this is to execute `cmd.exe /c` so that any command I run gets first input into the command line first. 
- Here is proof of it working, and this dir command was important so I can see where we are actually at on the machine. ![[Pasted image 20260924112553.png]]
- I messed up as I kept using cmd.exe /c certutil.exe .... and it wasn't working, so instead of that I just removed the cmd.exe and just pasted in certutil as itself and it worked. My first thought was that nesting cmd.exe to then run another binary was the problem, but thats not actually it — `cmd.exe /c certutil` is a totally normal thing to run. The real reason is that `exec()` splits my string into separate arguments before Windows ever sees it, and that long certutil command line was getting chopped up wrong. Running certutil directly = fewer layers chewing on my arguments. Rule of thumb: fewer layers, fewer things to mangle. ![[Pasted image 20260924121116.png]]
- In order to get the command to execute the file, I needed to add double slashes since the first ones get eaten. ![[Pasted image 20260924202131.png]]
- We get a shell! After we get the shell we find after running `whoami /priv` that we have the SeImpersonate privilege. Small thing I got wrong at first — the user is **tony**, not jacko. `jacko\tony` is `COMPUTERNAME\username`, so jacko is the machine and tony is the account. Tony is the one holding the privilege. ![[Pasted image 20260924203115.png]]
- This is now a great opportunity to run a potato exploit on this box. 

![[Pasted image 20260925204722.png]]
- Here there are a few important points to be made. We first pull over the PrintSpoofer potato file and name it privesc.exe. To make things easier I tried just changing directories to where I dropped the file, and wanted to see if the file was there, and just like when we were first trying to exploit the `JNIScriptEngine_eval`, we again cannot see the file. Turns out this is NOT something the lab authors did to me — its the **default Windows permissions on `C:\Windows\Temp`**. Normal users get traverse + write but NOT list or read. So:
	- `dir` shows nothing → I dont have list permission
	- full path works → traverse is enough as long as I already know the filename
	- and later on `type C:\Windows\Temp\out.txt` gave me `Access is denied` → no read permission either
	- **Rule for next time:** `C:\Windows\Temp` is fine to drop files in and execute from, but useless for reading anything back. If I need to read output, write it to `C:\Users\Public` instead.
- So calling the full path does run PrintSpoofer, but it still doesnt give me SYSTEM. It gets to `[+] Named pipe listening...` and then `[-] Operation failed or timed out.` The reason why matters — PrintSpoofer works by tricking the **Print Spooler service** into connecting to a named pipe it controls. I checked the service:
```cmd
sc query spooler
STATE : 1  STOPPED
WIN32_EXIT_CODE : 1077  (0x435)     <- ERROR_SERVICE_NEVER_STARTED
```
	- Spooler is off and has never even started since boot. No spooler = nothing to trick, so PrintSpoofer sets up its half and just waits forever. Thats not a syntax problem I can flag my way around, the exploits prerequisite straight up isnt there.
	- (Also checked `sc query windefend` → same thing, STOPPED / 1077. Defender is off on this box too. Services are trimmed on this image.)
	- **Lesson: when a potato fails, check whether the service it depends on is actually running.** That one check saves a ton of guessing.
- SO, the next best step is to try the other potato file (GodPotato-NET4.exe) from our [[Potato_Attacks]] note. The reason GodPotato works where PrintSpoofer didnt is that it coerces the **DCOM/RPC** subsystem instead of the spooler, and DCOM/RPC is core Windows plumbing that cant just be switched off. Same token theft, different SYSTEM process to trick. 
- What is important about GodPotato is that it steals the impersonation token and then **spawns a brand new process** running as SYSTEM (Windows gives that new process its own PID). It isnt upgrading my current shell and it never will — it creates SYSTEM processes *next to* it. And because that new process gets its own stdout, which is not hooked up to my netcat socket, I never see its output. Thats why `-cmd "cmd /c whoami"` looked like it did nothing even though it actually worked.
	- Two ways around this. If I just need output, have the SYSTEM process write to a file I can read: `-cmd "cmd /c whoami > C:\Users\Public\out.txt"` then `type` it from my current shell. If I want an actual interactive SYSTEM shell, I have to pull over a reverse shell and have the new process call back to a second listener on a different port from the one Im already sitting on. 
- The issue I was running into was that I did end up catching the shell but for some reason it was not letting me run my commands -> ![[Pasted image 20260925205557.png]]
	- Being honest, I never fully proved why this one went quiet. What I *did* rule out: it wasnt AV (Defender is stopped on this box), it wasnt a bad transfer (`dir C:\Users\Public\rootshell.exe` showed exactly 7,168 bytes, matching what msfvenom reported), and it wasnt my privesc (the callback landed at all, which means GodPotato's token theft worked). So the fault was inside the msfvenom payload itself. Best guess is the raw shellcode stub has to hand-roll its own process creation and handle plumbing and did that badly when launched as SYSTEM from a service-spawned parent with a stripped environment — but thats a guess, not something I confirmed.
	- Useful takeaway regardless: **the connection landing at all proved the escalation worked.** Dont let a payload problem convince me the privesc failed.
- So the real fix to this was to then bring over netcat (the executable itself) and to then use it to call back to our machine. `nc.exe` is just a normal program — `-e cmd.exe` hands cmd's stdin/stdout/stderr straight to the socket using standard Windows handle inheritance, so way fewer moving parts than raw shellcode. Binary lives on Kali at `/usr/share/windows-resources/binaries/nc.exe` (see [[Netcat]]).
	- General rule I want to remember: **if a msfvenom payload is acting weird and I already have arbitrary command execution, swap to a known-good static binary instead of debugging shellcode.** Caveat though — nc.exe is old and heavily signatured, so it only worked this easily because Defender was off here. On a box with AV actually running, nc.exe would be one of the first things killed, so check `sc query windefend` before betting on it.![[Pasted image 20260925205720.png]]
- Here we can see that the command does end up working giving me a shell as SYSTEM, thus allowing me to find both local.txt(`18794d2c265ac38d1314e8e28bf1909c`), and proof.txt (`9305b1d565e8ffb71549d47d4e8477c4`) files.![[Pasted image 20260925210002.png]]