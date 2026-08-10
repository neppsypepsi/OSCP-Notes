# FTP — Port 21

---

## When It Shows Up

Nmap shows `21/tcp open ftp`. Always check:
1. Does anonymous login work?
2. If not, do you have credentials from elsewhere to try?

---

## Anonymous Login

```bash
ftp <IP> #or
ftp <ip or hostname> -p <non port 21 port>
# Username: 
anonymous
# Password: (just press Enter — blank)
```

On success you'll see `230 Login successful`. Then:

```bash
ls
cd <dir>
get <file>
mget *        # download everything, but you can't just pull folders, must be file
bye
```

**If `ls` hangs:** the server is in passive mode but passive isn't working. Switch to active mode:

```bash
ftp> passive   # toggles passive off
ftp> ls
```

If it still hangs, try lftp:

```bash
lftp <IP>
lftp> login anonymous ""
lftp> ls
```

If both hang, FTP is a dead end — move on.

---

## Login With Credentials

```bash
ftp <IP>
# Username: <user>
# Password: <password>
```

Or inline:

```bash
ftp <user>@<IP>
```

---

## Downloading Files

```bash
get filename.txt              # download single file
mget *.txt                    # download all .txt files
binary                        # switch to binary mode before downloading executables/archives
```

Always switch to binary mode before downloading anything that isn't plain text — ASCII mode corrupts binary files.

---

## Uploading Files

```bash
put shell.php                 # upload single file
```

Uploading does nothing on its own — you still need a way to execute it. If the FTP root overlaps with the web root, an uploaded PHP file may be accessible via the web server.

---

## Nmap FTP Scripts

```bash
nmap -p 21 --script ftp-anon,ftp-bounce,ftp-syst <IP>
```

- `ftp-anon` — confirms whether anonymous login is allowed
- `ftp-syst` — server type and version
- `ftp-bounce` — checks for FTP bounce attack (rare)

---

## What to Look For

- Config files, credentials, backups
- Web application files if FTP root = web root
- Scripts that get executed by a scheduled task

---

## Related Notes

- [[SMB]]
- [[File_Transfer]]
- [[Web_Enum]]
