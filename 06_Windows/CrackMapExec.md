# CrackMapExec — Deprecated

CrackMapExec is **no longer maintained**.

On modern Kali, use **NetExec (`nxc`)** instead — same syntax, same workflow, actively developed.

> See [[NetExec]] for the current version of this workflow.

---

## If You Only Have CrackMapExec

If you land on an older box or VM that only has `crackmapexec` installed, the syntax is identical — just swap `nxc` for `crackmapexec` in any command from [[NetExec]].

```bash
crackmapexec smb <IP> -u user -p pass
crackmapexec smb <IP> -u user -H <NTLM_HASH>
crackmapexec smb <IP> -u users.txt -p 'Password1'
```

Everything else lives in [[NetExec]].
