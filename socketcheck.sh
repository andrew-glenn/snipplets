#!/bin/bash
# SocketCheck
# Andrew Glenn, <andrew at andrewglenn dawt net>
# 
# A quick way to cross reference listening sockets to their PID owner 
# This *WILL NOT* guard against an already compromised system where sockets aren't listed in netstat. 

for pid in $(netstat -nap | awk '$6 ~ /LISTEN/ {print $7}'); do 
    if [ $(cat /proc/${pid%/.*}/loginid) -eq 0 ]; then
        echo "PID $(pid) is LISTENING as root!"
    fi
done

