#!/bin/bash

#这个文件将收集k8s需要的信息
source ./k8s.conf

#需要先定义好 node_ip.txt 文件
sh ssh-copy-ip.sh

sh tar.sh

#需要先将etcd二进制包拷贝到k8s.conf里定义好的目录里
sh ETCD.sh

#需要先将flanneld二进制包拷贝到k8s.conf里定义好的目录里

#需要到node节点上修改一些配置文件，后启动服务
sh scp_node.sh
