## BloodHound (Legacy v4.x) — AD Attack-Path Mapping

→ Ingests Active Directory data and draws it as a **graph**: nodes = users / groups / computers, edges = rights/relationships (`MemberOf`, `AdminTo`, `GenericAll`, `CanRDP`, etc.). It finds the **shortest path to Domain Admin** for you. **AD only** — maps *domain* privileges, NOT local privesc like SeImpersonate ([[Potato_Attacks]]). Use it on the AD set / domain-joined boxes, not standalone machines.

**Two halves:** a **collector** (bloodhound-python / SharpHound) grabs the data → produces a `.zip` → you **import** it into the BloodHound GUI to explore.

> **This note = the LEGACY Electron app (v4.3.1) + neo4j** — the black-graph UI. Kali's `apt bloodhound` now installs **BloodHound CE** (a web app on :8080) instead, which has a different UI. Legacy is staged manually (below). Don't confuse the two.

---

## 0. One-time setup (Kali) — get the legacy app + neo4j

Legacy is **not in Kali repos anymore** (apt gives CE). Staged binary:
```
/home/nepps1/tools/bloodhound-legacy/BloodHound-linux-x64/BloodHound
```
> Source: official SpecterOps release `github.com/SpecterOps/BloodHound-Legacy` → `BloodHound-linux-x64.zip`, unzipped there.

neo4j comes from the `bloodhound`/`neo4j` apt package (already installed).

---

## 1. Start the backend (every session)

```bash
sudo systemctl stop bloodhound      # CE fights over neo4j — stop it first (once: systemctl disable bloodhound)
sudo neo4j start                    # backend DB — listens on :7474 (web) + :7687 (bolt)
```
**First time only** — set a neo4j password: open `http://localhost:7474` → log in `neo4j` / `neo4j` → it forces a change → set e.g. `bloodhound`. (After that, neo4j remembers it.)

Launch the GUI:
```bash
bloodhound-legacy      # symlink -> /home/nepps1/tools/bloodhound-legacy/BloodHound-linux-x64/BloodHound
```
> Shortcut set up once: `ln -sf /home/nepps1/tools/bloodhound-legacy/BloodHound-linux-x64/BloodHound ~/.local/bin/bloodhound-legacy` (`~/.local/bin` is on PATH). On a fresh machine, re-create it or run the full path.
Login screen: **URL** `bolt://localhost:7687` · **User** `neo4j` · **Pass** `<what you set>`.
> App window flashes and dies? Electron sandbox — relaunch with `--no-sandbox` appended.

**Gotchas:**
- **Only ONE of CE / legacy at a time** — both want neo4j and will clash. Always `systemctl stop bloodhound` before legacy.
- **`localhost` won't resolve / neo4j "no such host"?** → `/etc/hosts` is missing the loopback line (OSCP VPN can clobber it). Fix: `sudo sed -i '1i 127.0.0.1\tlocalhost' /etc/hosts`, verify `getent hosts localhost`.

---

## 2. Collect the data

### From Kali (remote — you have domain creds, no foothold needed)
```bash
bloodhound-python -u <user> -p '<pass>' -d <domain.local> -dc <DC_FQDN> -ns <DC_IP> -c all --zip
```
→ `-c all` runs every collection method · `--zip` bundles the JSON. Just needs valid domain creds + reachability to the DC. Preferred when pivoting.

### On a Windows target (SharpHound)
```cmd
SharpHound.exe -c all
```
```powershell
Import-Module .\SharpHound.ps1; Invoke-BloodHound -CollectionMethod All
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
