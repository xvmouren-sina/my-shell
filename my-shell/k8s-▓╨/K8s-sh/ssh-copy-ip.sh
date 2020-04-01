#!/bin/bash
echo "传输密钥中 请稍等。。。"
rsa_p=$HOME/.ssh/id_rsa.pub
host_tab=node_ip.txt
hosts=$(awk '/^node/{++i}END{print i}'  $host_tab)
which expect &> /dev/null || yum install -y expect &> /dev/null  ##可能会安装失败
C_SSHKEY() {
expect << eof
spawn ssh-keygen
expect ".ssh/id_rsa):"
send "\n"
expect " for no passphrase):"
send "\n"
expect "same passphrase again:"
send "\n"
expect eof
eof
}

[ -f $rsa_p ] || C_SSHKEY &> /dev/null

SEND_KEY() {
for ((i=1;i<=$hosts;i++));do
	host_name=node$i
    host_IP=$(awk -F " |\t" '/^'$host_name'/{print $2}' $host_tab) &> /dev/null
    ping -W3 -c2 $host_IP &> /dev/null || continue
    host_PWD=$(awk -F " |\t" '/^'$host_name'/{print $NF}' $host_tab) &> /dev/null
    expect << eof
        spawn ssh-copy-id -i $host_IP
        expect {
            "yes/no" { send "yes\n"; exp_continue }
            "password:" { send "$host_PWD\n"}
        }   
        expect eof
eof
done
}
SEND_KEY &> /dev/null &
echo "密钥传输完成"
wait
