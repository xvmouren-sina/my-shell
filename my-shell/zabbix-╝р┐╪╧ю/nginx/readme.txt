/*********************************nginx����*********************************************/
�鿴��û����Ҫ��ģ��Cwith-http_stub_status_module����Ҫ������װһ�¡�
�ο���https://www.cnblogs.com/huangyanqi/p/8527805.html

����վ���ļ��������locationģ�飺
location = /nginx_status {
          stub_status  on;
          access_log   off;
          allow 127.0.0.1;
          deny all;

# nginx -s reload
[root@nginx ~]# curl http://127.0.0.1/nginx-status
Active connections: 1
server accepts handled requests
 4 4 4
Reading: 0 Writing: 1 Waiting: 0


/**********************************�ű�����*************************************************/
# vim /etc/zabbix/nginx_status.sh
�ű����xȨ��

��zabbix_agentd .conf ������´��루����/etc/zabbix/zabbix_agentd.d/nginx.conf��
ע��ű�·��
UserParameter=Nginx.Status[*],/etc/zabbix/nginx_status.sh $1
���ԣ����о�zabbix-agent��������
# zabbix_get -s nginx-ip -k Nginx.Status[ping]
