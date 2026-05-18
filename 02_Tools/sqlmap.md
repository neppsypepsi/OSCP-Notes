# sqlmap — SQL Injection (OSCP)

## What is SQL Injection?

Web apps talk to databases using SQL queries. When user input (a search term, a URL parameter, a login field) gets dropped directly into a query without being sanitized, you can break out of the expected query and run your own SQL.

**Simple example:**
The app runs:
```sql
SELECT * FROM users WHERE username = '[YOUR INPUT]'
```
If you input `' OR 1=1 --`, it becomes:
```sql
SELECT * FROM users WHERE username = '' OR 1=1 --'
```
`1=1` is always true, so it returns every user. The `--` comments out the rest of the query.

That's the core idea — you're manipulating the SQL query the server runs.

---

## How to Spot a Vulnerable Parameter

SQL injection lives in **user-controlled input that gets sent to the database**. Look for:

- URL parameters: `?id=1`, `?search=test`, `?page=2`, `?q=admin`
- Form fields: login boxes, search bars, contact forms
- Hidden form values (check page source)

**Signs something might be injectable:**
- Putting a `'` in a parameter causes a server error or changes the response
- A CVE or wpscan scan tells you a specific parameter is vulnerable
- The response changes when you add SQL syntax (`AND 1=1` vs `AND 1=2`)

**The wpscan → sqlmap connection:**
wpscan can tell you a plugin has a SQLi CVE. The CVE documentation tells you which endpoint and parameter is injectable. You don't need to guess — the CVE does that work. Once you know the vulnerable parameter, you confirm it manually, then use sqlmap to extract data.

---

## Confirm It Manually First

Before running sqlmap, verify the injection works. Use curl or your browser to hit the vulnerable endpoint and see if the response changes or returns unexpected data.

What you're looking for: does manipulating the parameter change what the server returns? If yes, SQLi is likely confirmed.

---

## sqlmap — Automated Extraction

sqlmap does not find vulnerabilities. You bring it a URL with a known vulnerable parameter and it automates the data extraction.

### Basic workflow — enumerate databases first
```bash
sqlmap -u "http://<IP>/path?param=value" --dbs
```
→ Lists all databases on the server. Start here so you know what exists.

### Then list tables in the target database
```bash
sqlmap -u "http://<IP>/path?param=value" -D <database_name> --tables
```

### Then dump the table you want
```bash
sqlmap -u "http://<IP>/path?param=value" -D <database_name> -T <table_name> --dump
```

### Shortcut when you already know the table
```bash
sqlmap -u "http://<IP>/path?param=value" -T <table_name> --dump
```

### Check if the DB user has admin rights
```bash
sqlmap -u "http://<IP>/path?param=value" --is-dba
```
→ DBA = database administrator. If true, the DB account may be able to read files from the server or write files — useful for escalation beyond just dumping data.

### POST request (login forms, etc.)
```bash
sqlmap -u "http://<IP>/login" --data="username=admin&password=test"
```
→ Use when the vulnerable input is submitted via a form rather than a URL parameter.

---

## Key Flags

| Flag | What it does |
|---|---|
| `-u` | Target URL — must include the vulnerable parameter |
| `--dbs` | List all databases |
| `-D <name>` | Select a specific database |
| `--tables` | List tables in the selected database |
| `-T <name>` | Select a specific table |
| `--dump` | Extract all rows from the table |
| `--is-dba` | Check if DB user has admin privileges |
| `--data` | POST body data (for form-based injection) |

---

## What to Do With the Output

Dumped tables often contain password hashes. The hash format tells you which hashcat mode to use:

| Hash prefix | Format | Hashcat mode |
|---|---|---|
| `$P$` | phpass (WordPress) | 400 |
| No prefix, 32 chars | NTLM | 1000 |
| `$2y$` / `$2b$` | bcrypt | 3200 |

Once cracked, try the cleartext password on every service you found in nmap — credential reuse is extremely common.

> phpass (`$P$`) cannot be passed directly to services. You must crack it first. It is not NTLM.

---

## Related Notes

- [[Web_Enum]]
- [[wpscan]]
- [[Hashcat]]
