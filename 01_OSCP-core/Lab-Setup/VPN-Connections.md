# 🔐 VPNs & Connecting to Target Boxes (OSCP Fundamentals)

## 🧠 What is the VPN in OSCP-style labs?

In OSCP (and most practice labs), the **VPN is your entry point** into the target network.

You are **not attacking the internet** — you are attacking a **private lab network** that only becomes reachable after you connect to the VPN.

No VPN = no access.

---

## 🌐 High-Level Concept

- You connect your machine (Kali) to a VPN
- The VPN gives you:
  - A **tunnel interface** (usually `tun0`)
  - An **internal IP address**
- Through that tunnel, you can now:
  - Scan targets
  - Access internal services
  - Reach machines that are otherwise unreachable

Think of it as:
> “I am virtually plugged into their network.”

---

## 🧰 What They Usually Give You

Most OSCP-style platforms give you:

- A **`.ovpn` file**
- Credentials (or embedded certs)
- A target IP or subnet

Example:
- VPN config: `oscp-lab.ovpn`
- Target IP: `10.10.10.5`

---

## 🔌 How to Connect to the VPN (Kali / Linux)

### Step 1: Navigate to the VPN file

```bash
cd ~/Downloads
```

(or wherever the `.ovpn` file is stored)

---

### Step 2: Connect using OpenVPN

```bash
sudo openvpn ~/Downloads/universal.ovpn
```

Notes:
- There should be nothing more to do from here as our kali box should connect us
- This terminal must stay open
- Closing it disconnects the VPN

---

### Step 3: Confirm connection

Look for a message similar to: