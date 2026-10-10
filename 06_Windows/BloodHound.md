Start the server 
```bash 
sudo neo4j start
#or to stop
sudo neo4j stop
```
Launch the GUI:
```bash
bloodhound-legacy      
```

---

## 2. Collect the data

### From Kali (remote — you have domain creds, no foothold needed)
```bash
bloodhound-python -u <user> -p '<pass>' -d <domain.local> -dc <DC_FQDN> -ns <DC_IP> -c all --zip
```
→ `-c all` runs every collection method · `--zip` bundles the JSON. Just needs valid domain creds + reachability to the DC. Preferred when pivoting.

### On a Windows target (SharpHound)
```bash
SharpHound.exe -c all

# /home/nepps1/tools/bloodhound-legacy/BloodHound-linux-x64/resources/app/Collectors/SharpHound.exe

```



```powershell
Import-Module .\SharpHound.ps1; Invoke-BloodHound -CollectionMethod All

#/home/nepps1/tools/bloodhound-legacy/BloodHound-linux-x64/resources/app/Collectors/SharpHound.ps1
```
→ Transfer SharpHound ([[File_Transfer]]), run it, exfil the resulting `.zip` back to Kali.

---

## 3. Import + explore

→ In the GUI: **drag the collected `.zip` onto the window** (or the **Upload Data** button, top-right) to import.

- **Mark your foothold as Owned** — right-click the user/computer you control → *Mark as Owned*.
- **Pre-built queries** (Analysis tab) — the fast wins:
  - **Shortest Paths to Domain Admins**
  - **Shortest Paths from Owned Principals**
  - **Find Principals with DCSync Rights**
  - **Kerberoastable users** / **AS-REP Roastable users**
- **Edges to hunt:** `GenericAll`, `WriteDACL`, `ForceChangePassword`, `AddMember`, `AdminTo`, `CanPSRemote` — each is an abusable step toward DA.

> Right-click any edge → **Help** → gives the exact abuse commands (impacket / PowerView / netexec) for that relationship.

---

## Related Notes

- [[Active_Directory_Attacks]]
- [[Impacket]] · [[NetExec]] · [[Mimikatz]]
- [[Windows_Priv_Esc]]
