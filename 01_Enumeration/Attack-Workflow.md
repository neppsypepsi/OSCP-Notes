# 🧭 Attack Workflow — Step 0 → Root (OSCP)
![[Screenshot 2025-12-30 at 8.01.40 PM 1.png]]

This note is the **master playbook**.  
When stuck, tired, or under pressure, follow this **in order**.

---

## STEP 0 — VPN & Environment

If this step is wrong, everything else is pointless.

Before I touch nmap, gobuster, or anything else, I make sure:
- I am connected to the lab VPN
- My traffic is actually going through the tunnel
- I’m attacking from the correct machine

What I usually do:
- Start VPN in one terminal
- Leave it running the entire lab
- Never close or suspend that terminal

Command I always check:

```bash
ip a | grep tun0
```

What I expect to see:
- Interface named `tun0`
- An IP address on it (usually 10.x.x.x)

If I see tun0 with an IP:
→ VPN is up

If tun0 does NOT exist:
→ VPN is NOT connected
→ Stop and fix this first

If tun0 exists but has no IP:
→ VPN failed to authenticate or dropped

Rule:
If VPN is unstable, every scan will lie to me.

Extra sanity checks I sometimes do:
- `ip route` → look for routes going through tun0
- `ping <known internal IP>` (if provided)

Once VPN is confirmed:
- Do NOT close the VPN terminal
- Do NOT suspend the machine
- Do NOT reconnect unless needed

Only move on when:
- VPN connected
- tun0 exists
- Internal IP assigned




## STEP 1 — Host Discovery

Goal here is simple:
Figure out what targets are alive and reachable.

At this stage, I am NOT exploiting anything.
I am just confirming:
- What IPs exist
- Which ones respond
- Whether a firewall is likely involved

If IPs are given to me:
- I trust the lab
- I still test reachability

If IPs are NOT given:
- I need to identify live hosts first

What I usually try first:
```bash
ping -c 2 <target_ip>
```

What ping tells me (and what it DOESN’T):

If ping replies:
→ Host is up
→ ICMP is allowed
→ Firewall may still exist

If ping does NOT reply:
→ Host might still be up
→ ICMP may be blocked
→ This does NOT mean the box is dead

Important:
Ping failure ≠ unreachable host

This matters because:
- Nmap defaults rely on host discovery
- If ICMP is blocked, nmap may skip the host entirely

Mental note I make immediately:
- If ping fails → I will probably need `-Pn` later

Sometimes I’ll sanity check with:
- `arp -a` (local networks)
- Known lab IP patterns (ms01, dc01, etc.)

Once I know:
- Target IP(s)
- Likely firewall behavior

I move on to full port scanning.

Rule:
I do NOT get stuck here.
This step is fast and intentional.

### **Tool references (if I need help)**

- [[Recon_with_NMAP]]
- [[VPN-Connections]]



## STEP 2 — Port Scanning (Breadth)

This step answers one question:
“What services are even available to attack?”

At this point I already know:
- Target IP(s)
- Whether ICMP is likely blocked

My default mindset:
- Assume there are weird ports
- Assume something important is NOT on 80/443
- Assume I will miss the box if I don’t scan all ports

What I usually do first:
- Full TCP port scan
- No scripts yet
- No version detection yet
- Just find what’s open

```bash
sudo nmap -p- -T4 <target_ip> -oN nmap-allports.log
```

If ping failed earlier, I immediately add:

```bash
sudo nmap -p- -Pn -T4 <target_ip> -oN nmap-allports.log
```

Why this scan exists:
- `-p-` → scan all 65,535 TCP ports
- Fast scan first so I don’t miss services
- Output saved so I don’t rescan blindly

Things I am watching while this runs:
- Any open port, even weird ones (e.g. 8094, 1337, 2222)
- Scan time (very slow scans may mean filtering)

While this scan is running:
- I do NOT guess services
- I do NOT start exploiting
- I wait for real data

Once it finishes:
I write down:
- Every open port
- No assumptions yet

Example notes I make:
- 21/tcp
- 80/tcp
- 8094/tcp

Mental rule:
If I didn’t scan all ports, I didn’t enumerate.

Only after I have the full port list do I move on.

### **Tool references (if I need help)**

- [[Recon_with_NMAP]]




## STEP 3 — Service Enumeration (Depth)

This is where I slow down and think.

At this point I already have:
- A confirmed live host
- A full list of open ports

Now I need to answer:
“What exactly is running on these ports, and how can it break?”

I do NOT exploit yet.
I enumerate until I understand the service.

What I do for EVERY open port:
- Identify the service
- Identify the version
- Identify whether authentication is required
- Look for obvious misconfigurations

```bash
sudo nmap -p <comma_separated_ports> -sCV -T4 <target_ip> -oN nmap-services.log
```

Why this scan matters:
- `-sC` → default scripts (safe, common info)
- `-sV` → version detection
- This often reveals:
  - Software versions
  - Hostnames
  - OS hints
  - Auth requirements

For each open port, I literally ask myself:

- What service is this?
- Is this normal for this port?
- Does it need creds?
- Does this version ring a bell?
- Have I seen this exploited before?

Examples of things I pay attention to:
- FTP allows anonymous login
- SMB signing disabled
- Web server leaks version info
- Weird services on high ports
- Banner reveals product name/version

Important OSCP mindset:
Enumeration ≠ running tools blindly.
Enumeration = understanding behavior.

If I don’t understand what a service does:
- I Google the service name
- I read the banner
- I look at default configs

Only AFTER I know the service and version:
- I check SearchSploit
- I think about exploitation paths

### **Real OSCP decision points at STEP 3**

- If service needs creds → note it and move on
    
- If service exposes info anonymously → dig deeper
    
- If service version looks old → SearchSploit
    
- If web is present → STEP 4 immediately

### **Common mistakes at STEP 3**

- Skipping version detection
    
- Ignoring weird ports
    
- Assuming web is “normal”
    
- Running exploits without reading what they do

### **Tool references (if I need help)**

- [[Recon_with_NMAP]]
- [[SearchSploit]]
- [[Port-Overview-and-Priorities]]



## STEP 4 — Web Enumeration (If Applicable)

This step triggers if I see:
- 80/tcp
- 443/tcp
- Any HTTP service on a weird port (8080, 8094, etc.)

Web services are dangerous because:
- They expose logic
- They often run as privileged users
- One small mistake = shell

First thing to do:
- Open the site in a browser
- Click everything
- Read everything

not exploiting yet.
I am trying to understand how the site works.


Things I look for immediately:
- Login pages
- Upload functionality
- Forms
- Error messages
- Version banners
- File names in URLs
- Weird behavior

Questions I ask myself:
- Is this static or dynamic?
- Is there authentication?
- Is this custom or a known framework?
- Does user input affect the backend?





If the site looks “boring”:

- That usually means hidden directories exist
    
- I move to directory enumeration

At this point I want to know:
- What paths exist that I can’t see
- Whether uploads, backups, or admin panels exist

Usually run directory brute forcing next.

Notes to self:

- /uploads
    
- /admin
    
- /backup
    
- /config
    
- /dev
    
- /old
    

If I find:

- Upload directories
    
- Downloadable files
    
- Executables
    
    → This is HIGH priority

### **Upload Scenarios (IMPORTANT)**
> “What am I allowed to upload, and what happens to the file after?”

#### **Scenario 1 — I can upload files, but they don’t execute**

- File lands in /uploads
- Accessing it in browser just downloads it
- Backend might process it later

→ Look for:

- Backend jobs (automated processes that pick up and handle uploaded files)
- Cron jobs (scheduled tasks that run on a timer — e.g. every minute, every hour — and may process files in that upload directory)
- File processing endpoints (API routes or scripts that read and do something with an uploaded file, like resize an image or parse a document — if they execute code from the file, that's RCE)

#### **Scenario 2 — I can upload files AND they execute**

- PHP / ASPX / JSP environment
- Uploading .php or .aspx runs code

→ Immediate RCE candidate


#### **Scenario 3 — Filters exist**

- .php blocked
    
- Try:
    
    - .php.jpg
    - .phtml
    - .phar
    - .htaccess
    
    

  

#### Scenario 4 — I can create directories/files as a USER (not root)

This happens when:
- I have user-level access (shell or web)
- I can write to a directory
- That directory is either:
  - Inside the web root
  - Or mapped/served by the web server

Important:
- I do NOT need root for this
- Execution depends on how the web server handles the directory

What I immediately check:
- Is this directory accessible via browser?
- Are files served or executed?
- Does PHP (or similar) run here?

If PHP does NOT execute:
- I check if `.htaccess` is allowed
- I test whether execution rules can be changed

If PHP DOES execute:
- This is a direct web shell opportunity

Important distinction:
- `.htaccess` affects web execution only
- Reboot/cron/startup execution is a DIFFERENT path

Mental rule:
If I can write to a web-accessible directory → I assume RCE is possible until proven otherwise

### **Tool references (if I need help)**

- [[Web_Enum]]
- [[htaccess_Bypass]]
- [[Msfvenom]]




## STEP 5 — Initial Exploitation (Foothold)

This is where I stop “looking” and start acting.

By the time I’m here, I should have ONE clear reason I think I can get code execution:
- A vulnerable service + exploit
- A web upload or command injection
- Valid credentials for a remote service
- A misconfiguration that allows execution


Common real foothold situations I’ve seen:
- An exploit that runs `calc.exe` by default
- A web upload that lets me place files but not run them
- Credentials that work for SMB / RDP / WinRM
- An exploit that needs the IP and payload changed


### **Typical foothold paths (decision-based)**

If I have a public exploit:
- I read the exploit first
- I look for:
  - Hardcoded IPs
  - Hardcoded filenames
  - Hardcoded commands
- I test with something harmless (like whoami)

If I have a web upload:
- I upload a file
- I confirm where it lands
- I check if it executes
- If it doesn’t:
  - I look for a trigger
  - I look for backend processing
  - I check execution rules (.htaccess, handlers)

If I have credentials:
- I test them against services
- I do NOT assume they give admin
- I take the lowest shell I can get

Payload delivery ≠ payload execution

Just because I:
- Uploaded a file
- Downloaded a file
- Dropped a payload

Does NOT mean it will run.

Almost every foothold requires:
1. Deliver payload
2. Trigger execution



The moment I have:
- Any command execution
- Any shell (even unstable)
- Any access as a user

I stop exploiting and move to STEP 6.

I do NOT:
- Try to escalate immediately
- Keep firing exploits
- Overcomplicate the foothold

Foothold first. Everything else later.

### **Tool references (if I need help)**

- [[SearchSploit]]
- [[Msfvenom]]
- [[htaccess_Bypass]]
- [[Netcat]]




## STEP 6 — Shell Stabilization

If the shell feels fragile, I stop everything else and fix it.

I do NOT start privilege escalation with a bad shell.
That’s how shells die and time gets wasted.

Signs my shell is unstable:
- No tab completion
- Ctrl+C kills the shell
- Output is delayed or broken
- Commands randomly fail
- It’s a one-command-at-a-time shell

This matters because:
- Enumeration tools will break
- File transfers may fail
- I’ll accidentally kill my access
### **Tool references (if I need help)**

- [[Netcat]]
- [[Msfvenom]]
- [[Nano]]




## STEP 7 — Local Enumeration (Post-Foothold)

This is where most OSCP boxes are actually solved.

If I have a shell and don’t know what to do next,
this is the step I’m in.

My goal here:
Find ONE reliable path to higher privileges.


Before running tools, I sanity-check:
Linux:
- whoami
- id
- groups
- sudo -l
- Writable directories

Windows:
- whoami
- whoami /priv
- net user
- net localgroup
- What directories I can write to

Why PEAS tools matter:
- This is Nmap, but local
- I’m not expected to find privesc blind
- They surface things I forget to check

Windows:
- Transfer winPEAS
- Run it and let it finish

Linux:
- Transfer linPEAS
- Run it and let it finish


### **Things I care about most from PEAS output**
Windows:
- SeImpersonatePrivilege
- Writable services or binaries
- Scheduled tasks
- Stored credentials
- Powershell history
- Registry secrets

Linux:
- SUID binaries
- Cron jobs
- Writable scripts
- Credentials in files
- Weak permissions


### **If PEAS finds nothing obvious**
When it does happen cause it will:
- I re-check services manually
- I check startup scripts
- I look for credential reuse
- I check GTFOBins (gtfobins.github.io) — a searchable list of Unix binaries that can be abused for privilege escalation if misconfigured (SUID, sudo, capabilities, etc.)

PEAS missing something ≠ no privesc exists

The moment I identify:
- A writable service
- A weak permission
- A credential path
- A known privilege abuse

I stop enumerating and move to STEP 8.

### **Tool references (if I need help)**

- [[winPEAS]]
- [[Priv_Esc]]
- [[File_Transfer]]

## STEP 8 — Privilege Escalation

Common real privesc paths:
- Writable service binary
- Weak scheduled task
- Token impersonation (Windows) — if SeImpersonatePrivilege is enabled, tools like PrintSpoofer can impersonate the SYSTEM token and give you a SYSTEM shell
- SUID binary abuse (Linux) — binaries with the SUID bit set run as their owner (often root) regardless of who executes them; GTFOBins shows how to exploit these
- Credential reuse
- Misconfigured permissions

I do ONE thing at a time:
- Modify exactly what enum showed
- Keep payloads simple
- Avoid unnecessary tools

I do NOT:
- Try multiple techniques at once
- Blindly run kernel exploits
- Assume escalation must be complicated


### **Tool references (if I need help)**

- [[Priv_Esc]]
- [[Msfvenom]]
- [[winPEAS]]




## STEP 9 — Proof & Documentation

This step is mandatory.
A solved box without proof is a failed box.

Once I have root / SYSTEM:
- I stop attacking
- I collect proof
- I document clearly

- Proof file contents
- Commands used
- Exploit chain in order
	How did I get in?
	What service did I exploit?
	What creds did I use?
	How did I escalate?
