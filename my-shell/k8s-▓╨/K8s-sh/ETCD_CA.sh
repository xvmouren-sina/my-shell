#!/bin/bash
#需要先将cfssl文件赋予可执行权限,并设置为系统命令
source ./k8s.conf
my_ip=`hostname -I|awk '{print $1}'`
echo "执行 $0 中。。。"
hosts=$(awk '/^node/{++i}END{print i}'  node_ip.txt)
for i in `seq $hosts`;do
    host_name=node$i
    host_IP=$(awk -F " |\t" '/^'$host_name'/{print $2}' node_ip.txt) &> /dev/null
    node_hosts=$node_hosts"\"$host_IP\"",
done
export node_hosts=${node_hosts%%,}

SSL_DIR=${ETCD_SSL_DIR:=$ETCD_DIR/ssl}
export ETCD_SSL_DIR=$SSL_DIR
echo "检查或生成ssl证书中。。。"
[ -d $SSL_DIR ] || mkdir -p $SSL_DIR
echo $SSL_DIR
cd $SSL_DIR

[ ! -e ca-config.json ] && > ca-config.json && cat > ca-config.json << EOF  && echo "ca-config.json 创建成功"
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "www": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF

[ ! -e ca-csr.json ] && > ca-csr.json && cat > ca-csr.json << EOF && echo "ca-csr.json 创建成功"
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "GuangDong",
            "ST": "GuangZhou"
        }
    ]
}
EOF

[ ! -e server-csr.json ] && > server-csr.json && cat > server-csr.json << EOF && echo "server-csr.json 创建成功"
{
    "CN": "etcd",
    "hosts": [
	"$my_ip",$node_hosts
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "GuangDong",
            "ST": "GuangZhou"
        }
    ]
}
EOF
cfssl_linux-amd64 gencert -initca ca-csr.json | cfssljson_linux-amd64 -bare ca
cfssl_linux-amd64 gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www server-csr.json | cfssljson_linux-amd64 -bare server
echo "证书生成成功"
