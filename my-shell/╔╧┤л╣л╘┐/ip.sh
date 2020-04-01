#!/bin/bash

network_dir=/etc/sysconfig/network-scripts/
network_name=ens33
gateway=192.168.10.2
my_ip=`hostname -I`

cd $network_dir

cat > ifcfg-$network_name << EOF
TYPE="Ethernet"
BOOTPROTO="static"
IPADDR=$my_ip
NETMASK=255.255.255.0
GATEWAY=$gateway
DNS1=114.114.114.114
DEVICE=$network_name
ONBOOT="yes"
EOF

