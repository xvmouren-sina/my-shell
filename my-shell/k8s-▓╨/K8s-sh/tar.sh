#!/bin/bash

source ./k8s.conf
cd $BIN_DIR
pwd 
#ca
mv cfssl* /usr/local/bin/ &> /dev/null
chmod +x /usr/local/bin/cfssl*

#etcd
if [ ! `which etcd &> /dev/null` ];then
	pwd
	tar xf etcd*
	cp -p etcd-v*/etc* /usr/local/bin/
fi

#flannel
if [ ! `which flanneld &> /dev/null` ];then
	pwd
	tar xf fla* 
	mv flanneld mk-docker-opts.sh /usr/local/bin/
fi

