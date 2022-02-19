#!/bin/bash
echo "    ...............Installing Requirments.........................."
pkg update -y
pkg upgrade -y
echo "    ...............Installing Nmap..................................."
pkg install nmap -y
echo "    ...............Installed........................................"
echo "    .................Updating Termux Packages......................."
pkg install termux-tools
echo "     .................'IP Tools by darke'installed on your system....."
chmod +x itds.sh
clear
echo "ITDS IS READY"
echo "              
"
echo "USE: ./itds.sh <options> <website address>"
