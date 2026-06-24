# Curl & HTTP Requests (OSCP)

Understanding curl means understanding HTTP. Curl doesn't "use" a website — it sends raw HTTP requests and shows you the raw response. Everything a browser does, curl can replicate by hand.

---

## OSCP Essentials — Most-Used

The handful of curl moves you actually reach for on the exam. Fuller explanations are in the sections further down.

### Path Traversal / LFI file read
```bash
curl -s --path-as-is "http://<IP>/../../../../etc/passwd"
```
→ `--path-as-is` stops curl from collapsing `../` *before* sending — **required** for traversal, or the attack never reaches the server. High-value read targets:

| Target | What you get |
|---|---|
| `/etc/passwd` | user enumeration (who has `/bin/bash`) |
| `/proc/self/cmdline` | the web process's launch args — often creds (`-u user -p pass`). Pipe through `tr '\0' ' '` to read it |
| `/proc/self/environ` | env-var secrets (DB creds, API keys) — try when `cmdline` has nothing |
| `/etc/shadow` | password hashes (needs root-level read) |
| `/home/<user>/.ssh/id_rsa` | reusable private keys |

See [[LFI_RFI]].

### Carve many files through one LFI (loop)
```bash
for i in $(cat tmp); do
  curl -s -q --path-as-is "http://<IP>/path/../../etc/freeswitch/autoload_configs/$i" >> carve
done
grep -i password carve
```
→ `tmp` holds a list of candidate filenames (build it with `grep -Ril` — see [[Grep]]). The loop fetches each one through the traversal and **appends** (`>>`, not `>` which would overwrite) every response into a single file `carve`; then one grep finds the secret across all of them. **Why bother:** when a *live* config differs from a backup you already grabbed (the backup had only a default password), this re-pulls the real files.

### Upload a shell past browser-side validation
```bash
curl -b "session=abc123" -F "file=@shell.php" http://<IP>/admin/upload
```
→ "Images only" checks usually run in JavaScript in the browser; curl sends straight to the server, which may not validate at all.

### Download a file behind auth
```bash
curl -b "session=abc123" http://<IP>/admin/backup.zip -o backup.zip
```
→ Without the cookie you save the login page (302). Backups often hold source, config creds, old passwords.

### Fingerprint / debug
```bash
curl -i http://<IP>/        # response headers (Server, X-Powered-By, Set-Cookie)
curl -L http://<IP>/        # follow redirects
curl -v http://<IP>/admin   # see the raw request (>) and response (<)
```

---

## How HTTP Requests Work

Every interaction between a browser and a server is an HTTP request. There are four you'll use constantly:

| Method | What it means | Common use |
|---|---|---|
| GET | Fetch data | Loading a page, URL parameters |
| POST | Send data to the server | Form submissions, logins |
| PUT | Replace data | Less common, some APIs |
| DELETE | Remove data | Less common, some APIs |

When you type a URL into a browser and hit Enter, that's a GET request.
When you fill out a form and click Submit, that's usually a POST request.

**GET parameters live in the URL:**
```
http://site.com/search?q=admin&page=1
```
Everything after `?` is a parameter. `q=admin` means the parameter named `q` has the value `admin`. These are what you test for SQL injection, command injection, etc.

**POST parameters live in the request body — invisible in the URL.**
You see them when you look at the raw request in Burp or browser DevTools.

---

## How Forms Map to Requests

Every input field in an HTML form has a `name` attribute. That name becomes the parameter key the server receives.

```html
<form method="POST" action="/login">
  <input type="text" name="username" />
  <input type="password" name="password" />
  <button type="submit">Login</button>
</form>
```

When you click Submit, the browser packages this as:
```
username=admin&password=test
```
and sends it to `/login` via POST. The server never sees the HTML — it only sees those key-value pairs.

**The button doesn't do anything special.** It just tells the browser to collect the form values and send the request. Curl skips the button entirely and sends the request directly.

**How to find the field names:**
- Right-click the page → View Page Source → look for `<input name="...">`
- Or use Burp Suite — intercept the real browser request and you see the exact parameter names and values that were sent

---

## Curl Commands

### GET Request (default)
```bash
curl http://<IP>/page
```
→ Fetches the page. Same as typing the URL in a browser.

### GET with URL Parameters
```bash
curl "http://<IP>/search?q=test&page=1"
```
→ Quote the URL when it contains `&` so the shell doesn't interpret it.

### POST Request (form submission)
```bash
curl -X POST http://<IP>/login -d "username=admin&password=test"
```
→ `-d` sends the data as a POST body. Same format the browser uses.

### POST with JSON (APIs)
```bash
curl -X POST http://<IP>/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"test"}'
```
→ `-H` adds a header. APIs often expect JSON instead of form data.

### Include Response Headers
```bash
curl -i http://<IP>/page
```
→ Shows status code, server type, cookies, redirects — useful for fingerprinting.

### Follow Redirects
```bash
curl -L http://<IP>/page
```
→ Automatically follows 301/302 redirects. Without this, curl stops at the redirect.

### Save Response to File
```bash
curl http://<IP>/file.zip -o file.zip
```

### Send Cookies
```bash
curl http://<IP>/dashboard -b "session=abc123"
```
→ Used when a page requires authentication — grab the session cookie from Burp or browser DevTools after logging in.

### Set a Custom Header
```bash
curl http://<IP>/page -H "X-Forwarded-For: 127.0.0.1"
```
→ Useful for bypassing IP-based restrictions or testing header injection.

---

## Key Flags Reference

| Flag | Meaning |
|---|---|
| `-X` | HTTP method (GET, POST, PUT, DELETE) |
| `-d` | POST body data (`key=value&key2=value2`) |
| `-H` | Add a header |
| `-i` | Show response headers |
| `-L` | Follow redirects |
| `-o` | Save output to file |
| `-b` | Send cookies |
| `-s` | Silent mode (no progress bar) |
| `-v` | Verbose — shows full request and response (good for debugging) |

---

## Example Outputs and What They Tell You

### curl -i http://192.168.1.10/
```
HTTP/1.1 200 OK
Server: Apache/2.4.41 (Ubuntu)
X-Powered-By: PHP/7.4.3
Set-Cookie: PHPSESSID=abc123def456; path=/
Content-Type: text/html; charset=UTF-8
```
`Server` and `X-Powered-By` give you the software stack without nmap. `X-Powered-By` leaking a PHP version is a direct CVE lookup. `Set-Cookie` tells you the app is session-based — that cookie value is what you use with `-b` to stay authenticated.

---

### curl -X POST http://192.168.1.10/login -d "username=admin&password=test"

Wrong password:
```html
<div class="error">Invalid username or password.</div>
```
Valid username, wrong password:
```html
<div class="error">Incorrect password.</div>
```
The difference in error messages is **user enumeration** — the app is telling you which usernames exist even without a successful login.

Success:
```
HTTP/1.1 302 Found
Location: /dashboard
Set-Cookie: session=eyJhbGci...
```
302 redirect = login worked. Grab the session cookie from `Set-Cookie` and use it with `-b` for subsequent requests.

---

### curl -v http://192.168.1.10/admin
```
> GET /admin HTTP/1.1
> Host: 192.168.1.10
>
< HTTP/1.1 403 Forbidden
< WWW-Authenticate: Basic realm="Admin Area"
```
`>` lines = what curl sent. `<` lines = what the server returned. `WWW-Authenticate: Basic` means this panel uses HTTP Basic Auth — try default creds directly in the URL:
```bash
curl http://admin:password@192.168.1.10/admin
```

---

### curl "http://192.168.1.10/search?q='"
Normal response:
```html
<h2>Results for: test</h2>
<p>3 results found</p>
```
After injecting a single quote:
```html
<b>Fatal error</b>: You have an error in your SQL syntax near ''' at line 1
```
SQL error on a broken quote = unsanitized parameter. Point sqlmap at it.

---

### curl -b "session=abc123" http://192.168.1.10/dashboard

Without cookie:
```
HTTP/1.1 302 Found
Location: /login
```
With valid cookie:
```html
<h1>Welcome back, admin</h1>
```
The redirect without the cookie confirms the page requires auth. With the cookie, you're in as that user.

---

## When Authenticated Curl Actually Matters

Logging into a site via curl alone is not useful — you can't browse, you can't see what's on the next page. The value is in two specific situations:

**1. Confirming credentials before using them elsewhere**

Curl is a fast way to verify a cracked or found password works against the web app. The real move is then taking that confirmed credential to SSH, FTP, or netexec. Curl is the check, not the goal.

**2. Hitting a specific endpoint you already know about**

This is where curl earns its place. Once you know the URL of something worth targeting, curl lets you interact with it precisely — and bypass browser-side restrictions.

**File upload behind JavaScript validation:**
You try to upload a PHP shell through the browser and it's instantly rejected — "only images allowed." That check ran in JavaScript, in your browser, before anything reached the server. The server itself may have no validation at all.

Curl skips the browser and sends directly to the server:
```bash
curl -b "session=abc123" -F "file=@shell.php" http://site.com/admin/upload
```
`-F` sends a file. `file=` is the form field name from the page source. `@shell.php` means send the contents of that local file. If the server isn't validating, the shell lands.

**Downloading files behind auth:**
```bash
curl -b "session=abc123" http://site.com/admin/backup.zip -o backup.zip
```
Without the cookie, the server returns a 302 redirect to the login page — you'd save an HTML login page instead of the file. With the cookie, the server serves the real file.

Why backup files matter: they often contain full source code, config files with database credentials, or old password files. Same idea as reading `wp-config.php` through FTP — just a different path to the same result.

The workflow for both:
1. Find the endpoint through gobuster, page source, or a CVE
2. Find the form field names from page source or Burp
3. Curl sends exactly what you want, bypassing what the browser would block

Without knowing the endpoint first, curl is useless. It is a precision tool, not an exploration tool.

---

## How This Connects to sqlmap

When sqlmap uses `--data="username=admin&password=test"`, it's using the exact same format curl uses for POST bodies. The parameter names come from the same place — the HTML form's `name` attributes, or from a captured request in Burp.

For GET-based injection (parameters in the URL), sqlmap takes the full URL:
```bash
sqlmap -u "http://<IP>/search?q=test"
```
sqlmap will test the `q` parameter for injection because it's in the URL. It knows to test it because you included it — if there were multiple parameters, you can tell sqlmap which one to focus on with `-p`:
```bash
sqlmap -u "http://<IP>/search?q=test&page=1" -p q
```

---

## What Curl Cannot Do

- **Execute JavaScript** — curl gets raw HTML. If the page builds its content or sends requests via JavaScript, curl won't trigger any of that. Tools like Selenium or a real browser are needed.
- **Click dynamically rendered buttons** — same reason. If a button's action is JavaScript-driven rather than a plain HTML form, curl can't replicate it without knowing exactly what HTTP request the JS would make.
- **Handle CAPTCHAs** — requires human interaction or specialized tools.

In practice on OSCP boxes: most targets use plain HTML forms. JavaScript-heavy apps are less common. When you do hit one, use Burp to intercept what the browser actually sends, then replicate that with curl.

---

## The Workflow in Practice

1. Open the page in a browser and find the form or parameter you want to interact with
2. View source or use Burp to capture the exact field names
3. Replicate the request with curl using the correct method and parameter names
4. If testing for injection — modify one parameter at a time and watch how the response changes

---

## Related Notes

- [[Web_Enum]]
- [[sqlmap]]
- [[wpscan]]
- [[htaccess_Bypass]]
