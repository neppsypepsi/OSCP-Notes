# git-dumper

Rebuilds a full git repo from an exposed `.git/` on a web server → recover source + commit history (deleted creds, configs, hints often live in old commits).

Use when enum finds `http://<IP>/.git/` (e.g. nmap `http-git`, or a 403/directory hit on `.git`). Works even when **directory listing is disabled** — it fetches known git internals directly instead of browsing.

---

## Install
```bash
pipx install git-dumper        # pip is blocked system-wide on Kali — use pipx (or a venv)
```

---

## Dump
```bash
git-dumper http://<IP>/.git/ loot_dir
```
`loot_dir` = name of file you want to save it to.

---

## Mine the history (the actual point)
```bash
cd loot_dir
git log --oneline --all          # every commit, all branches
git show <commit>                # full diff of one commit
git log -p                       # all commits with diffs — scroll for creds/keys
git stash list                   # sometimes secrets hide in a stash
grep -rniE 'pass|secret|key|token|api' .
```
> A file "deleted" in the latest commit is still in history → `git log -p` reveals it. Check `config.php`, `.env`, `settings`, DB connection strings.

---

## Related Notes
- [[GitHub_Repos]]
- [[Web_Enum]]
- [[Grep]]
