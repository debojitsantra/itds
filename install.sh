#!/bin/bash
echo "installing..."
pkg update -y
pkg upgrade -y
pkg install nmap -y
pkg install termux-tools
chmod +x itds.sh
echo "installed!!"
