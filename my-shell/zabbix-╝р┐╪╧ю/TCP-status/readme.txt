添加脚本x权限
chmod +x Tcp_Status.sh


在zabbix_agentd .conf （或者 /etc/zabbix/zabbix_agentd.d/Tcp_Status.conf）添加如下代码
注意脚本路径
UserParameter=Tcp.Status[*],/etc/zabbix/Tcp_Status.sh $1
测试，不行就zabbix-agent重启即可
# zabbix_get -s ip -k Tcp.Status[TIMEWAIT]