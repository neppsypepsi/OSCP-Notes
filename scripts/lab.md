---
description: OSCP lab session startup — run the tool checklist, load vault context, log this machine
allowed-tools: Bash, Read, Edit
---

You are starting an OSCP lab session on this Kali machine. Do all of the following, in order, then stop and wait for me:

0. **Sync the vault FIRST** — run `cd /home/nepps1/OSCP-Notes && git pull --rebase` before anything else. The vault syncs across machines, so pulling up front guarantees the toolcheck script, guides, and machine-check log are current AND prevents end-of-session push rejections (`fetch first`). If the pull reports conflicts or fails, tell me and stop — don't proceed on a stale/broken vault.

1. **Run the tool checklist** — execute `bash /home/nepps1/OSCP-Notes/scripts/oscp-toolcheck.sh` with the Bash tool and read its full output. This reports machine identity (hostname, Kali version, user, date) and the present/missing status of every required tool and wordlist. It is report-only and needs no sudo. (The script lives in the synced vault so every machine has it after `git pull`.)

2. **Read the vault guides:**
   - `/home/nepps1/OSCP-Notes/CLAUDE.md` — my session rules, tool checklist reference, and the per-machine "Machines checked" log.
   - `/home/nepps1/OSCP-Notes/Session-Guide-Boxes.md` — the strict guide/don't-lead rules for lab boxes. Follow these for the rest of the session.

3. **Touch the machine-check log ONLY IF SOMETHING CHANGED.** Look at the "Machines checked:" list under the Essential Tools Checklist in `CLAUDE.md` and compare this machine (by hostname) to what's logged:
   - If this hostname is **already logged and the tool findings still match** what's recorded → **do nothing to the file.** Do not bump the date, do not rewrite the entry. Keep this a read-only session so there's nothing to commit or push.
   - Only edit `CLAUDE.md` when this hostname has **no entry yet**, or its **findings actually differ** from the log (a tool appeared/disappeared, a staged path changed). In that case: update the entry in place (or add a new dated one at the top if new), note any staged/non-apt binaries and their paths, and enforce the cap of **at most 4 dated entries** (delete the oldest if a 5th would be added).

4. **Report a concise readiness summary:** machine identity, ✓ all-clear or the list of gaps with the exact fix command (from the script). If tools are missing, remind me they need sudo so I must run the `apt install` myself via `! sudo apt ...`. If pspy specifically is the gap, offer to stage the static binary (no sudo) instead.

5. **Only if you actually edited `CLAUDE.md` in step 3**, remind me to commit + push. If you changed nothing, say nothing about git.

Keep it tight — no fluff, no busywork. In the common case (machine already logged, nothing changed) this is a read-only check: checklist + load the guides + summary, and that's it. After the summary, ask what box or topic I'm working on and then follow the Session-Guide-Boxes rules strictly (do not search for exploits or suggest attack chains unprompted).
