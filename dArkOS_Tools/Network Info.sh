#!/bin/bash

# basic network information for dArkOS
# by daedalus-code

################################################################################

# get primary network interface from default route
NET_IFACE=$(ip route show default 0.0.0.0/0 | awk '{print $5}' | head -n1)
# get IPv4 address for that interface
IP_ADDRESS=$(ip -4 addr show dev "$NET_IFACE" | awk '/inet / {print $2}' | cut -d/ -f1)
# get default gateway
GATEWAY=$(ip route show default 0.0.0.0/0 | awk '{print $3}' | head -n1)
# get domain (DNS search domain, first entry)
DOMAIN=$(awk '/^search/ {print $2; exit}' /etc/resolv.conf)
# get RX and TX bytes
RX_BYTES=$(</sys/class/net/"$NET_IFACE"/statistics/rx_bytes)
TX_BYTES=$(</sys/class/net/"$NET_IFACE"/statistics/tx_bytes)
# convert to MB
RX_MB=$(awk -v b="$RX_BYTES" 'BEGIN {printf "%.2f", b/1024/1024}')
TX_MB=$(awk -v b="$TX_BYTES" 'BEGIN {printf "%.2f", b/1024/1024}')

msgbox "Network.: $NET_IFACE
Address.: $IP_ADDRESS
Gateway.: $GATEWAY
Domain..: ${DOMAIN:-N/A}

Down....: ${RX_MB}MB
Up......: ${TX_MB}MB"

# END
