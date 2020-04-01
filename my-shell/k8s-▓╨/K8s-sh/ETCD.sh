#!/bin/bash
cd /K8s-sh
source ./k8s.conf
#需要先将cfssl文件拷贝到k8s.conf里定义好的目录里
sh ETCD_CA.sh
my_ip=`hostname -I | awk '{print $1}'`
echo "执行 $0 文件中。。。"
hosts=$(awk '/^node/{++i}END{print i}'  node_ip.txt)
for i in `seq $hosts`;do
	host_name=node$i
    host_IP=$(awk -F " |\t" '/^'$host_name'/{print $2}' node_ip.txt) &> /dev/null
	etcd_IC=$etcd_IC"etcd-"$host_name"=https://$host_IP:2380",
done
export etcd_IC=$etcd_IC"master=https://$my_ip:2380"

[ -d $ETCD_DIR ] || mkdir $ETCD_DIR
cd $ETCD_DIR
[ ! -e "$ETCD_DIR"/etcd.conf ] && cat > "$ETCD_DIR"/etcd.conf << EOF && echo "etcd.conf 文件创建成功"
#[Member]
ETCD_NAME="master"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://$my_ip:2380"
ETCD_LISTEN_CLIENT_URLS="https://$my_ip:2379"

#[Clustering]                                                                                 
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://$my_ip:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://$my_ip:2379"
ETCD_INITIAL_CLUSTER="$etcd_IC"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

etcd_service=/usr/lib/systemd/system/etcd.service
[ ! -e $etcd_service ] && cp /K8s-sh/sys-service/etcd.service $etcd_service
