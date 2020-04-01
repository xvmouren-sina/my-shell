#!/bin/bash
cd /packet
if [ ! `which flanneld &> /dev/null` ];then
    pwd
    tar xf fla*
    mv flanneld mk-docker-opts.sh /usr/local/bin/
fi
[ ! -e /etc/flannel.conf ] && cat > /etc/flannel.conf << EOF && echo "flannel.conf 创建成功"
FLANNEL_OPTIONS="--etcd-endpoints="$endpoint" -etcd-cafile="$SSL_DIR"/ca.pem -etcd-certfile="$SSL_DIR"/server.pem -etcd-keyfile="$SSL_DIR"/server-key.pem"
EOF

flanneld_service=/usr/lib/systemd/system/flanneld.service
[ ! -e $flanneld_service ] && cat > $flanneld_service << EOF && echo "flanneld.service 创建成功"
[Unit]
Description=Flanneld overlay address etcd agent
After=network-online.target network.target
Before=docker.service

[Service]
Type=notify
EnvironmentFile=/etc/flannel.conf
ExecStart=/usr/local/bin/flanneld --ip-masq $FLANNEL_OPTIONS
ExecStartPost=/usr/local/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

docker_service=/usr/lib/systemd/system/docker.service
echo "EnvironmentFile=/run/flannel/subnet.env" >> $docker_service
sed -ir 's#(ExecStart=/usr/bin/dockerd)(.*)#\1 $DOCKER_NETWORK_OPTIONS \2#' !$
systemctl daemon-reload
sleep 1
systemctl start flanneld
systemctl enable flanneld
systemctl restart docker
systemctl enable docker

