#!/bin/bash

# ETCD

cd /K8s-sh
source ./k8s.conf
bin_dir=`which etcd`
hosts=$(awk '/^node/{++i}END{print i}'  node_ip.txt)
for i in `seq $hosts`;do
    host_name=node$i
    host_IP=$(awk -F " |\t" '/^'$host_name'/{print $2}' node_ip.txt) &> /dev/null
	scp "$bin_dir"* "$host_IP":/usr/local/bin/
	scp -r $ETCD_DIR "$host_IP":/etc/
	scp /usr/lib/systemd/system/etcd.service "$host_IP":/usr/lib/systemd/system/
done

#Flannel
