#!/usr/bin/env bash
# OSCP lab tool checklist — report-only, no sudo, safe to run anytime.
# Called by the /lab slash command. Prints machine identity + tool/wordlist status.

C_OK=$'\e[32m'; C_BAD=$'\e[31m'; C_DIM=$'\e[2m'; C_HDR=$'\e[1;36m'; C_RST=$'\e[0m'
present=(); missing=()

hdr() { printf '\n%s== %s ==%s\n' "$C_HDR" "$1" "$C_RST"; }

# check <label> <command-on-PATH>
check() {
  local label="$1" cmd="$2" path
  path="$(command -v "$cmd" 2>/dev/null)"
  if [ -n "$path" ]; then
    printf '  %s✓%s %-22s %s%s%s\n' "$C_OK" "$C_RST" "$label" "$C_DIM" "$path" "$C_RST"
    present+=("$label")
  else
    printf '  %s✗%s %-22s %sMISSING%s\n' "$C_BAD" "$C_RST" "$label" "$C_BAD" "$C_RST"
    missing+=("$label")
  fi
}

hdr "MACHINE"
printf '  host    : %s\n' "$(hostname)"
printf '  kali    : %s\n' "$(. /etc/os-release 2>/dev/null; echo "${VERSION:-unknown}")"
printf '  user    : %s\n' "$(whoami)"
printf '  date    : %s\n' "$(date +%Y-%m-%d)"

hdr "CORE RECON"
for t in nmap gobuster feroxbuster ffuf enum4linux smbclient nikto; do check "$t" "$t"; done

hdr "EXPLOITATION"
for t in msfvenom searchsploit sqlmap hydra burpsuite; do check "$t" "$t"; done
if python3 -m venv --help >/dev/null 2>&1; then
  printf '  %s✓%s %-22s %sok%s\n' "$C_OK" "$C_RST" "python3-venv" "$C_DIM" "$C_RST"; present+=("python3-venv")
else
  printf '  %s✗%s %-22s %sMISSING%s\n' "$C_BAD" "$C_RST" "python3-venv" "$C_BAD" "$C_RST"; missing+=("python3-venv")
fi

hdr "POST-EXPLOIT / PRIVESC"
for t in linpeas winpeas evil-winrm impacket-psexec impacket-secretsdump john hashcat; do check "$t" "$t"; done
# pspy: on PATH OR staged static binary
if command -v pspy >/dev/null 2>&1; then
  check "pspy" "pspy"
elif [ -x /home/nepps1/tools/pspy/pspy64 ]; then
  printf '  %s✓%s %-22s %sstaged: /home/nepps1/tools/pspy/pspy64%s\n' "$C_OK" "$C_RST" "pspy" "$C_DIM" "$C_RST"; present+=("pspy")
else
  printf '  %s✗%s %-22s %sMISSING%s\n' "$C_BAD" "$C_RST" "pspy" "$C_BAD" "$C_RST"; missing+=("pspy")
fi

hdr "CRED / NETWORK"
for t in netexec bloodhound-python; do check "$t" "$t"; done

hdr "TUNNELING / PIVOTING"
# ligolo-ng package provides ligolo-proxy (+ ligolo-agent); accept staged copy too
if command -v ligolo-proxy >/dev/null 2>&1; then
  check "ligolo-proxy" "ligolo-proxy"
elif [ -x /home/nepps1/tools/ligolo/proxy ]; then
  printf '  %s✓%s %-22s %sstaged: /home/nepps1/tools/ligolo/proxy%s\n' "$C_OK" "$C_RST" "ligolo-proxy" "$C_DIM" "$C_RST"; present+=("ligolo-proxy")
else
  printf '  %s✗%s %-22s %sMISSING%s\n' "$C_BAD" "$C_RST" "ligolo-proxy" "$C_BAD" "$C_RST"; missing+=("ligolo-proxy")
fi

hdr "WORDLISTS"
if [ -d /usr/share/seclists ]; then
  printf '  %s✓%s %-22s %s/usr/share/seclists%s\n' "$C_OK" "$C_RST" "seclists" "$C_DIM" "$C_RST"; present+=("seclists")
else
  printf '  %s✗%s %-22s %sMISSING%s\n' "$C_BAD" "$C_RST" "seclists" "$C_BAD" "$C_RST"; missing+=("seclists")
fi
if [ -f /usr/share/wordlists/rockyou.txt ]; then
  printf '  %s✓%s %-22s %splaintext ready%s\n' "$C_OK" "$C_RST" "rockyou.txt" "$C_DIM" "$C_RST"; present+=("rockyou.txt")
elif [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
  printf '  %s✗%s %-22s %sGZIPPED — run: gunzip /usr/share/wordlists/rockyou.txt.gz%s\n' "$C_BAD" "$C_RST" "rockyou.txt" "$C_BAD" "$C_RST"; missing+=("rockyou.txt(gz)")
else
  printf '  %s✗%s %-22s %sMISSING%s\n' "$C_BAD" "$C_RST" "rockyou.txt" "$C_BAD" "$C_RST"; missing+=("rockyou.txt")
fi

hdr "SUMMARY"
printf '  present: %d   missing: %d\n' "${#present[@]}" "${#missing[@]}"
if [ "${#missing[@]}" -eq 0 ]; then
  printf '  %sAll clear — ready to lab.%s\n' "$C_OK" "$C_RST"
else
  printf '  %sGaps: %s%s\n' "$C_BAD" "${missing[*]}" "$C_RST"
  printf '  %sapt-installable fix (needs sudo):%s\n' "$C_DIM" "$C_RST"
  printf '    sudo apt install %s -y\n' "$(printf '%s ' "${missing[@]}" | sed 's/pspy//g; s/rockyou[^ ]*//g' | xargs)"
  printf '  %s(pspy often 403s from kali.download — stage static binary to /home/nepps1/tools/pspy/pspy64 instead)%s\n' "$C_DIM" "$C_RST"
fi
exit 0
