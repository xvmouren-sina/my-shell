#!/bin/bash
#需要先将cfssl文件赋予可执行权限,并设置为系统命令
#
ssl_dir=/etc/etcd/ssl
[ -d $ssl_dir ] || mkdir -p $ssl_dir
cd $ssl_dir

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
	"`hostname -I`",
	$node_hosts
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
