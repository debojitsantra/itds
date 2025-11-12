

# ITDS

**Easy Port Scanning & Ping Toolkit**

A compact, no-nonsense network utility built for **Termux** and Linux.  
Run quick ping checks, perform targeted `nmap` scans, trace routes, or run a full network diagnostic — all from one script.

---

##  Requirements

- Termux or a Linux terminal  
- Active internet connection  
- Installed packages:  
  `nmap`, `curl`, `traceroute` *(automatically handled by the installer)*

---

##  Installation

Run the following commands in **Termux**:

```bash
pkg update && pkg upgrade -y
pkg install git -y
git clone https://github.com/debojitsantra/itds
cd itds
chmod +x install.sh && ./install.sh
```
If the installer fails, install dependencies manually:
```bash
pkg install nmap curl traceroute -y
chmod +x itds.sh
```
You can optionally move the script to your PATH:
```bash
mv itds.sh ~/bin/
```


## Quick Usage

Example:
```bash
./itds.sh -n -t -i google.com -p 80
```
Flags:

- -n	Run nmap scan
- -t	Ping the target
- -i	Specify IP or domain
- -p	Port(s) for nmap (e.g. 22, 22,80,443, or 1-1024)
- -v	Show version info
- -h	Show help



## Advanced Usage

If you’re using the extended ITDS version:

Multiple nmap scan modes: connect, syn, udp, service

Port presets: common, web, ssh, top100

Traceroute support

HTTP(S) header check via curl

Timestamped logs saved to itds_output/

Interactive menu mode (-I)



Ping a host:
```bash
./itds.sh -t -i 8.8.8.8 -c 4
```
Scan common ports:
```bash
./itds.sh -n -i example.com -P common
```
Save output to a file:
```bash
./itds.sh -n -t -i example.com -p 22,80 -o result.txt
```
Interactive menu:
```bash
./itds.sh -I
```



## Troubleshooting

Missing commands: Install them manually with
pkg install nmap curl traceroute -y

Permission errors: SYN scans may need root.
Use connect scan (-N connect) if you’re not root.

Output missing: Ensure the script has permission to write to the output directory.



---

## Contributing

Bug reports, feature ideas, or PRs are welcome!
Visit the repo:
github.com/debojitsantra/itds


---

## License
MIT
