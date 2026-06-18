# Labs Index

> When starting a new box, create the file inside the right platform folder and link it here.

## Resources

- [OSCP-Like Box List (TJnull)](https://docs.google.com/spreadsheets/u/1/d/1dwSMIAPIam0PuRBkCiDI88pU3yzrqqHkDtBngUHNCw8/htmlview) — curated PG/HTB boxes relevant to OSCP

---

## PG-Practice

| Box | OS | Status | Foothold / Privesc |
|-----|----|--------|--------------------|
| [[Snookums]] | Linux | ✅ Complete | RFI via SimplePHPGal → MySQL creds → SSH as michael → writable /etc/passwd |
| [[ochima]] | Linux | ✅ Complete | Maltrail 0.52 unauth RCE → writable cron script |
| [[RubyDome]] | Linux | ✅ Complete | PDFKit CVE-2022-25765 command injection → writable sudo script |
| [[Blackgate]] | Linux | ✅ Complete | (see file) |
| [[HUB]] | Linux | ✅ Complete | Barracuda/FuguHub LSP injection → root rev shell |
| [[Workaholic]] | Linux | 🟡 In Progress | WordPress user enum done, no foothold yet |
| [[Law]] | Linux | 🟡 In Progress | Unstructured notes — needs cleanup |
| [[ImageMagick]] | Linux | 🟡 In Progress | Initial recon only — found upload form |
| [[PyLoader]] | Linux | 🟡 In Progress | Nmap only — pyLoad on 9666 |

## PG-Play

| Box | OS | Status | Foothold / Privesc |
|-----|----|--------|--------------------|
|     |    |        |                    |

## HackTheBox

| Box | OS | Status | Foothold / Privesc |
|-----|----|--------|--------------------|
| [[Suana\|Sauna]] | Windows (AD) | ✅ Complete | Username gen → ASREPRoast (fsmith) → winPEAS AutoLogon (svc_loanmgr) → NTDS dump → PTH as Administrator |

## TryHackMe

| Box | OS | Status | Foothold / Privesc |
|-----|----|--------|--------------------|
|     |    |        |                    |
