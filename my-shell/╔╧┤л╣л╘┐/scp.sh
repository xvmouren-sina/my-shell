#!/bin/bash
host_tab=/data/host.txt
hosts=$(cat $host_tab | wc -l)
SEND_KEY() {
for ((i=1;i<=$hosts;i++));do
    host_IP=$(awk 'NR=='$i'{print $1}' $host_tab) &> /dev/null
    ping -W3 -c2 $host_IP &> /dev/null || continue
    scp /root/ip.sh ${host_IP}:/root/
    ssh $host_IP "sh /root/ip.sh"
done
}
SEND_KEY &> /dev/null &
wait
