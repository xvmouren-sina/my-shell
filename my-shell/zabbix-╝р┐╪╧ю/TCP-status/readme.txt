��ӽű�xȨ��
chmod +x Tcp_Status.sh


��zabbix_agentd .conf ������ /etc/zabbix/zabbix_agentd.d/Tcp_Status.conf��������´���
ע��ű�·��
UserParameter=Tcp.Status[*],/etc/zabbix/Tcp_Status.sh $1
���ԣ����о�zabbix-agent��������
# zabbix_get -s ip -k Tcp.Status[TIMEWAIT]