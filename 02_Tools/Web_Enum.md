# 🌐 Web Enumeration (OSCP)
#tags: #web #enum #gobuster #oscp #http #https

Web enumeration is the **most common initial foothold** in OSCP-style labs.  
If ports **80 or 443** are open, **web enum is mandatory**.

---
## STEP 1 — Manual Browsing (Always First)

Before running tools, **open the site in a browser**.

Things to check immediately:
- Login pages
- File upload forms
- Admin panels
- Error messages
- References to users, admins, or internal tools

Why this matters:
- Manual browsing gives **context**
- Tools without context waste time
- Many OSCP web vulns are obvious by eye

---

## STEP 2 — Hidden Content & Directories

Web servers often expose **more than the homepage**.

Hidden paths may include:
- `/admin`
- `/uploads`
- `/backup`
- `/dev`
- `/test`
- `/api`

These often lead to:
- File uploads
- Misconfigured admin panels
- Debug or dev functionality

This is where **directory enumeration** comes in.

---

## STEP 3 — High-Value Web Features to Look For

### 🔹 File Uploads
**Top-tier target**

If uploads exist, ask:
- What file types are allowed?
- Where are files stored?
- Are files executed or just stored?

Uploads often lead to:
- Web shells
- Reverse shells
- Backend processing RCE

---

### 🔹 Login Pages
Login pages are valuable even without creds.

Why:
- Credential reuse is common
- Weak/default creds exist
- Credentials from SMB/configs often work here

---

### 🔹 Forms & Inputs
Forms may lead to:
- Command injection
- SQL injection
- File inclusion

Error messages matter:
- File paths
- Stack traces
- SQL errors

---

### 🔹 Source Code & JavaScript
Always:
- View page source
- Inspect `.js` files

Look for:
- Hidden endpoints
- API routes
- Hardcoded credentials
- Comments left by developers

---

## STEP 4 — Execution Paths (How Web Leads to Shells)

Web exploitation usually leads to shells via:
- File upload execution
- Command injection
- Server-side script abuse
- Misconfigured interpreters (PHP, Python, etc.)
---

## 🛠️ Web Enumeration Command Workflow

### 🔹 Confirm Web Service
```bash
nmap -p 80,443 -sV <target>
```

Confirms:
- HTTP vs HTTPS
- Web server type
- Version info (sometimes exploitable)




## ** Gobuster — Directory Enumeration**
Gobuster is used to **discover hidden directories and files**.

### **Basic Gobuster Command**
```bash
gobuster dir -u http://<IP> -w <wordlist>
```

### **Common OSCP Gobuster Command**
```bash
gobuster dir -u http://<IP> -w /usr/share/dirb/wordlists/common.txt -t 40 -o gobuster-common.txt
```

**Why these flags:**

- dir → directory brute forcing
- -u → target URL
- -w → wordlist
- -t 40 → faster scanning
- -o → save output for reference

### **Larger Scan**
```bash
gobuster dir -u http://<IP> -w /usr/share/dirb/wordlists/big.txt -t 40 -o gobuster-big.txt
```
Use **only if**:

- Small list found little
- You suspect more content exists



### **File Extensions**
```bash
gobuster dir -u http://<IP> -w <wordlist> -x php,txt,zip,conf,bak
```
This checks for:

- PHP files
- Config files
- Backups

## **🧠 How to Read Gobuster Output (What Matters)**

  

Focus on:

- **Status 200 / 301 / 302**
- Upload directories
- Admin paths
- Backup files


Note on 403:
- **403 = Forbidden** — the directory EXISTS but you don't have permission
- Worth noting in your notes — it confirms the path is real
- Sometimes 403 paths become accessible after auth or with different methods



## **🔗 Related Notes**

- [[Msfvenom]]
- [[Hydra]]
- [[Web_Login_Brute_Force]]
- [[htaccess_Bypass]]
- [[Netcat]]