#! /bin/bash
 [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]] &&
 echo "Usage: $(basename $0) <hostname -without - domain> < ip-without-network>" && exit
! [[ $2 -ge 1 && $2 -le 254 ]] &> /dev/null && echo "Ipaddress out of range"  && exit
iface=ens33
domain=xv.com
net_dir=/etc/sysconfig/network-scripts
cd $net_dir
sed -r -i "/IP/s/[0-9]+$/$2/" $net_dir/ifcfg-$iface
systemctl restart network
hostname $1.$domain
echo $1.$domain > /etc/hostname
echo "set ts=4" >> /etc/vimrc
systemctl stop firewalld  > /dev/null
systemctl disable firewalld  > /dev/null
setenforce 0  > /dev/null
sed -i '/^SELINUX/c SELINUX=disable' /etc/selinux/config 
