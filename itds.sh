#!/bin/bash     
" 
#Example: ./itds.sh -nt -i google.com -p 80


while getopts ':nti:p:v' opt
do
case "$opt" in
   'i')ip="${OPTARG}"
       ;;
   'p')port="${OPTARG}"
       ;;
   'n')nmap_yes=1;
       ;; 
   't')ping_yes=1;
       ;;
   'v')echo "itds version 1.0"
       ;;
    *) echo "Invalid option $opt"
       echo "Usage : "
       echo "pingmap -[n|t[i|p]|v]"
       echo "                     "
       echo "
             -n : nmap
             -t : ping
             -i : ip
             -p : port
             -v : version
              Ex: ./itds.sh -nt -i google.com -p 80 "
       ;;
esac
done
if  [ ! -z "$nmap_yes" ] && [ "$nmap_yes" -eq "1" ]
then
   if [ ! -z "$ip" ] && [ ! -z "$port" ]
   then
     nmap -p "$port" "$ip"
   fi
fi

if  [ ! -z "$ping_yes" ] && [ "$ping_yes" -eq "1" ]
then
   if [ ! -z "$ip" ]
   then
     ping -c 5 "$ip"
   fi
fi
shift $(( OPTIND - 1 ))
if [ ! -z "$@" ]
then
  echo "At the end : $@"
fi
