ip: 192.168.231.96
nmap:
```
PORT     STATE SERVICE                VERSION
22/tcp   open  ssh                    OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 51:56:a7:34:16:8e:3d:47:17:c8:96:d5:e6:94:46:46 (RSA)
|   256 fe:76:e3:4c:2b:f6:f5:21:a2:4d:9f:59:52:39:b9:16 (ECDSA)
|_  256 2c:dd:62:7d:d6:1c:f4:fd:a1:e4:c8:aa:11:ae:d6:1f (ED25519)
9090/tcp open  hadoop-datanode        Apache Hadoop
| hadoop-tasktracker-info: 
|_  Logs: jive-ibtn jive-btn-gradient
| hadoop-datanode-info: 
|_  Logs: jive-ibtn jive-btn-gradient
|_http-title: Site doesn't have a title (text/html).
9091/tcp open  ssl/hadoop-tasktracker Apache Hadoop
|_ssl-date: TLS randomness does not represent time
| ssl-cert: Subject: commonName=localhost
| Subject Alternative Name: DNS:localhost, DNS:*.localhost
| Not valid before: 2024-06-28T07:02:39
|_Not valid after:  2029-06-27T07:02:39
| hadoop-tasktracker-info: 
|_  Logs: jive-ibtn jive-btn-gradient
| hadoop-datanode-info: 
|_  Logs: jive-ibtn jive-btn-gradient
|_http-title: Site doesn't have a title (text/html).
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

node0oq37ry6r3sxcekoi963iwkih52.node0; csrf=pLVPMczyLubI6qI